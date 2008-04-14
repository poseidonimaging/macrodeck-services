class Recurrence
    attr_reader :recurrence, :recurrence_day, :recurrence_notify
    def initialize(init_hash)
        @recurrence = init_hash[:recurrence]
        @recurrence_day = init_hash[:recurrence_day]
        @recurrence_notify = init_hash[:recurrence_notify]
    end
end

class SubscriptionService < ActiveRecord::Base
  composed_of :recurrence_info,
              :name => Recurrence,
              :mapping =>
                [ %w(recurrence recurrence),
                  %w(recurrence_day recurrence_day),
                  %w(recurrence_notify recurrence_notify)
                ]
  acts_as_ferret :fields => [:description, :title] 
                  
  # analog of has_many but it's using uuid field instead id
  def subscriptions
      Subscription.find_all_by_sub_service_uuid(self.uuid)
  end
  
  def SubscriptionService.checkUuid(uuid)  
      !find_by_uuid(uuid).nil? rescue false
  end  
  
  def SubscriptionService.check!(uuid)
      find_by_uuid(uuid)
  end
  
  def SubscriptionService.subscribed_by(user_uuid)
      Subscription.find_all
  end
  
  def raise_no_record(id)
      raise ActiveRecord::RecordNotFound, "Can't find subscription service with UUID: " + id
  end
end
