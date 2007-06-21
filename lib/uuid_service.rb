# This service generates UUIDs for other services.
# It uses the Ruby Gem "uuidtools".

require_gem "uuidtools", ">= 1.0.0"

class UUIDService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.UUIDService"
	@serviceName = "UUIDService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 3
	@serviceVersionRevision = 20060705
	@serviceUUID = "05705b50-135a-489f-bbbd-a8fc7d38b643"
	
	# Returns a string containing a random UUID.
	def self.generateUUID()
		return UUID.random_create.to_s
	end
	
	# Looks up the uuid and returns a human readable
	# name. This searches users, groups, services, and
	# so on. *NOTE* It doesn't _actually_ look services
	# or anything other than users up yet.
	def self.lookupUUID(uuid)
		displayname = UserService.lookupUUID(uuid)
		if displayname != nil
			return displayname
		else
			# Didn't find a user or group, keep truckin'
			loadedServices = Services.getLoadedServices
			loadedServices.each do |service|
				if service[:uuid].downcase == uuid
					return service[:name]
				end
			end
			# Search Data Items, return data item title
			ditem = DataItem.find(:first, :conditions => ["dataid = ?", uuid])
			if ditem != nil
				return ditem.title
			else
				dgroup = DataGroup.find(:first, :conditions => ["groupingid = ?", uuid])
				if dgroup != nil
					return dgroup.title
				else
					ServicesModule::DefaultUUIDs::constants.each do |constant|
						if ServicesModule::DefaultUUIDs::const_get(constant) == uuid
							return constant.to_s
						end
					end
					ServicesModule::LocalUUIDs::constants.each do |constant|
						if ServicesModule::LocalUUIDs::const_get(constant) == uuid
							return constant.to_s
						end
					end
					# Sorry folks!
					return uuid
				end
			end
		end
	end
end

# Register this service with Services.
Services.registerService(UUIDService)