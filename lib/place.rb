# This class is used as a helper for creating places

require "data_service/data_item_common"
require "place_metadata"

class Place < ActiveRecord::Base
    set_table_name 'data_items'

## DECLARATIONS ###############################################################
	# broken # acts_as_ferret :fields => ['tags', 'description', 'title']
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
		return "#<Place:#{title}>"
	end

	# Set's a place's metadata (but not the item's metadata). Can accept either a
	# PlaceMetadata object or a Hash with the same values.
	def place_metadata=(metadata = PlaceMetadata.new)
		if metadata.nil? || metadata.class == NilClass
			pmeta = PlaceMetadata.new
			self.setValue(:object, pmeta)
		elsif metadata.class == PlaceMetadata
			self.setValue(:object, metadata)
		elsif metadata.class == Hash
			pmeta = PlaceMetadata.from_hash(metadata)
			self.setValue(:object, pmeta)
		else
			raise ArgumentError
		end
	end

	# Return the place's metadata as a PlaceMetadata object.
	def place_metadata
		return self.value(:object)
	end

	def parent?
		p = City.find(:first, :conditions => ["groupingid = ?", grouping])
		if p != nil
			return true
		else
			return false
		end
	end

	# Returns this place's parent city
	def parent
		p = City.find(:first, :conditions => ["groupingid = ?", grouping])
		return p
	end

	# Alias for title, allows place.name
	def name
		return self.title
	end

	# FIXME: TEMPORARY USE ONLY
	def url_part
		return self.dataid
	end

	# Returns an array containing User objects of all of the patrons of this place, or else nil
	def patrons
		patron_list = Relationship.find(:all, :conditions => ["target_uuid = ? AND relationship = 'patron'", self.dataid])
		user_list = []
		if patron_list != nil && patron_list.length > 0
			patron_list.each do |patron|
				user = User.find(:first, :conditions => ["uuid = ?", patron.source_uuid])
				if user != nil
					user_list << user
				end
			end
		end
		return user_list
	end

	# Returns the Comments group that belongs to this Place (aka "the wall").
	# If the group doesn't exist, it will create it for you.
	def wall
		if @wall.nil?
			@wall = Comments.find(:first, :conditions => ["parent = ? AND groupingtype = ?", self.dataid, DTYPE_COMMENTS])
			# create the comments if they don't exist yet
			if @wall.nil?
				@wall = Comments.new do |c|
					c.title = "#{self.title}'s Wall"
					c.parent = self.dataid
					c.groupingid = UUIDService.generateUUID()
					c.groupingtype = DTYPE_COMMENTS
					c.creator = CREATOR_MACRODECK
					c.owner = CREATOR_MACRODECK
				end
				@wall.save!
			end
		end
		return @wall
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
