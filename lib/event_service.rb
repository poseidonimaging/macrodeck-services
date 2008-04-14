# Handles all event creation and stuff (mainly just here as a way to include Calendar/Event)

gem "chronic"
require 'chronic'

require 'event_service/calendar'
require 'event_service/event'
require 'event_service/acts_as_macrodeck_calendarable'
require 'event_service/time_extensions'

class EventService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.EventService"
	@serviceName = "EventService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 3
	@serviceVersionRevision = 20080410
	@serviceUUID = "c60e27de-b320-4822-aa06-a3060c6e5648"

	def self.parse_time(time)
		t = Chronic.parse(time.to_s.strip.chomp.downcase.gsub("at 0", "at ").gsub(",", ""))
		puts "EventService#parse_time: in: #{time} out: #{t}"
		return t
	end
end

# Register this service with Services.
Services.registerService(EventService)
