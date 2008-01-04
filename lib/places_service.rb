# This service wraps DataService and other related stuff for
# the Places application.

require "category"
require "city"
require "place"
require "place_metadata"

class PlacesService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.PlacesService"
	@serviceName = "PlacesService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 3
	@serviceVersionRevision = 20071116
	@serviceUUID = "4c8c7deb-7e7b-485b-a467-6b7b195895fd"

	# Returns true if the city exists, false if the city does not exist.
	def self.isCity?(city_name, state)

		# check to see if the state is valid.
		states = self.getUSStates
		valid_state = false
		valid_city = false
		state_category = nil
		
		states.each	do |s|
			if s.title.downcase == state.downcase || s.url_part.downcase == state.downcase
				valid_state = true
				state_category = s
			end
		end

		# If the state is not valid, the city cannot be. So we return false unless the state is valid
		unless valid_state
			return false
		end

		# Now, does the state category have a child named city_name? Return false unless it does.
		unless state_category.hasChild?(city_name)
			return false
		end

		# So there is a city inside the state specified.
		return true
	end

	# Returns a City object for the city specified.
	def self.getCity(city_name, state)

		# check to see if the state is valid.
		states = self.getUSStates
		valid_state = false
		valid_city = false
		state_category = nil
		
		states.each	do |s|
			if s.title.downcase == state.downcase || s.url_part.downcase == state.downcase
				valid_state = true
				state_category = s
			end
		end

		# If the state is not valid, the city cannot be. So we return nil unless the state is valid
		unless valid_state
			return nil
		end

		# Now, does the state category have a child named city_name? Return nil unless it does.
		unless state_category.hasChild?(city_name)
			return nil
		end

		# The city exists, now get the child category and get the city object.
		city_category = state_category.getChild(city_name)
		city = City.find_by_category(city_category.uuid)
		return city
	end

	# Returns the category for a state specified.
	# Specify by name or abbreviation.
	def self.getStateCategory(state)
		states = self.getUSStates
		state_category = nil
		
		states.each	do |s|
			if s.title.downcase == state.downcase || s.url_part.downcase == state.downcase
				return s
			end
		end

		return nil
	end

	# Creates a city with the specified name and state.
	# Returns a City (spiffy DataGroup) object. States can
	# be specified as the abbreviation or spelled out.
	def self.createCity(city_name, state)
		
		# check to see if the city exists
		is_valid_city = self.isCity?(city_name, state)
		if is_valid_city
			return nil
		end

		# Create a child Category of state_category
		city_category = self.getStateCategory(state).createChild({ :title => city_name })
		
		if city_category == nil
			raise "PlacesService critical error: createCity could not create a city category for #{city_name}, #{state}"
		end

		# Save the URL-part
		city_category.url_part = self.makeURLPart(city_name)
		city_category.can_have_items = true
		city_category.save!

		# Now create a city
		city = City.new do |c|
			c.uuid = UUIDService.generateUUID
			c.creation = Time.now.to_i
			c.category = city_category.uuid
			c.title = city_name
			c.groupingtype = DTYPE_CITY
			# MacroDeck owns cities.
			c.creator = CREATOR_MACRODECK
			c.owner = CREATOR_MACRODECK
		end
		city.save!

		return city
	end

	# Returns a list of states as categories.
	def self.getUSStates()
		places = Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"])
		country = places.getChildByURL("us")

		if country != nil
			states = country.children
			return states
		else
			raise "Country not found."
		end
	end

	# This method takes a string and returns a suitable URL version.
	def self.makeURLPart(str)
		return str.chomp.strip.downcase.gsub(/[^0-9A-Za-z_\-\s]/, "").gsub(" ", "-")
	end
end

Services.registerService(PlacesService)
