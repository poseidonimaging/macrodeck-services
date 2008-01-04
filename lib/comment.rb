# This class is used to represent a Comment within a group of Comments.

require "data_service/data_item_common"

class Comment < ActiveRecord::Base
    set_table_name 'data_items'

## DECLARATIONS ###############################################################
    acts_as_ferret :fields => ['tags', 'description', 'title']
	before_create :set_creation_time, :set_uuid_if_not_set
	before_save :set_updated_time, :set_uuid_if_not_set

## CLASS METHODS ##############################################################
	
	# Extend this class with more methods
	extend DataItemCommon::ClassMethods

## INSTANCE METHODS ###########################################################

	# Include common DataItem methods
	include DataItemCommon::InstanceMethods

	# Override the inspect method to give us something a bit more useful.
	def inspect
		return "#<Comment:#{title}>"
	end

	def parent?
		if @parent.nil?
			@parent = Comments.find(:first, :conditions => ["groupingid = ?", grouping])
		end
		if @parent != nil
			return true
		else
			return false
		end
	end

	def parent
		if @parent.nil?
			@parent = Comments.find(:first, :conditions => ["groupingid = ?", grouping])
		end
		return @parent
	end

	# Returns the body of the message
	def message
		return self.getValue(:string)
	end

	# Sets the message body
	def message=(msg)
		return self.setValue(:string, msg)
	end

## PRIVATE INSTANCE METHODS ###################################################
	
	private
		def set_updated_time
			self.updated = Time.new.to_i
			return true
		end

		def set_creation_time
			self.creation = Time.new.to_i
			return true
		end

		def set_uuid_if_not_set
			if self.uuid == nil || self.uuid == ""
				self.uuid = UUIDService.generateUUID
			end
			return true
		end
end
