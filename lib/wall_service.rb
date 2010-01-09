# There's nothing that needs to be done really so this doesn't do anything yet.

require "comment_service/comments"
require "comment_service/comment"
require "comment_service/acts_as_macrodeck_wall"

class CommentService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.CommentService"
	@serviceName = "CommentService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 3
	@serviceVersionRevision = 20080317
	@serviceUUID = "880c9dea-9b92-4ffe-a049-d10a095bb0d3"
end

# Register this service with Services.
Services.registerService(CommentService)
