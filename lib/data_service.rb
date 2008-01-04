# This service handles all of the data for MacroDeck.
# This service *requires* Rails to function due to its
# use of ActiveRecord. I believe that if you were to
# load ActiveRecord, you could probably get away
# with using only ActiveRecord.
#
# BIG FAT WARNING!
# ================
#
# Most of the methods in DataService differ in some
# way from the old version (0.2). We are even trying
# to help out a little by throwing up a huge error if
# you use a method that's been depreciated in this way.
# Of course, it probably won't work, since alias is
# really meant for instance methods, but meh. We tried.
# (Everyone is free to point out that we're using the
# wrong word... we should be using obsolete instead of
# depreciated, since depreciated implies it still sort
# of works... you fix it ;) )

require "data_item"		# DataItem model
require "data_group"	# DataGroup model
require "data_source"	# DataSource model
require "user_source"	# UserSource model
require "category"
require "yaml"

class DataService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.DataService"
	@serviceName = "DataService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 3
	@serviceVersionRevision = 20071015
	@serviceUUID = "ae52b2a9-0872-4651-b159-c37715a53704"

	# THE FOLLOWING METHODS ARE DEPRECIATED AND NO LONGER SUPPORTED!
	#
	# * modifyDataItem - use DataService.getData(uuid).setValue(:string, "whatever") instead.
	# * findDataGrouping - use getGroup instead. Otherwise, use DataGroup.find.
	# * createData - to ensure that all data items are created as children of data groups,
	#   the data creation function moved to the DataGroup object. So, create a group, then
	#   create an item within that group.
	# * getDataGroupItems - find a group and use that group's .items method.
	# * doesDataItemExist? - use DataItem.isItem?(itemID) instead.
	# * doesDataGroupExist? - use DataGroup.isGroup?(itemID) instead.
	# * modifyDataGroupMetadata - modify the metadata directly (getDataGroup is a start)
	# * getDataGroupMetadata - get it from a DataGroup (use getDataGroup).
	# * getDataItemMetadata - get it from a DataItem.
	# * modifyDataItemMetadata - set it from a DataItem.
	


	# Returns a DataItem for the specified UUID. The old
	# behavior of getData can be reproduced by using
	# DataService.getData(uuid).value(:type).
	#
	# Use DataItem's "setValue" method to set data values. It
	# replaces modifyDataItem.
	def self.getData(dataID)
		ditem = DataItem.getItem(dataID)
		return ditem
	end

	# Deletes a data item specified by its ID
	def self.deleteDataItem(dataID)
		dataObj = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if dataObj != nil
			# TODO: If the data item is the only child of a data group, we should probably
			# destroy the data group as well.
			dataObj.destroy
			return true
		else
			return false
		end		
	end

	# Gets a DataGroup for the specified UUID.
	def self.getDataGroup(groupID)
		dgroup = DataGroup.getGroup(groupID)
		return dgroup
	end
	
	# Deletes a data group specified by its groupID
	def self.deleteDataGroup(groupID)
		dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", groupID])
		if dgroup != nil
			# Kill all of the children.
			# In a different context, I might get called by those wonderful fellows at the
			# Department of Homeland Security...
			if dgroup.items?
				dgroup.items.each do |i|
					i.destroy
				end
			end
			# ...but fuck it, I might get called anyway.
			dgroup.destroy
			return true
		else
			return false
		end
	end
	
	# Creates a new DataGroup. See Metadata for parameters you can use. Returns
	# the group itself (previously returned a string).
	def self.createDataGroup(objMetadata = Metadata.new)        
		group = DataGroup.new do |g|       
			g.uuid = UUIDService.generateUUID
			g.creation = Time.now.to_i # XXX: it should be replaced by creation_at
			g.loadMetadata(objMetadata)
		end
		group.save!
		return group
	end

	# Creates a new category that comes from the root of the category tree.
	def self.createCategory(objMetadata = Metadata.new)
		category = Category.new do |c|
			c.uuid = UUIDService.generateUUID
			c.loadMetadata(objMetadata)
		end
		category.save!
		return category
	end

	# Returns a Category for a UUID
	def self.getCategory(uuid)
		category = Category.find_by_uuid(uuid)
		return category
	end

	# TODO: Fix this to be more like createData.
	#
	# Creates remote data with the sourceid specified.
	# Keep in mind that this is only a helper function so you don't
	# have to play with the models. Remote data is still accessed
	# like normal data.
	def self.createRemoteDataItem(valueType, dataValue, metadata, sourceId)
		uuid = self.createData(valueType, dataValue, metadata)
		if uuid != nil
			ditem = DataItem.find(:first, :conditions => ["dataid = ?", uuid])
			if ditem != nil
				ditem.sourceid = sourceId
				ditem.remote_data = true
				ditem.save!
			end
		end
		return uuid
	end
	
	# TODO: Fix this to be more like createDataGroup.
	#
	# Creates remote data groups with the sourceid specified.
	# You still access it like normal data groups.
	def self.createRemoteDataGroup(groupingID, parent, metadata, sourceId)
		uuid = self.createDataGroup(groupingID, parent, metadata)
		if uuid != nil
			dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", uuid])
			if dgroup != nil
				dgroup.sourceid = sourceId
				dgroup.remote_data = true
				dgroup.save!
			end
		end
		return uuid
	end

	### DEPRECIATED METHODS FOLLOW ###
	
	# DEPRECIATED: Will be replaced by a much simpler Permission object
	# that will belong to DataGroups and DataItems. Then you do something
	# like item.permissions.add_last :read, :allow, uuid...
	#
	# Sets the permissions on a data item. +kind+
	# is either :read or :write for read permissions
	# and write permissions respectively. +value+
	# is the permission array (see Services:UserService
	# on the wiki)
	def self.setPermissions(dataID, kind, value)
		ditem = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if ditem != nil
			case kind
				when :write, "write"
					value.each do |val|
						if val[:action] == "allow"
							val[:action] = :allow
						elsif val[:action] == "deny"
							val[:action] = :deny
						end
					end						
					ditem.write_permissions = value.to_yaml
					ditem.save!
					return true
				when :read, "read"
					value.each do |val|
						if val[:action] == "allow"
							val[:action] = :allow
						elsif val[:action] == "deny"
							val[:action] = :deny
						end
					end				
					ditem.read_permissions = value.to_yaml
					ditem.save!
					return true
				else
					return false
			end
		else
			return false
		end
	end
	
	# DEPRECIATED: See setPermissions.
	#
	# Returns an array containing the permissions requested
	# of the data item specified.
	def self.getPermissions(dataID, kind)
		ditem = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if ditem != nil
			case kind
				when :write, "write"
					perms = UserService.loadPermissions(ditem.write_permissions)
					return perms					
				when :read, "read"
					perms = UserService.loadPermissions(ditem.read_permissions)
					return perms
				else
					return nil
			end
		else
			return nil
		end	
	end
	
	# DEPRECIATED: See setPermissions.
	#
	# Gets the default permissions on a data group.
	def self.getDefaultPermissions(groupID, kind)
		dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", groupID])
		if dgroup != nil
			case kind
				when :write, "write"
					perms = UserService.loadPermissions(dgroup.write_permissions)
					return perms
				when :read, "read"
					perms = UserService.loadPermissions(dgroup.read_permissions)
					return perms					
				else
					return false
			end
		else
			return false
		end	
	end
	
	# DEPRECIATED: See setPermissions.
	#
	# Sets the default permissions on a data group.
	# See setPermissions for more info.
	def self.setDefaultPermissions(groupID, kind, value)
		dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", groupID])
		if dgroup != nil
			case kind
				when :write, "write"
					value.each do |val|
						if val[:action] == "allow"
							val[:action] = :allow
						elsif val[:action] == "deny"
							val[:action] = :deny
						end
					end
					dgroup.write_permissions = value.to_yaml
					dgroup.save!
					return true
				when :read, "read"
					value.each do |val|
						if val[:action] == "allow"
							val[:action] = :allow
						elsif val[:action] == "deny"
							val[:action] = :deny
						end
					end				
					dgroup.read_permissions = value.to_yaml
					dgroup.save!
					return true
				else
					return false
			end
		else
			return false
		end	
	end
	
	# DEPRECIATED: See setPermissions.
	#
	# Returns true if the user specified (by UUID) can
	# read the data item or data group specified (by UUID)
	def self.canRead?(dataID, userID)
		ditem = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if ditem != nil
			# the creator and owner always have permission to read/write.
			if ditem.creator == userID
				return true
			elsif ditem.owner == userID
				return true
			else
				return UserService.checkPermissions(YAML::load(ditem.read_permissions), userID)
			end
		else
			# check data group
			dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", dataID])
			if dgroup != nil
				if dgroup.creator == userID
					return true
				elsif dgroup.owner == userID
					return true
				else
					return UserService.checkPermissions(YAML::load(dgroup.read_permissions), userID)
				end
			else
				return false
			end		
		end
	end
	
	# DEPRECIATED: See setPermissions.
	#
	# Returns true if the user specified (by UUID) can
	# write to the data item or data group specified (by UUID)
	def self.canWrite?(dataID, userID)
		ditem = DataItem.find(:first, :conditions => ["dataid = ?", dataID])
		if ditem != nil
			# the creator and owner always have permission to read/write.
			if ditem.creator == userID
				return true
			elsif ditem.owner == userID
				return true
			else
				return UserService.checkPermissions(YAML::load(ditem.write_permissions), userID)
			end
		else
			# check data group
			dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", dataID])
			if dgroup != nil
				if dgroup.creator == userID
					return true
				elsif dgroup.owner == userID
					return true
				else
					return UserService.checkPermissions(YAML::load(dgroup.write_permissions), userID)
				end
			else
				return false
			end
		end
	end

end

Services.registerService(DataService)
