# This is the the ActiveRecord model that
# represents data items. A bunch of
# convienence methods will be added here
# to help DataService do its job.
# Of course, this means that DataService will
# absolutely not be able to run outside of
# Rails. At least not without some hack.

# External requirements
require 'data_service/data_item_common'

class DataItem < ActiveRecord::Base

## DEPRECATION WARNING! #######################################################
# findDataByGrouping is no longer valid. Please use
# DataGroup.getGroup(uuid).items.

## DECLARATIONS ###############################################################
    acts_as_ferret :fields => ['tags', 'description', 'title']
	before_create :set_creation_time, :set_uuid_if_not_set
	before_save :set_updated_time

## CLASS METHODS ##############################################################
	
	# Extend this class with more methods
	extend DataItemCommon::ClassMethods

## INSTANCE METHODS ###########################################################

	# Include common DataItem methods
	include DataItemCommon::InstanceMethods

## PRIVATE INSTANCE METHODS ###################################################
	
	private
		def set_updated_time
			updated = Time.new.to_i
			return true
		end

		def set_creation_time
			creation = Time.new.to_i
			return true
		end

		def set_uuid_if_not_set
			if uuid == nil || uuid == ""
				uuid = UUIDService.generateUUID
			end
			return true
		end
end
