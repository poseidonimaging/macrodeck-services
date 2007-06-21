# This file is a stub for Rails so it loads our
# "real" library.

require "services"
require "acts_as_ferret"
#require "rubygems"
#require_gem "activemerchant"

class ActiveRecord::Base

  def self.checkUUID(uuid)
    #puts self.to_s 
    #puts uuid    
    case self.to_s
      when 'ForumPost','ForumReply','Forum','ForumCategory','ForumBoard':         
        obj = find_by_uuid(uuid)
        return nil unless obj
        return obj.grouping == self::UUID ? obj : false 
      
      when 'DataItem':
        return find_by_dataid(uuid)
      when 'DataGroup', 'Profile':               
        find_by_groupingid(uuid)
      else 
        return nil        
    end
  end
  
end

# This is a method from Ruby Cookbook. It initializes the instance variables for us.
# 
# MOVED TO METADATA CLASS
#  
#class Object
#  private
#  def Object.set_instance_variables(binding, *variables)
#    variables.each do |var|
#      instance_variable_set("@#{var}", eval(var, binding))
#    end
#  end
#end

#module ActiveMerchant
#  module Billing
#    class AuthorizeNetGateway < Gateway
#      ARB_LIVE_URL = "https://api.authorize.net/xml/v1/request.api"
#      ARB_TEST_URL = "https://apitest.authorize.net/xml/v1/request.api"
#          
#      def arb_commit(api_login, trns_key, options)
#        
#      end
#      
#      def add_subscription(request,options)        
#      end
#      
#      def add_payment(request,options)
#      end
#      
#      def 
#             
#    end
#  end
#end
#    end
