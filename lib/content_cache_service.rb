require "content_cache_service/html_part"

class ContentCacheService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.ContentCacheService"
	@serviceName = "ContentCacheService"
	@serviceVersionMajor = 0
	@serviceVersionMinor = 3
	@serviceVersionRevision = 20090409
	@serviceUUID = "78a36533-dfe2-4abf-9927-d2ebd7018346"
end

# Register this service with Services.
Services.registerService(ContentCacheService)

