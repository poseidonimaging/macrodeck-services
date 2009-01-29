# PlaceMetadata is a class that we store as the objectdata of an item that contains all of the information you would want to know about a place.
class PlaceMetadata
	# Standard information
	attr_accessor :address, :zipcode, :phone_number, :website, :latitude, :longitude, :type, :type_other, :features, :parking

	# Hours of operation
	attr_accessor :hours_sunday, :hours_monday, :hours_tuesday, :hours_wednesday, :hours_thursday, :hours_friday, :hours_saturday

	# Photo stuff.
	attr_accessor :flickr_photo_id

	PLACE_FEATURES = {	# Alcohol
						:full_bar => "Full Bar", # Restaurant has a bar
						:wine => "Wine",
						:byob => "BYOB",
						:beer => "Beer",
						# Internet features
						:free_wifi => "Free WiFi",
						:pay_wifi => "Pay WiFi",
						# Ordering features
						:takeout => "Takeout", # Same as carryout
						:delivery => "Delivery",
						:call_ahead => "Call-Ahead Seating",
						:drive_thru => "Drive-Thru",
						# Restaurant meals offered
						:breakfast => "Breakfast",
						:lunch => "Lunch",
						:dinner => "Dinner",
						:catering => "Catering",
						# Atmosphere
						:pets_allowed => "Pets Allowed",
						:televisions => "Televisions",
						:outdoor_seating => "Outdoor Seating",
						:vegeterian_friendly => "Vegeterian-Friendly",
						:live_music => "Live Music",
						:date_friendly => "Date-Friendly",
						:kid_friendly => "Kid Friendly",
						:casual => "Casual",	# this is generically here because it can refer to atmosphere/dress
						:formal_dress_required => "Formal Dress Required",
						:smoking_permitted => "Smoking Permitted",
						# Menus
						:kids_menu => "Kids Menu",
						:senior_menu => "Senior Menu",
						# Money features
						:cash_only => "Cash Only"
	}
	PLACE_TYPES = {	:restaurant => "Restaurant",
					:bar => "Bar / Club",
					:theater => "Theater",
					:coffee_shop => "Coffee Shop",
					:store => "Store",
					:deli => "Deli",
					:bakery => "Bakery",
					:public_place => "Public Place",
					:other => "Other"
	}
	PLACE_PARKING = {	:own => "Own Parking Lot",
						:valet => "Valet Parking",
						:validated => "Validated Parking",
						:street => "Street Parking",
						:transit => "Public Transit Accessible",
						:no_local => "No Local Parking",
						:pay => "Pay Parking",
						:parallel => "Parallel Parking"
	}

	def initialize
		# Initialize default values.
		@address = ""
		@zipcode = 00000
		@phone_number = ""
		@website = ""
		@latitude = 0.0
		@longitude = 0.0
		@type = nil # should be a symbol
		@type_other = ""
		@features = []
		@flickr_photo_id = nil
	end

	# e.g. x = PlaceMetadata.from_hash({:address => "your mom"})
	def self.from_hash(hash)
		hash.each do |key,val|
			instance_variable_set("@#{key}", val) if respond_to?(key)
		end 
	end

	def self.get_place_types
		return PLACE_TYPES
	end

	def self.get_place_features
		return PLACE_FEATURES
	end
  
	# e.g. x[:address]
	def [](key)
		if instance_variables.include?("@#{key.to_s}")
			return instance_variable_get("@#{key.to_s}")
		else
			return nil
		end
	end

	# e.g. x[:address] = "123 any street"
	def []=(key, value)
		if instance_variables.include?("@#{key.to_s}")
			instance_variable_set("@#{key.to_s}", value)
			return self
		end
	end
    
	# e.g. x.to_hash => { :address => ... }
	def to_hash
		res = {}
		instance_variables.each do |var|
			var.sub!(/^@/,'')
			res[var] = instance_variable_get("@#{var}")
		end
		return res
	end

	# Returns a human version of the place type.
	def place_type_to_s
		return PLACE_TYPES[@type]
	end
end
