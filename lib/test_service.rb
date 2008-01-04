# A very simple test service that doesn't do anything
# remotely useful other than let us know everything
# is working like it should.

class TestService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.TestService"
	@serviceName = "TestService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 2
	@serviceVersionRevision = 20060705
	@serviceUUID = "9de63d03-9a05-4514-9e8e-c829b090263c"
	
	# A simple function that returns a message letting the user know everything is A-OK :)
	def self.test()
		return true
	end
end

# Register this service with Services.
Services.registerService(TestService)