# This controller provides /services/ and associated tidbits.

class ServicesController < ApplicationController
	wsdl_service_name "MacroDeck"
	wsdl_namespace "http://www.macrodeck.com/xmlns/services/1.0/"
	web_service_scaffold :index
	layout "default"
	
	web_service_dispatching_mode :delegated
	
	web_service :DataService, DataWebService.new
	web_service :UserService, UserWebService.new
end