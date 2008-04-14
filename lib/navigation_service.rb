# Provides linking functionality, including breadcrumbs.

require "navigation_service/breadcrumb"

class NavigationService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.NavigationService"
	@serviceName = "NavigationService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 3
	@serviceVersionRevision = 20080327
	@serviceUUID = "735eb870-de2b-42f0-9f13-56a00a02346b"
	
	# takes an array of Breadcrumb objects and renders it as a series of links.
	def self.render_breadcrumbs(breadcrumbs)
		html = ""
		breadcrumbs.each do |crumb|
			html << crumb.to_html
			html << " / "
		end
		return html
	end
end

# Register this service with Services.
Services.registerService(NavigationService)
