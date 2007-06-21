# This service provides the methods common to all services,
# such as versioning. It is loaded automatically when the
# Services framework loads.

class BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"	
	@serviceID = "com.macrodeck.BaseService"	
	@serviceName = "BaseService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 0
	@serviceVersionRevision = 0
	@serviceUUID = "78d71960-3387-4ea6-84ca-399d2f880469"

	# Returns the author(s) of this service.
	def self.serviceAuthor
		@serviceAuthor
	end
	
	# Returns the (Java-style) identifier of this service.
	def self.serviceID
		@serviceID
	end

	# Returns the CamelCase name of this service.
	def self.serviceName
		@serviceName
	end
	
	# Returns the major version number of this service (A in A.B.C).
	def self.serviceVersionMajor
		@serviceVersionMajor
	end
	
	# Returns the minor version number of this service (B in A.B.C).
	def self.serviceVersionMinor
		@serviceVersionMinor
	end
	
	# Returns the revision number of this service (C in A.B.C).
	def self.serviceVersionRevision
		@serviceVersionRevision
	end
	
	# Returns the UUID of the service (generate with Linux/Unix's `uuidgen` or Windows' GuidGen)
	def self.serviceUUID
		@serviceUUID
	end
	
end