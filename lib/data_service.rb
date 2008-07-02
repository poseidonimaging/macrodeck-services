# This service handles all of the data for MacroDeck.
# This service's components require ActiveRecord.

require "data_service/data_source"	# DataSource model
require "data_service/user_source"	# UserSource model
require "data_service/data_object"	# New DataObject model
require "data_service/category"		# Category model
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
end

Services.registerService(DataService)
