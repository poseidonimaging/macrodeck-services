# This model is used by UserService to interact
# with users in the database.

class User < ActiveRecord::Base
   # def User.checkUuid(uuid)
   #     !find_by_uuid(uuid).nil? rescue false
   # end
    
    # XXX: Is this name OK?
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
end