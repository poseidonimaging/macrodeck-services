# This class represents a specific Place. 

require "places_service/place_metadata"

class Place < DataObject
	acts_as_macrodeck_wall
	acts_as_macrodeck_calendarable

	# Override the inspect method to give us something a bit more useful.
	def inspect
		return "#<Place:#{self.to_s}>"
	end

	# Take the place location info and return a string
	def to_s
		return self.name + ", " + self.city.name + ", " + self.city.state(:abbreviation => true)
	end

	# Returns effectively the parent.
	def city
		if self.parent.is_a?(City)
			return self.parent
		else
			raise "Place parent is not a city (#{self.uuid})"
		end
	end

	# Set's a place's metadata (but not the item's metadata). Can accept either a
	# PlaceMetadata object or a Hash with the same values.
	def place_metadata=(metadata = PlaceMetadata.new)
		if metadata.nil? || metadata.class == NilClass
			pmeta = PlaceMetadata.new
			self.extended_data = pmeta
		elsif metadata.class == PlaceMetadata
			self.extended_data = metadata
		elsif metadata.class == Hash
			pmeta = PlaceMetadata.from_hash(metadata)
			self.extended_data = pmeta
		else
			raise ArgumentError
		end
	end

	# Return the place's metadata as a PlaceMetadata object.
	def place_metadata
		return self.extended_data
	end

	# Alias for title, allows place.name
	def name
		return self.title
	end

	# FIXME: TEMPORARY USE ONLY
	def url_part
		return self.uuid
	end

	# Returns an array containing User objects of all of the patrons of this place, or else nil
	def patrons
		patron_list = Relationship.find(:all, :conditions => ["target_uuid = ? AND relationship = 'patron'", self.uuid])
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

	# Points at a view that can render this model
	def path_of_partial
		return "models/place"
	end

	# Returns a full URL to this model. Options:
	# :facebook		=> true | false
	# :action		=> a valid action
	# :place_action => (optional) a place-contextual action (XXX: Unused?)
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
		url << url_sanitize(self.parent.country) << "/"
		url << url_sanitize(self.parent.state(:abbreviation => true)) << "/"
		url << url_sanitize(self.parent.url_part) << "/"
		url << url_sanitize(self.url_part) << "/"
		if options[:place_action] != nil && options[:place_action] != ""
			url << "#{url_sanitize(options[:place_action].to_s)}/"
		end
		return url
	end
end
