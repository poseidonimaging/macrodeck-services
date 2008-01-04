# This service provides user support across MacroDeck.
# This service requires UUIDService to work correctly.
# It also depends on the existance of Rails, or at
# least ActiveRecord. It also requires digest/sha2 and
# digest/md5.

require 'digest/md5'
require 'digest/sha2'
require 'user'
require 'group'
require 'group_member'

class UserService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.UserService"
	@serviceName = "UserService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 3
	@serviceVersionRevision = 20070709
	@serviceUUID = "8d6e8d29-55b0-4d74-bf71-84b2d653ba1f"

	# Depreciated methods
	# * getGroupMemberLevel - use group_obj.member(uuid).level or similar. see associated APIs.
	# * getUserProperty - get a User, then get the property from that object
	# * setUserProperty - see above
	# * getGroupProperty - get a Group, then get the property from that object
	# * setGroupProperty - see above
	# * addUserToGroup - group_obj.addUser
	# * removeUserFromGroup - group_obj.removeUser
	# * doesGroupMemberExist? - group.isMember?
	# * doesGroupExist? - UserService.isGroup?

	##### New User Handling Plans #####
	# We currently have a problem, which is that the username is required. If we are going to
	# use MacroDeck to extend other applications (Facebook), the username must be made optional.
	# We already use the user's UUID everywhere (so they could change their username), so this
	# won't break anything too incredibly important. But, how do we handle it? We will add a
	# column called context_data. It contains a YAMLized Hash that would look something like
	# this:
	#
	# {
	#	:facebook => { :fb_uid => 12345, :fb_other_stuff => "otherstuff" },
	#	:myspace => { :uid => 12345, :username => "ziggythehamster" }
	# }
	#
	# And then something like user.getContext(:facebook).fb_uid when you need their fb_uid, etc.
	# But then another problem arises.. searching for a Facebook user to get their specific
	# User. So perhaps we should just have a fb_uid column. I need to rethink this for sure,
	# but this is a start I think.

	# TODO: Accept a Metadata object.
	#
	# Creates a new user in the database, first checking to see if the user exists or not.
	# Returns the new user's UUID.
	def self.createUser(userName, password, secretQuestion, secretAnswer, name, displayName, email)
		if self.doesUserExist?(userName) == false
			user = User.new
			user.uuid = UUIDService.generateUUID
			user.username = userName.downcase
			if defined?(PASSWORD_SALT)
				user.password = "sha512:" + Digest::SHA512::hexdigest(PASSWORD_SALT + ":" + password)
			else
				user.password = "sha512:" + Digest::SHA512::hexdigest(password)
			end
			# removed 10-July-2006 by Ziggy #user.passwordhint = passHint
			user.secretquestion = secretQuestion
			user.secretanswer = secretAnswer
			user.name = name
			user.displayname = displayName
			user.creation = Time.now.to_i
			# removed 10-July-2006 by Ziggy #user.dob = dob
			user.email = email
			user.verified_email = false
			user.save!
			return user.uuid
		else
			return nil
		end
	end	

	# Takes a username (and optionally their context) as a parameter and returns their UUID.
	def getUserUUID(userName, context = nil)

	end
	
	# DEPRECIATED: Use isUser? combined with getUserUUID (TODO: create this function...) instead.
	#
	# Returns true if the user specified exists, returns false if the
	# user specified does not exist.
	def self.doesUserExist?(userName)
		user = User.find(:first, :conditions => ["username = ?", userName.downcase])
		if user == nil
			return false
		else
			return true
		end
	end
	
	# Returns true if the UUID matches a user.
	def self.isUser?(uuid)
		user = User.find(:first, :conditions => ["uuid = ?", uuid])
		if user != nil
			return true
		else
			return false
		end
	end
	
	# Returns true if the UUID matches a group.
	def self.isGroup?(uuid)
		group = Group.find(:first, :conditions => ["uuid = ?", uuid])
		if group != nil
			return true
		else
			return false
		end
	end

	# TODO: Audit and/or revise this code to be more coherent.
	# Perhaps require a userUUID to begin with?
	#
	# Returns an authentication code, does NOT create a session.
	# AuthCodes can be used to perform actions on behalf
	# of this user (i.e. from remote sites).
	def self.authenticate(userName, password, ipAddress)
		if self.doesUserExist?(userName)
			user = User.find(:first, :conditions => ["username = ?", userName.downcase])
			if defined?(PASSWORD_SALT)
				if user.password == "sha512:" + Digest::SHA512::hexdigest(PASSWORD_SALT + ":" + password)
					# create an authcode.
					authcode = createAuthCode(userName, user.password, ipAddress)
					# set the authcode
					user.authcode = authcode
					user.save!
					return { :authcode => authcode, :uuid => user.uuid }
				else
					return nil
				end
			else
				if user.password == "sha512:" + Digest::SHA512::hexdigest(password)
					# create an authcode.
					authcode = createAuthCode(userName, user.password, ipAddress)
					# set the authcode
					user.authcode = authcode
					user.save!
					return { :authcode => authcode, :uuid => user.uuid }
				else
					return nil
				end
			end
		else
			# User doesn't exist.
			return nil
		end
	end

	# TODO: Use Metadata instead!
	#
	# Creates a group with the information specified. Returns the UUID of the newly created group or nil.
	def self.createGroup(groupName, displayname)
		if self.doesGroupExist?(groupName) == false
			# Can create the group since it doesn't exist.
			group = Group.new
			group.uuid = UUIDService.generateUUID
			group.name = groupName.downcase
			group.displayname = displayname
			group.creation = Time.now.to_i
			group.save!
			return group.uuid
		else
			return nil
		end
	end
	# Validates an authcode specified with one in the database. If it matches, it returns
	# true. Otherwise, it returns false.
	def self.verifyAuthCode(uuid, authCode)
		user = User.find(:first, :conditions => ["uuid = ? AND authcode = ?", uuid, authCode])
		if user != nil
			return true
		else
			return false
		end
	end
	
	# Generates a new authCookie for a user. authCookies are not used for local authentication --
	# authCodes are. authCookies are simply a salt that must be used if someone attempts to get
	# a user's authCode from remote. There's more to it than that though. See UserWebService.
	def self.generateAuthCookie(uuid)
		user = User.find(:first, :conditions => ["uuid = ?", uuid])
		if user != nil
			r1 = rand
			r2 = rand
			r3 = rand
			authCookie = Digest::MD5::hexdigest("#{r1}:#{r2}:#{r3}")
			if user.authcookie_set_time == nil
				user.authcookie_set_time = 0
				user.save!
			end
			if user.authcookie_set_time >= (Time.now.to_i - 60)
				return nil
			else
				# the one minute security block hasn't been set off.
				user.authcookie = authCookie
				user.authcookie_set_time = Time.now.to_i
				user.save!
				return authCookie
			end
		else
			return nil
		end
	end
	
	# Returns a User object for the authCode specified. Two users should not have the same
	# authCode, so this should always work. If the authCode's not in the database, this function
	# will return nil.
	def self.userFromAuthCode(authCode)
		user = User.find(:first, :conditions => ["authcode = ?", authCode])
		if user != nil
			return user
		else
			return nil
		end
	end

	# TODO: change userName to userUUID?
	#
	# Creates an authentication code based on information
	# that can be retrieved in the function and a username
	# and password hash that are specified.
	def self.createAuthCode(userName, passHash, ipAddress)
		ipaddr_arr = ipAddress.split(".")
		# Changed the month addition to the current time so logging out and logging back in will make all cookies invalid.
		return Digest::SHA512::hexdigest(userName + ":" + passHash + ":" + ipaddr_arr[0].to_s + ":" + ipaddr_arr[1].to_s + ":" + ipaddr_arr[2].to_s + ":" + Time.now.to_i.to_s)
	end

	# DEPRECIATED: Use isGroup? combined with getGroupUUID (TODO: create this function..)
	#
	# Returns true if a group exists, false if one
	# does not.
	def self.doesGroupExist?(groupName)
		group = Group.find(:first, :conditions => ["name = ?", groupName.downcase])
		if group == nil
			return false
		else
			return true
		end
	end	
	
	# DEPRECIATED: Move to Group, rename to removeUser.
	#
	# Removes a user from a group.
	def self.removeUserFromGroup(groupID, userID)
		groupmember = GroupMember.find(:first, :conditions => ["groupid = ? AND userid = ?", groupID, userID])
		if groupmember != nil
			groupmember.destroy
		end
	end
	
	# DEPRECIATED: Move to Group, rename to banUser.
	#
	# Sets a particular user in a group as banned
	def self.banGroupMember(groupID, userID)
		groupmember = GroupMember.find(:first, :conditions => ["groupid = ? AND userid = ?", groupID, userID])
		if groupmember != nil
			groupmember.isbanned = true
			groupmember.save!
		end
	end
	
	# DEPRECIATED: Move to Group, rename to unbanUser
	#
	# Unsets a particular user in a group as banned
	def self.unbanGroupMember(groupID, userID)
		groupmember = GroupMember.find(:first, :conditions => ["groupid = ? AND userid = ?", groupID, userID])
		if groupmember != nil
			groupmember.isbanned = false
			groupmember.save!
		end
	end
	
	# DEPRECIATED: Move to Group, rename to isUserBanned?
	#
	# Returns true if a group member is banned, false
	# if a group member isn't banned, or nil if the
	# user could not be found.
	def self.isGroupMemberBanned?(groupID, userID)
		groupmember = GroupMember.find(:first, :conditions => ["groupid = ? AND userid = ?", groupID, userID])
		if groupmember != nil
			return groupmember.isbanned
		else
			return nil
		end
	end
	
	# DEPRECIATED: Move to Group, rename to setUserLevel
	#
	# Changes a user's level within a group. See addUserToGroup for
	# a list of valid levels.
	def self.changeGroupMemberLevel(groupID, userID, newLevel)
		if self.doesGroupMemberExist?(groupID, userID)
			groupmember = GroupMember.find(:first, :conditions => ["groupid = ? AND userid = ?", groupID, userID])
			case newLevel
				when :administrator, "administrator"
					groupmember.level = "administrator"
				when :moderator, "moderator"
					groupmember.level = "moderator"
				when :user, "user"
					groupmember.level = "user"
				else
					raise ArgumentError, "Valid group level not specified", caller
			end
			groupmember.save!
		end
	end
	
	# DEPRECIATED: Move to Group, rename to getUsers.
	#
	# Returns an array (that contains hashes) of the users
	# that are members of a group. The hashes returned are
	# in the following format:
	#
	#  { :uuid => "User's UUID", :level => :administrator, :isbanned => true }
	#
	# Keeping in mind that :level may be any possible in
	# addUserToGroup. And :isbanned can be false.
	def self.getGroupMembers(groupID)
		groupmembers = GroupMember.find(:all, :conditions => ["groupid = ?", groupID])
		members = Array.new
		groupmembers.each do |member|
			case member.level
				when "administrator"
					h = { :uuid => member.userid, :level => :administrator, :isbanned => member.isbanned }
				when "moderator"
					h = { :uuid => member.userid, :level => :moderator, :isbanned => member.isbanned }
				when "user"
					h = { :uuid => member.userid, :level => :user, :isbanned => member.isbanned }
			end
			members << h
		end
		return members
	end
	
	# DEPRECIATED: Rename to getGroupUUID.
	#
	# Returns the UUID of the group name specified.
	def self.lookupGroupName(groupName)
		group = Group.find(:first, :conditions => ["name = ?", groupName.downcase])
		if group != nil
			return group.uuid
		else
			return nil
		end
	end
	
	# DEPRECIATED: Rename to getUserUUID
	#
	# Returns the UUID of the user name specified
	def self.lookupUserName(userName)
		user = User.find(:first, :conditions => ["username = ?", userName.downcase])
		if user != nil
			return user.uuid
		else
			return nil
		end
	end
	
	# DEPRECIATED: Move to User and Group, call it human_name. 
	# Returns a user/group's display name or nil if the user/group
	# doesn't exist.
	def self.lookupUUID(uuid)
		user = User.find(:first, :conditions => ["uuid = ?", uuid])
		if user != nil
			return user.displayname
		else
			# lookup group name
			group = Group.find(:first, :conditions => ["uuid = ?", uuid])
			if group != nil
				return group.displayname
			else
				return nil
			end
		end
	end
	

	# TODO: Return an array of actual groups.
	# DEPRECIATED: Move to User, call getGroups
	#
	# Returns an array containing all of the UUIDs of the groups the user
	# specified is a member of.
	def self.getGroupsForMember(uuid)
		groups = Array.new
		groupmembers = GroupMember.find(:all, :conditions => ["userid = ?", uuid])
		groupmembers.each do |groupmember|
			groups << groupmember.groupid
		end
		return groups
	end
	
	# DEPRECIATED?: Should this be moved into the Permissions object? objid.permissions.isAllowed?(uuid)
	# is probably easier than this.
	#
	# Takes a permissions array (see http://developer.macrodeck.com/wiki/Services:UserService)
	# and returns true if the user specified is allowed. This function returns false if the
	# user is denied. The default is to deny -- that means that if you don't explicitly
	# allow everyone in an permission array, nobody can see it!
	def self.checkPermissions(perms, uuid)
		perms.each do |perm|
			if perm[:id] != nil
				if perm[:id].downcase == uuid.downcase
					if perm[:action] == :allow
						return true
					elsif perm[:action] == :deny
						return false
					end
				elsif self.isGroup?(perm[:id])
					# if the permission is a group
					if self.doesGroupMemberExist?(perm[:id], uuid)
						if perm[:action] == :allow
							return true
						elsif perm[:action] == :deny
							return false
						end
					end
				elsif perm[:id].downcase == "everybody"
					if perm[:action] == :allow
						return true
					elsif perm[:action] == :deny
						return false
					end
				end
			else
				# perm[:id] is nil therefore something is wrong.
				# deny them.
				return false
			end
		end
		# if the user hasn't matched a rule yet, they
		# will be denied for security!
		return false
	end
	
	# DEPRECIATED: Hack for the previous function.
	#
	# Loads permissions from YAML.
	def self.loadPermissions(permsYaml)
		perms = YAML::load(permsYaml)
		perms.each do |perm|
			if perm[:action] == "allow"
				perm[:action] = :allow
			elsif perm[:action] == "deny"
				perm[:action] = :deny
			end
		end
		return perms
	end
end

Services.registerService(UserService)
