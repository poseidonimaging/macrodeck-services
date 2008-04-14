class SubscriptionPayment < ActiveRecord::Base
  def human_payment_date
      Time.at(self.payment_date)
  end
  
  def get_history(user_uuid, sub_uuid) 
      find_all_by_user_uuid_and_subscription_uuid(user_uuid,sub_uuid, :select=>[:amount_paid,:date_paid])
  end
      
end
