# This model is used by UserService to interact
# with users in the database. Requires RFacebook
# and ActiveRecord.

gem "rfacebook", ">= 0.9.3"

class User < ActiveRecord::Base
#	acts_as_facebook_user

	before_validation :set_uuid_if_not_set

	has_many	:created_objects,	:class_name => "DataObject", :foreign_key => "created_by_id"
	has_many	:updated_objects,	:class_name => "DataObject", :foreign_key => "updated_by_id"
	has_many	:owned_objects,		:class_name => "DataObject", :foreign_key => "owned_by_id"

	has_and_belongs_to_many	:friends,	:class_name => "User", :foreign_key => "friend_id", :join_table => "friends"

	validates_presence_of	:uuid
	validates_uniqueness_of	:uuid

	# Returns an array of places that this user patronizes
	def places_patronized
		places = []
		place_rels = Relationship.find(:all, :conditions => ["source_uuid = ? AND relationship = 'patron'", self.uuid])
		if place_rels
			place_rels.each do |rel|
				place = Place.find_by_uuid(rel.target_uuid)
				places << place unless place.nil?
			end
		end
		return places
	end

	# Returns a City if the user has a home city, else nil
	def home_city
		hcity_rel = Relationship.find(:first, :conditions => ["source_uuid = ? AND relationship = 'home_city'", self.uuid])
		if hcity_rel
			return City.find_by_uuid(hcity_rel.target_uuid)
		end
	end

	# Returns a City if the user has a secondary city, else nil
	def secondary_city
		scity_rel = Relationship.find(:first, :conditions => ["source_uuid = ? AND relationship = 'secondary_city'", self.uuid])
		if scity_rel
			return City.find_by_uuid(scity_rel.target_uuid)
		end
	end

	private
		# Sets the UUID if it's not already been assigned.
		def set_uuid_if_not_set
			if self.uuid == nil || self.uuid == ""
				self.uuid = UUIDService.generateUUID()
			end
			return true
		end
end
