# This class is used as a helper for creating cities for
# Places

require "data_service/data_group_common"

class City < ActiveRecord::Base
    set_table_name 'data_groups'

## DECLARATIONS ###############################################################
	
	# broken # acts_as_ferret :fields => [:tags, :description, :title]
	before_create :set_creator, :set_owner, :set_data_type, :set_creation_time, :set_uuid_if_not_set
	before_save :set_updated_time, :set_data_type

## CLASS METHODS ##############################################################
	
	# Extend the class with the base class methods.
	extend DataGroupCommon::ClassMethods

	# Override count so it returns something that makes sense. If you need the original
	# count, use calculate, but realize that it will *not* count just Cities...
	def self.count
		return self.calculate(:count, :all, :conditions => ["groupingtype = ?", DTYPE_CITY])
	end

	# Method to get all cities (probably stupid on a normal server)
	def self.find_all_cities
		return self.find(:all, :conditions => ["groupingtype = ?", DTYPE_CITY])
	end
	
## INSTANCE METHODS ###########################################################

	# Include common instance methods
	include DataGroupCommon::InstanceMethods

	# Override the inspect method to give us something a bit more useful.
	def inspect
		return "#<City:#{title}>"
	end

	# Get a city's associated state by its category. Specify :abbreviation => true to return
	# only the state's abbreviation
	def state(options = { :abbreviation => false })
		if self.category != nil
			# Just in case we screwed up somehow.
			if @category_self.nil?
				@category_self = Category.find_by_uuid(self.category)
			end
			if @category_self != nil
				if @category_parent.nil?
					@category_parent = @category_self.parent
				end
				if @category_parent != nil
					if options[:abbreviation] == false
						return @category_parent.title
					elsif options[:abbreviation] == true
						return @category_parent.url_part.upcase
					else
						raise ArgumentError
					end
				else
					raise "Parent of category [#{category}] does not exist in #{self.inspect}"
				end
			else
				raise "Category [#{category}] does not exist in #{self.inspect}"
			end
		else
			raise "Category not set in #{self.inspect}"
		end
	end

	# Alias for title; makes City.name work and sane.
	def name
		return self.title
	end

	# Returns true if there are places; false if not.
	# Differs from children? in that it only checks stuff with the correct datatype.
	def places?
		if @places.nil?
			@places = Place.find(:first, :conditions => ["datatype = ? AND grouping = ?", DTYPE_PLACE, groupingid])
		end
		if @places != nil
			return true
		else
			return false
		end
	end

	# Returns a list of places (all of them).
	# If you want to narrow your search, consider using Place.find and something like this for conditions:
	#   :conditions => ["grouping = ? AND title = ?", city.groupingid, "Pizza Hut"]
	def places
		if @places.nil?
			@places = Place.find(:all, :conditions => ["datatype = ? AND grouping = ?", DTYPE_PLACE, groupingid])
		end
		return @places
	end
	
	# Creates a place (basically the same as createItem, except it sets a datatype)
	# You still have to set the place's metadata...
	#
	# == Sample Usage ==
	#
	#   # c = City
	#   p = c.create_place({ :title => "Chili's", :description => "Bar and Grill" })
	#   # p is now a new Place - congratulations!
	#
	def create_place(meta = Metadata.new)
		item = Place.new do |i|
			i.update_attributes(meta.to_hash)

			# defaults if not set in Metadata
			i.datacreator = CREATOR_MACRODECK unless i.datacreator
			i.datatype = DTYPE_PLACE
			i.grouping = self.groupingid
			i.creation = Time.now.to_i
			i.updated = Time.now.to_i
			i.place_metadata = nil
		end
		item.save!    
		return item
	end

	# Returns 10 newest places.
	def top_10_newest_places
		# Cache the result
		if @top_10_newest_places.nil?
			@top_10_newest_places = Place.find(:all, :conditions => ["datatype = ? AND grouping = ?", DTYPE_PLACE, groupingid], :order => "creation DESC", :limit => 10)
		end
		return @top_10_newest_places
	end

	# Returns 10 random places
	def get_10_random_places
		# Cache the result
		if @get_10_random_places.nil?
			@get_10_random_places = Place.find(:all, :conditions => ["datatype = ? AND grouping = ?", DTYPE_PLACE, groupingid], :order => "RAND()", :limit => 10)
		end
		return @get_10_random_places
	end

	# Fake url_part handling.
	def url_part
		return url_sanitize(self.title)
	end

	# Fake country handling
	def country
		return "us"
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

		def set_creator
			if self.creator == nil || self.creator == ""
				creator = CREATOR_MACRODECK
			end
			return true
		end

		def set_owner
			if self.owner == nil || self.owner == ""
				owner = CREATOR_MACRODECK
			end
			return true
		end

		def set_data_type
			self.groupingtype = DTYPE_CITY
			return true
		end

		# This method takes a string and returns a suitable URL version.
		def url_sanitize(str)
			return str.chomp.strip.downcase.gsub(/[^0-9A-Za-z_\-\s]/, "").gsub(" ", "-")
		end
end
