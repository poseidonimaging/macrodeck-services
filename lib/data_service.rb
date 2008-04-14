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

#require "data_service/data_item"	# DataItem model
#require "data_service/data_group"	# DataGroup model
require "data_service/data_source"	# DataSource model
require "data_service/user_source"	# UserSource model
require "data_service/data_object"	# New DataObject model
require "category"
require "yaml"

class DataService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.DataService"
	@serviceName = "DataService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 3
	@serviceVersionRevision = 20080211
	@serviceUUID = "ae52b2a9-0872-4651-b159-c37715a53704"

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
end

Services.registerService(DataService)
