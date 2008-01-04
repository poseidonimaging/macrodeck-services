# This ActiveRecord model is for the data_groups table. 
# This table defines groupings for DataItem objects,
# and gives each group a type. Its columns are
# similar to DataItem.

# External files.
require "data_service/data_group_common"

class DataGroup < ActiveRecord::Base

# THE FOLLOWING METHODS ARE NO LONGER SUPPORTED AND HAVE BEEN REMOVED:
# findGroupings
# findGroupingsByCreator
# findGroupingsByOwner
# findGroupingsByParent
#
# Use find with :conditions instead!

## DECLARATIONS ###############################################################
	
    acts_as_ferret :fields => [:tags, :description, :title]
	before_create :set_creation_time, :set_uuid_if_not_set
	before_save :set_updated_time

## CLASS METHODS ##############################################################
	
	# Extend the class with the base class methods.
	extend DataGroupCommon::ClassMethods
	
## INSTANCE METHODS ###########################################################

	# Include common instance methods
	include DataGroupCommon::InstanceMethods

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
