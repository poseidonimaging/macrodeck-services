# This model is used by UserService for interacting with the groups table

class Group < ActiveRecord::Base
	has_many :group_members

	# Returns true if the userID specified is a member
	# of this group, false otherwise
	def isMember?(userID)
		gm = GroupMember.find(:first, :conditions => ["userid = ? AND groupid = ?", userID, uuid])
		if gm != nil
			return true
		else
			return false
		end
	end

	# Adds a user to this group.
	def addUser(userID, level)
		if isMember?(userID) == false
			# only add if the user doesn't already exist
			groupmember = GroupMember.new
			groupmember.groupid = uuid
			groupmember.userid = userID
			case level
				when :administrator, "administrator"
					groupmember.level = "administrator"
				when :moderator, "moderator"
					groupmember.level = "moderator"
				when :user, "user"
					groupmember.level = "user"
				else
					raise "Valid permission level not specified in Group.addUser"
			end
			groupmember.isbanned = false
			groupmember.save!
			return groupmember
		else
			return nil
		end
	end
end
