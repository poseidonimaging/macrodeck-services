# There's nothing that needs to be done really so this doesn't do anything yet.

require "wall_service/comments"
require "wall_service/comment"
require "wall_service/acts_as_macrodeck_wall"

class WallService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.WallService"
	@serviceName = "WallService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 3
	@serviceVersionRevision = 20100109
	@serviceUUID = "880c9dea-9b92-4ffe-a049-d10a095bb0d3"
end

# Register this service with Services.
Services.registerService(WallService)
