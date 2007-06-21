require 'yaml'
require 'cl/xmlserial'

class Invoice
    include XmlSerialization
    
    attr_accessor :invoice_data
    
    def initialize(user,subscriptions,detail)
        @invoice_data = Array.new
        subscriptions.each {|sub|
            provider = sub.service.provider
            data = Hash.new
            data[:sub] = sub.uuid
            data[:seller_name] = provider.name
            data[:seller_email] = provider.email
            data[:purchaser_name] = user.name
            data[:purchaser_email] = user.email
            data[:sub_status] = sub.status
            data[:sub_created] = Time.at(sub.created).to_s
            data[:sub_due] = sub.billing_data[:amount]                
            if detail == :full
                history=SubscriptionPayment.get_history(user.uuid,sub.uuid)
                data[:history] = history
            end
            @invoice_data.push(data)
        }    
    end
    
    def to_hash
        i = 0
        res = Hash.new
        @invoice_data.each{ |inv|    
            res[i] = inv
        }
        res
    end
    
    def to_yaml
        @invoice_data.to_yaml
    end
    
    def to_xml
        self.to_xml
    end
    
    def to_json
        @invoice_data.to_json
    end
    
end
