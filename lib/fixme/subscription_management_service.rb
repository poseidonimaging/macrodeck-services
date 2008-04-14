require 'payment/authorize_net'
require 'creditcard'
require 'digest/sha2'
require 'openssl'
require 'yaml'
require 'ArpApiLib'

# we will use SHA512 function
include Digest

# include own utils module
include Utils

# TODO: mask all raise calls! Create subscription's own exceptions. 

class SubscriptionManagementService < BaseService   
    
    STATUSPAID              = 10
    STATUSPAYMENTDUE        = 20
    STATUSSUSPEND           = 30
    STATUSCANCELED          = 40
    STATUSPARTIALPAYMENT    = 50

    API_LOGIN               = '4CuQ34ap'
    TRNS_KEY                = '6p23q4DE6DC9EVsx'
    API_URL                 = 'https://apitest.authorize.net/xml/v1/request.api'
         
    # Create/edit/delete subscriptions
    # Create/edit/delete subscription services (i.e. things that users can subscribe to) 
    def SubscriptionManagementService.createSubscriptionService(recurrence_info,sub_type,metadata,template)
        sub_service = SubscriptionService.new(metadata.to_hash)
        sub_service.uuid = UUIDService.generateUUID
        
        sub_service.creation = Time.now.to_i
        sub_service.creator = metadata[:creator]
        sub_service.creator = NOBODY unless sub_service.creator
        
        sub_service.recurrence_info = Recurrence.new(recurrence_info)
        
        sub_service.notify_template = template if template
        
        sub_service.subscription_type = sub_type
        sub_service.subscription_type = ONETIME_PAYMENT unless sub_service.subscription_type
                
        sub_service.save 
        
    end
    
    def SubscriptionManagementService.createSubscription(user_uuid, sub_service_uuid, billing_data, status)
        raise "User not found" unless User.checkUUID(user_uuid)
        raise "Subscription Service not found" unless SubscriptionService.checkUuid(user_uuid)
        sub = Subscription.new do
            self.creation = Time.new.to_i
            self.user_uuid = user_uuid
            self.sub_service_uuid = sub_service_uuid
            self.status = status
            self.updated = self.creation
            self.uuid = UUIDService.generateUUID
        end
        sub.save
        sub.uuid        
    end
    
    def SubscriptionManagementService.deleteSubscriptionService(uuid)
        sub_srv = SubscriptionService.find_by_uuid(uuid)
        raise_no_record(uuid) unless sub_srv
        if sub_srv.subscriptions.empty?
            sub_srv.destroy
        else
            raise "you must delete all subscription for this service before"
        end
    end
    
    def SubscriptionManagementService.deleteSubscription(uuid)
        sub = Subscription.find_by_uuid(uuid)
        raise_no_record(uuid,1)
        sub.destroy
    end

    def SubscriptionManagementService.editSubscriptionService(uuid,updated_attributes)
        sub_srv = SubscriptionService.find_by_uuid(uuid)
        raise_no_record(uuid) unless sub_srv
        sub_srv.update_attributes(updated_attributes)       
    end
    
    def SubscriptionManagementService.editSubscription(uuid,updated_attributes)
        sub = SubscriptionService.find_by_uuid(uuid)
        SubscriptionService.raise_no_record(uuid,1) unless sub
        sub.update_attributes(updated_attributes)       
    end
    
    def SubscriptionManagementService.makePayment(user_uuid, auth_data, amount, card_number, expiration)
        user = User.find_by_uuid(user_uuid)
        User.raise_no_record(uuid)
        
        # TODO: test and update this fragment
        transaction = Payment::AuthorizeNet.new(
          :login       => auth_data[:username],
          :password    => auth_data[:password],
          :amount      => amount,
          :card_number => card_number,
          :expiration  => expiration
        )
        begin
          transaction.submit
          
        rescue
          return false
        end
    end    
        
    def SubscriptionManagementService.makeRecurrencePayment(user_uuid, subscription_uuid, payment_info)
        user = User.checkUUID(user_uuid)        
        sub = Subscription.checkUUID(subscription_uuid)
        raise ArgumentError unless (subs & user)
        subname = sub.service.title
        interval = IntervalType.new(payment_info.length, payment_info.unit)
        schedule = PaymentScheduleType.new(interval, payment_info.start_date, payment_info.total_acc, payment_info.trial_acc)        
        cinfo = CreditCardType.new(payment_info.credit_card, payment_info.month)
        binfo = NameAndAddressType.new(payment_info.first_name,payment_info.last_name)
        xmlout = req.CreateSubscription(auth,subname,schedule,payment_info.amount, payment_info.trial_amount, cinfo,binfo)
        xmlresp = HttpTransport.TransmitRequest(xmlout, ARGV_0)
        aReq.ProcessResponse(xmlresp)       
    end  
    
    
    # TODO: Tests OK, but need to be processed
    def SubscriptionManagementService.decryptCard(subscription_uuid, last_four_digits,password)
        sub = Subscription.find_by_uuid(subscription_uuid)
        Subscription.raise_no_record(subscription_uuid) unless sub
        billing_data = YAML::load(sub.billing_data)
        digest = SHA512.hexdigest(billing_data[:entropy] + ":" + last_four_of_card + ":" + password)
        cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
        cipher.decrypt
        cipher.key = digest
        cipher.iv = billing_data[:iv]
        card_number = c.update(billing_data[:card_number])
        card_number << cipher.final
        checkCard(card_number)
    end
    
    # Include a method for seeing if a user is subscribed to a particular subscription service
    def SubscriptionManagementService.isUserSubscribedTo?(user_uuid, service_uuid)   
        sub = Subscription.check!(user_uuid, service_uuid)
        !sub.nil?
    end
    
    def SubscriptionManagementService.isUserPaidFor?(user_uuid,service_uuid)
        sub = Subscription.check!(user_uuid, service_uuid)
        billing_data = YAML::load(sub.billing_data)
        last_payment = SubscriptionPayment.lastPaymentFor(user_uuid,sub.uuid)
        {
          :status => sub.status,
          :debt =>billing_data[:debt],
          :last_payment_amount => last_payment.amount_paid,
          :last_payment_date => last_payment.human_payment_date
        }
    end
    
    # TODO: Write tests    
    def SubscriptionManagementService.changeSubscriptionPassword(user_uuid, last4, oldpassword,newpassword)
      subs = Subscription.by_user(user_uuid)
      subs.each {|sub|
          billing_data = YAML::load(sub.billing_data)
          card_number = SubscriptionManagementService.decryptCard(sub_uuid, last4,oldpassword)[:card_number]
          raise "wrong password" if !card_number
          raise "last 4 digits are incorrect" if last4.to_s !=card_number[card_number.length-4 .. card_number.length]          
      }
      subs.each {|sub|                    
          Subsciption.update_billing_data(
            sub.uuid,     # subscription uuid
            encryptCardForSubscription(
              card_number, #! plain credit card number
              sub.uuid,   # subscription uuid
              newpassword    # password
          ))    
      }
    end
    
    # XXX: Question: YAML or XML or something else?
    def SubscriptionManagementService.getInvoice(user_uuid,options={:selection=>'all'})
        user = User.check!(user_uuid)        
        with_history = options[:history]
        assign_when_undef(with_history,true) # Utils::assign_when_undef
        
        selection = options[:selection]
        if selection        
            case selection
                when 'sub'
                    sub = Subscription.check!(options[:sub_uuid])
                    raise "unknown subscription" unless sub
                    subscriptions = [sub]                    
                when 'multi'
                    subs_range = :multi                    
                    subscriptions = options[:subscriptions]
                    subscriptions.collect! {|sub_uuid|
                        Subscription.check!(sub_uuid)
                    }.compact
                when 'all'
                    subs_range = :all
                    subscriptions = Subscription.by_user(user_uuid)
                when 'sub_srv'
                    subscriptions = Subscription.check!(user_uuid, options[:sub_srv])
                when 'seller'
                    sub_srv = SubscriptionService.find_by_provider_uuid(options[:seller])
                    subscriptions = Subscription.check!(user_uuid, sub_srv.uuid)                    
                when 'group'
                # XXX: I'm unknown what is need to do in this case :-(
                # Probably we need to specify an responsible for each group.
            end
        else
            raise "You have to specify either seller or group or service or subscription"
        end
                
        report = Invoice.new(subscriptions,with_history)
                        
        report_type = options[:type]
        assign_when_undef(report_type,'hash')        
        case report_type
            when 'hash'
                return report.to_hash
            when 'xml'
                return report.to_xml
            when 'json'
                return report.to_json
            when 'yaml'
                return report.to_yaml
            when 'object'
                return report
        end
    end
    
    # use rubygem creditcard
    def SubscriptionManagementService.checkCard(card_number)
        {
          :card_number => card_number.creditcard? ? card_number.to_s : nil,
          :type => card_number.creditcard_type
        }
    end

    # guard time - days before payment due date to e-mail out notices that money is due   
    def SubscriptionManagementService.setGuardTimeForSubscription(sub_uuid,number_of_days)
        sub = Subscription.find_by_uuid(subscription_uuid)
        Subscription.raise_no_record(subscription_uuid)  unless sub
        Subscription.update_billing_data({:guard_time => number_of_days})    
    end
    
    private
    
    def SubscriptionManagementService.encryptCardNumber(card_number,password)        
        random_string_of_characters = (1..20).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
        card_number = card_number.to_s unless card_number.kind_of? String
        last4 = card_number[card_number.length-4 .. card_number.length]
        digest = SHA512.hexdigest(random_string_of_characters + ":" + last4 + ":" + password)
        cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
        cipher.encrypt
        cipher.key = digest
        cipher.iv = cipher.random_iv
        enc_card_number = cipher.final
        {
          :entropy => random_string_of_characters,
          :iv => cipher.iv,
          :card_number => cipher.final          
        }
    end    
        
end