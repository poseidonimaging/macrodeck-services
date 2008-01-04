# This model is used by UserService to interact
# with users in the database. Requires RFacebook
# and ActiveRecord.

gem "rfacebook", ">= 0.9.3"

class User < ActiveRecord::Base
	acts_as_facebook_user
	before_create :set_creation, :set_uuid_if_not_set

    # XXX: Is this name OK?
	# The intention of this method looks like a way to get a User by UUID. I doubt it actually
	# works. And for the love of God people - stop using shortcuts. I know what user ? user : nil
	# does, but it's not the Ruby way to make it not readable. It can be more easily read like this:
	# if user
	#	return user
	# else
	#	return nil
	# end
    def User.check!(uuid)
        user = find_by_uuid(uuid)
        user ? user : nil
    end

	# return all user's subscriptions.
    # Example:
    #   user = User.check!(joe_uuid)
    #   user.subscriptions.each { |sub|
    #       line = String.new
    #       line << Time.at(sub.created).to_s
    #       line << " " <<  sub.service.description
    #       line << " " << sub.
    #       puts Time.at(sub.created).to_s + " " + sub.service.description + " " + 
    #   }
    def subscriptions
        Subscription.by_user(self.uuid)
    end 
    
    def raise_no_record(id)
        raise ActiveRecord::RecordNotFound, "Can't find User with UUID: " + id
    end

	private
		# Sets the creation when an item is created
		def set_creation
			self.creation = Time.new.to_i
			return true
	    end

		# Sets the UUID if it's not already been assigned.
		def set_uuid_if_not_set
			if self.uuid == nil || self.uuid == ""
				self.uuid = UUIDService.generateUUID()
			end
			return true
		end
end
