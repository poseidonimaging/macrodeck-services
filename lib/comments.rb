# This class is for a group of comments.

require "data_service/data_group_common"

class Comments < ActiveRecord::Base
    set_table_name 'data_groups'

## DECLARATIONS ###############################################################
	
    acts_as_ferret :fields => [:tags, :description, :title]
	before_create :set_creator, :set_owner, :set_creation_time
	before_save :set_updated_time, :set_uuid_if_not_set

## CLASS METHODS ##############################################################
	
	# Extend the class with the base class methods.
	extend DataGroupCommon::ClassMethods

	# Override count so it returns something that makes sense. If you need the original
	# count, use calculate, but realize that it will *not* count just Comments...
	def self.count
		return self.calculate(:count, :all, :conditions => ["groupingtype = ?", DTYPE_COMMENTS])
	end
	
## INSTANCE METHODS ###########################################################

	# Include common instance methods
	include DataGroupCommon::InstanceMethods

	# Override the inspect method to give us something a bit more useful.
	def inspect
		return "#<Comments:#{title}>"
	end

	# Returns true if there are comments, false otherwise.
	def comments?
		if @comments.nil?
			@comments = Comment.find(:first, :conditions => ["datatype = ? AND grouping = ?", DTYPE_COMMENT, groupingid])
		end
		if @comments != nil
			return true
		else
			return false
		end
	end

	# Returns the number of comments in the comment group
	def comment_count
		if @comment_count.nil?
			@comment_count = Comment.calculate(:count, :all, :conditions => ["datatype = ? AND grouping = ?", DTYPE_COMMENT, groupingid])
		end
		return @comment_count
	end

	# Returns ten of the latest comments
	def latest_comments
		if @latest_comments.nil?
			@latest_comments = Comment.find(:all, :conditions => ["datatype = ? AND grouping = ?", DTYPE_COMMENT, groupingid], :order => "creation DESC", :limit => 10)
		end
		return @latest_comments
	end

	# Returns all of the comments in this comment group 
	def comments
		if @comments.nil?
			@comments = Comment.find(:all, :conditions => ["datatype = ? AND grouping = ?", DTYPE_COMMENT, groupingid], :order => "creation DESC") # order newest first
		end
		return @comments
	end
	
	# Creates a comment. First parameter is the text second is the Metadata (hash or otherwise)
	def create_comment(text, meta = Metadata.new)
		item = Comment.new do |i|
			i.update_attributes(meta.to_hash)

			# defaults if not set in Metadata
			i.datacreator = CREATOR_MACRODECK unless i.datacreator
			i.datatype = DTYPE_COMMENT
			i.grouping = self.groupingid
			i.creation = Time.now.to_i
			i.updated = Time.now.to_i
		end
		item.message = text
		item.save!    
		return item
	end

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
			if groupingid == nil || groupingid == ""
				groupingid = UUIDService.generateUUID
			end
			return true
		end

		def set_creator
			if creator == nil || creator == ""
				creator = CREATOR_MACRODECK
			end
			return true
		end

		def set_owner
			if owner == nil || owner == ""
				owner = CREATOR_MACRODECK
			end
			return true
		end
end
