# This file contains all of the default permissions.
# Pretty much just the default read and write permssions,
# actually. In the future there might be default permissions
# based on data type. But not yet.

module ServicesModule
	module DefaultPermissions
		DEFAULT_READ_PERMISSIONS	= [{ :id => "everybody", :action => :allow }]
		DEFAULT_WRITE_PERMISSIONS	= [{ :id => "everybody", :action => :deny  }]
	end
end