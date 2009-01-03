# This class is used as a helper for creating cities for
# Places

class City < DataObject
	acts_as_macrodeck_wall
	acts_as_macrodeck_calendarable

	# Override the inspect method to give us something a bit more useful.
	def inspect
		return "#<City:#{title}>"
	end

	# Get a city's associated state by its category. Specify :abbreviation => true to return
	# only the state's abbreviation
	def state(options = { :abbreviation => false })
		if self.category != nil
			if @category_parent.nil?
				@category_parent = self.category.parent
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
				raise "Parent of category [#{self.category}] does not exist in #{self.inspect}"
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
		return !(Place.find(:first, :conditions => ["parent_id = ?", self.id]).empty?)
	end

	# Returns a list of places (all of them).
	# If you want to narrow your search, consider using Place.find 
	def places
		return Place.find(:all, :conditions => ["parent_id = ?", self.id])
	end
	
	# Creates a place as a subitem of this item.
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

			i.parent = self
			i.category = self.category
			i.place_metadata = nil
		end
		item.save!
		return item
	end

	# Returns 10 newest places.
	def top_10_newest_places
		return Place.find(:all, :conditions => ["parent_id = ?", self.id], :order => "created_at DESC", :limit => 10)
	end

	# Returns 10 random places
	def get_10_random_places
		return Place.find(:all, :conditions => ["parent_id = ?", self.id], :order => "RAND()", :limit => 10)
	end

	# Fake url_part handling.
	def url_part
		return url_sanitize(self.title)
	end

	# Fake country handling
	def country
		return "us"
	end

	# Partial
	def path_of_partial
		return "models/city"
	end

	# Returns a full URL to this model. Options:
	# :facebook		=> true | false
	# :action		=> a valid action
	def url(options = {})
		if options[:facebook]
			url = "#{PLACES_FBURL}/"
		else
			url = "/"
		end

		if options[:action] != nil && options[:action] != ""
			url << "#{url_sanitize(options[:action].to_s)}/"
		else
			url << "view/"
		end
		url << url_sanitize(self.country) << "/"
		url << url_sanitize(self.state(:abbreviation => true)) << "/"
		url << url_sanitize(self.url_part) << "/"
		return url
	end

## PRIVATE INSTANCE METHODS ###################################################
	
	private
		# This method takes a string and returns a suitable URL version.
		def url_sanitize(str)
			return str.chomp.strip.downcase.gsub(/[^0-9A-Za-z_\-\s]/, "").gsub(" ", "-")
		end
end
