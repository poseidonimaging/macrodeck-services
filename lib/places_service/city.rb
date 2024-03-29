# This class is used as a helper for creating cities for
# Places

class City < DataObject
	acts_as_macrodeck_wall
	acts_as_macrodeck_calendarable

	has_many :places, :foreign_key => "parent_id"

	# Override the inspect method to give us something a bit more useful.
	def inspect
		return "#<City:#{self.to_s}>"
	end

	# To string method
	def to_s
		return self.name + ", " + self.state(:abbreviation => true)
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

	# Returns the upcoming events in this city.
	def upcoming_events
		return Calendar.upcoming_events_in_category(self.category_id)
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

	# Returns this city in XML (our own schema).
	def to_xml
		builder = Builder::XmlMarkup.new
		xml = builder.city do |city|
			city.instruct!
			city.uuid(self.uuid)
			city.name(self.name)
			city.description(self.description)
			city.state(self.state(:abbreviation => false), :abbreviation => self.state(:abbreviation => true))
			city.category_uuid(self.category.uuid)
			city.created_at(self.created_at.to_s(:db))
			city.updated_at(self.updated_at.to_s(:db))
		end

		return xml
	end

## PRIVATE INSTANCE METHODS ###################################################
	
	private
		# This method takes a string and returns a suitable URL version.
		def url_sanitize(str)
			return str.chomp.strip.downcase.gsub(/[^0-9A-Za-z_\-\s]/, "").gsub(" ", "-")
		end
end
