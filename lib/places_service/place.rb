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

	# Returns a hash that looks like this:
	# { :likes => [ User, User, User, ... ], :dislikes => [ User, User, User, ... ] }
	def ratings
		rating_list = Relationship.find(:all, :conditions => ["target_uuid = ? AND (relationship = 'like' OR relationship = 'dislike')", self.uuid])
		rating_hash = { :likes => [], :dislikes => []}
		if rating_list != nil && rating_list.length > 0
			rating_list.each do |r|
				user = User.find_by_uuid(r.source_uuid)
				if user != nil
					if r.relationship == "like"
						rating_hash[:likes] << user
					elsif r.relationship == "dislike"
						rating_hash[:dislikes] << user
					end
				end
			end
		end
		return rating_hash
	end

	# Returns a numerical (0..100) rating of this place.
	def rating
		all_ratings = self.ratings
		num_likes = all_ratings[:likes].length.to_f
		num_dislikes = all_ratings[:dislikes].length.to_f

		# prevent divide by 0
		if num_likes > 0 && num_dislikes > 0
			# This formula is as follows:
			# weighted_likes - weighted_dislikes     100
			# ----------------------------------  X  ---
			#          weighted_likes                 1
			#
			# Currently, dislikes are weighted at 75% of their base value and likes are 50% of their base value.
			return ( ( ( num_likes * 0.5 - num_dislikes * 0.75 ) / ( num_dislikes * 0.5 ) ) * 100.0 )
		elsif num_likes > 0 && num_dislikes == 0
			return 100.0
		else
			return 0.0
		end
	end

	# Returns a hash that looks like this:
	# { :good => [ User, User, User, ... ], :bad => [ User, User, User, ... ] }
	def experiences
		experience_list = Relationship.find(:all, :conditions => ["target_uuid = ? AND relationship IN ('good_experience','bad_experience')", self.uuid])
		experience_hash = { :good => [], :bad => []}
		if experience_list != nil && experience_list.length > 0
			experience_list.each do |r|
				if r.relationship == "good_experience"
					experience_hash[:good] << r
				elsif r.relationship == "bad_experience"
					experience_hash[:bad] << r
				end
			end
		end
		return experience_hash
	end

	# Returns a numerical (0..100) experience level of this place.
	def experience
		all_experiences = self.experiences
		num_good = all_experiences[:good].length.to_f
		num_bad = all_experiences[:bad].length.to_f

		# prevent divide by 0
		if num_good > 0 && num_bad > 0
			# this is a simple number of good out of total. Time needs to be taken into account however.
			return (num_good / num_good + num_bad) * 100.0
		elsif num_good > 0 && num_bad == 0
			return 100.0
		else
			return 0.0
		end
	end

	# Returns an array of experiences for the sparkline generator. 0 = bad, 50 = neutral, 100 = positive.
	def experience_for_sparklines
		experience_list = Relationship.find(:all, :conditions => ["target_uuid = ? AND relationship IN ('good_experience', 'bad_experience')", self.uuid], :order => "updated_at DESC", :limit => 25)
		experience_sparklines = []
		experience_list.each do |e|
			if e.relationship == "good_experience"
				experience_sparklines << 100
			elsif e.relationship == "bad_experience"
				experience_sparklines << 0
			end
		end
		return experience_sparklines.reverse
	end

	# Returns an array of ratings for the sparkline generator. 0 = bad, 50 = neutral, 100 = positive.
	def rating_for_sparklines
		rating_list = Relationship.find(:all, :conditions => ["target_uuid = ? AND relationship IN ('like', 'dislike')", self.uuid], :order => "updated_at DESC", :limit => 25)
		rating_sparklines = []
		rating_list.each do |r|
			if r.relationship == "like"
				rating_sparklines << 100
			elsif r.relationship == "dislike"
				rating_sparklines << 0
			end
		end
		return rating_sparklines.reverse
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
