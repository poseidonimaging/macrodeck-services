class SubscriptionManagementServiceAPI < ActionWebService::API::Base
end

class SubscriptionWebService < ActionWebService::Base
	web_service_api SubscriptionManagementServiceAPI
	
end	

