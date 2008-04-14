# This model is used by UserService to interact
# with users in the database. Requires RFacebook
# and ActiveRecord.

gem "rfacebook", ">= 0.9.3"

class User < ActiveRecord::Base
	acts_as_facebook_user

	before_validation :set_uuid_if_not_set

	has_many	:created_objects,	:class_name => "DataObject", :foreign_key => "created_by_id"
	has_many	:updated_objects,	:class_name => "DataObject", :foreign_key => "updated_by_id"
	has_many	:owned_objects,		:class_name => "DataObject", :foreign_key => "owned_by_id"

	validates_presence_of	:uuid
	validates_uniqueness_of	:uuid

	private
		# Sets the UUID if it's not already been assigned.
		def set_uuid_if_not_set
			if self.uuid == nil || self.uuid == ""
				self.uuid = UUIDService.generateUUID()
			end
			return true
		end
end
