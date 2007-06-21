# The DataWebService. Provides DataService functions to
# remote via ActionWebService.

# Error code constants

DATA_SERVICE_ERROR_OK							= 0
DATA_SERVICE_ERROR_INVALID_AUTHCODE				= 10
DATA_SERVICE_ERROR_NO_PERMISSION_TO_WRITE_ITEM	= 100
DATA_SERVICE_ERROR_NO_PERMISSION_TO_WRITE_GROUP	= 101

# Structs for DataWebService.
module DataServiceCustomTypes
	# Metadata for DataItems. Can be nil/null
	class ItemMetadata < ActionWebService::Struct
		# creator and owner are inferred by the current user and parent group/item
		member :dataType,		:string # UUID expected
		member :title,			:string
		member :description,	:string
		member :creatorApp,		:string # UUID expected
	end
	
	class GroupMetadata < ActionWebService::Struct
		member :groupType,		:string # UUID expected
		member :title,			:string
		member :description,	:string
	end
	
	class YAML < ActionWebService::Struct
		member :yamlContent,	:string
	end
	
	class ReturnUUID < ActionWebService::Struct
		member :errorCode,		:int
		member :uuid,			:string
	end
	
	class ItemData < ActionWebService::Struct
		member :stringData,		:string
		member :integerData,	:int
		member :objectData,		YAML
	end
	
	class Permissions < ActionWebService::Struct
		member :readPermissions,	YAML
		member :writePermissions,	YAML
	end
	
	class ReturnItem < ActionWebService::Struct
		member :uuid,			:string # UUID	
		member :dataType,		:string # UUID
		member :groupUUID,		:string # UUID
		member :creator,		:string # UUID
		member :owner,			:string # UUID
		member :creation,		:int # UNIX Time
		member :creatorApp,		:string # UUID
		member :tags,			:string
		member :title,			:string
		member :description,	:string
		member :data,			ItemData
		member :permissions,	Permissions
		member :isRemoteData,	:bool
		member :remoteSourceId,	:string # UUID
	end
	
	class ReturnGroup < ActionWebService::Struct
		member :uuid,			:string # UUID
		member :groupType,		:string # UUID
		member :creator,		:string # UUID
		member :owner,			:string # UUID
		member :tags,			:string
		member :parent,			:string # UUID
		member :title,			:string
		member :description,	:string
		member :permissions,	Permissions
		member :isRemoteData,	:bool
		member :remoteSourceId,	:string # UUID
		member :remoteSourcesIncluded, YAML
	end
end

# The DataService API definition
class DataServiceAPI < ActionWebService::API::Base
	# DataItem functions
	api_method :create_data_item, {
		:expects =>	[{ :authCode	=> :string },
					 { :groupUUID	=> :string },
					 { :metadata	=> DataServiceCustomTypes::ItemMetadata }],
		:returns => [{ :returnUUID	=> DataServiceCustomTypes::ReturnUUID }]
	}
	api_method :delete_data_item, {
		:expects =>	[{ :authCode	=> :string },
					 { :itemUUID	=> :string }],
		:returns => [:bool]
	}
	api_method :set_string_value, {
		:expects =>	[{ :authCode	=> :string },
					 { :itemUUID	=> :string },
					 { :value		=> :string }],
		:returns => [:bool]
	}
	api_method :delete_string_value, {
		:expects => [{ :authCode	=> :string },
					 { :itemUUID	=> :string }],
		:returns =>	[:bool]
	}
	api_method :set_integer_value, {
		:expects =>	[{ :authCode	=> :string },
					 { :itemUUID	=> :string },
					 { :value		=> :int }],
		:returns => [:bool]
	}
	api_method :delete_integer_value, {
		:expects => [{ :authCode	=> :string },
					 { :itemUUID	=> :string }],
		:returns =>	[:bool]
	}
	api_method :set_object_value, {
		:expects =>	[{ :authCode	=> :string },
					 { :itemUUID	=> :string },
					 { :value		=> DataServiceCustomTypes::YAML }],
		:returns => [:bool]
	}
	api_method :delete_object_value, {
		:expects => [{ :authCode	=> :string },
					 { :itemUUID	=> :string }],
		:returns =>	[:bool]
	}
	# DataGroup functions
	api_method :create_data_group, {
		:expects => [{ :authCode	=> :string },
					 { :parent		=> :string },
					 { :metadata	=> DataServiceCustomTypes::GroupMetadata }],
		:returns => [{ :returnUUID	=> DataServiceCustomTypes::ReturnUUID }]
	}
	api_method :delete_data_group, {
		:expects => [{ :authCode		=> :string },
					 { :groupUUID		=> :string }],
		:returns => [:bool]
	}
	# Listing functions
	api_method :get_data_items, {
		:expects => [{ :authCode	=> :string },
					 { :groupUUID	=> :string }],
		:returns => [{ :items		=> [DataServiceCustomTypes::ReturnItem] }]
	}
	api_method :get_data_groups, {
		:expects => [{ :authCode	=> :string },
					 { :groupUUID	=> :string }],
		:returns => [{ :groups		=> [DataServiceCustomTypes::ReturnGroup] }]
	}
	# Metadata functions
	api_method :get_data_item_metadata, {
		:expects => [{ :authCode	=> :string },
					 { :itemUUID	=> :string },
					 { :mdProperty	=> :string }],
		:returns => [{ :mdValue		=> :string }]
	}
	api_method :get_data_group_metadata, {
		:expects => [{ :authCode	=> :string },
					 { :groupUUID	=> :string },
					 { :mdProperty	=> :string }],
		:returns => [{ :mdValue		=> :string }]
	}
	api_method :set_data_item_metadata, {
		:expects => [{ :authCode	=> :string },
					 { :itemUUID	=> :string },
					 { :mdProperty	=> :string },
					 { :mdValue		=> :string }],
		:returns => [:bool]
	}
	api_method :set_data_group_metadata, {
		:expects => [{ :authCode	=> :string },
					 { :groupUUID	=> :string },
					 { :mdProperty	=> :string },
					 { :mdValue		=> :string }],
		:returns => [:bool]
	}	
end

# The Data Web Service. Provides SOAP/XML-RPC for DataService.
# The user's authCode must be specified in every function that
# requires it. In MacroDeck, we'll provide widgets with the
# authCode via a JavaScript variable (probably something like
# CurrentUser.authCode). In your app, you will probably need to
# provide the user with a copy-and-pastable authCode if you want
# to be able to use these APIs.
class DataWebService < ActionWebService::Base
	web_service_api DataServiceAPI
	
	# Creates a data item but does not populate it with data.
	# A groupUUID for the data must exist. Returns the UUID
	# of the data item or nil/null if failure.
	def create_data_item_OLD(authCode, groupUUID, metadata)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			# The user exists! Hooray!
			# Now we check to make sure they have permission to write to this groupUUID.
			if DataService.canWrite?(groupUUID, user.uuid)
				# They can write, create the data!
				group_md = DataService.getDataGroupMetadata(groupUUID)
				if metadata[:title] == ""
					title = nil
				else
					title = metadata[:title]
				end
				if metadata[:description] == ""
					description = nil
				else
					description = metadata[:description]
				end
				if metadata[:creatorApp] == ""
					creatorapp = nil
				else
					creatorapp = metadata[:creatorApp]
				end
				uuid = DataService.createData(metadata[:dataType], :nothing, nil, { :creator => user.uuid, :owner => group_md[:owner], :title => title, :description => description, :creatorapp => creatorapp, :grouping => groupUUID })
				return { :errorCode => DATA_SERVICE_ERROR_OK, :uuid => uuid }
			else
				return { :errorCode => DATA_SERVICE_ERROR_NO_PERMISSION_TO_WRITE_ITEM, :uuid => nil }
			end
		else
			return { :errorCode => DATA_SERVICE_ERROR_INVALID_AUTHCODE, :uuid => nil }
		end
	end

	def create_data_item(authCode, groupUUID, objMeta)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			# The user exists! Hooray!
			# Now we check to make sure they have permission to write to this groupUUID.
			if DataService.canWrite?(groupUUID, user.uuid)
				# They can write, create the data!
				group_md = DataService.getDataGroupMetadata(groupUUID)
				new_meta = Metadata.new do |m|
    				m.title = objMeta.title == "" ? nil : objMeta.title
    				m.description = objMeta.description == "" ? nil : objMeta.description
    				m.datacreator = objMeta.datacreator == "" ? nil : objMeta.datacreator
    				m.creator = user.uuid
    				m.owner = group_md.owner
    				m.grouping = groupUUID
    				m.type = objMeta.type				
				end

				uuid = DataService.createData(:nothing, nil, objMeta)
				return { :errorCode => DATA_SERVICE_ERROR_OK, :uuid => uuid }
			else
				return { :errorCode => DATA_SERVICE_ERROR_NO_PERMISSION_TO_WRITE_ITEM, :uuid => nil }
			end
		else
			return { :errorCode => DATA_SERVICE_ERROR_INVALID_AUTHCODE, :uuid => nil }
		end
	end
	
	# Deletes a data item and all associated data and
	# metadata.
	def delete_data_item(authCode, itemUUID)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				result = DataService.deleteDataItem(itemUUID)
				return result
			else
				return false
			end
		else
			return false
		end	
	end
	
	# Sets a string value on an existing data item. Returns
	# true if all is okay otherwise false.
	def set_string_value(authCode, itemUUID, value)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				result = DataService.modifyDataItem(itemUUID, :string, value)
				return result
			else
				return false
			end
		else
			return false
		end	
	end
	
	# Deletes the string value of a data item. Returns true
	# if all is good, otherwise false.
	def delete_string_value(authCode, itemUUID)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				result = DataService.modifyDataItem(itemUUID, :string, nil)
				return result
			else
				return false
			end
		else
			return false
		end		
	end
	
	# Sets an integer value on an existing data item. Returns
	# true if all is okay otherwise false.
	def set_integer_value(authCode, itemUUID, value)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				result = DataService.modifyDataItem(itemUUID, :integer, value)
				return result
			else
				return false
			end
		else
			return false
		end	
	end
	
	# Deletes the integer value of a data item. Returns true
	# if all is good, otherwise false.
	def delete_integer_value(authCode, itemUUID)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				result = DataService.modifyDataItem(itemUUID, :integer, nil)
				return result
			else
				return false
			end
		else
			return false
		end		
	end
	
	# Sets an object value on an existing data item. Returns
	# true if all is okay otherwise false. Expects the object
	# to be specified as YAML.
	def set_object_value(authCode, itemUUID, value)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				# This will load the YAML into an object so that
				# partially malformed YAML is inserted correctly.
				obj = YAML::load(value[:yamlContent])
				result = DataService.modifyDataItem(itemUUID, :object, obj)
				return result
			else
				return false
			end
		else
			return false
		end	
	end
	
	# Deletes the object value of a data item. Returns true
	# if all is good, otherwise false.
	def delete_object_value(authCode, itemUUID)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(itemUUID, user.uuid)
				result = DataService.modifyDataItem(itemUUID, :object, nil)
				return result
			else
				return false
			end
		else
			return false
		end		
	end
	
	# Creates a data group that should be populated with data items. +parent+
	# is optional and can be nil/null. Returns a fresh UUID if successful.
	def create_data_group_old(authCode, parent, metadata)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			# The user exists! Hooray!
			
			# If: 1) No parent was specified, or 2) A parent was specified and they can write to it,
			# Then: They can get in.
			if (parent != nil && DataService.canWrite?(parent, user.uuid)) || (parent == nil)
				# They can write, create the data!
				if parent != nil
					parent_md = DataService.getDataGroupMetadata(parent)
					owner = parent_md[:owner]
				else
					owner = user.uuid
				end
				if metadata[:title] == ""
					title = nil
				else
					title = metadata[:title]
				end
				if metadata[:description] == ""
					description = nil
				else
					description = metadata[:description]
				end
				uuid = DataService.createDataGroup(metadata[:groupType], nil, parent, { :creator => user.uuid, :owner => owner, :title => title, :description => description})
				return { :errorCode => DATA_SERVICE_ERROR_OK, :uuid => uuid }
			else
				return { :errorCode => DATA_SERVICE_ERROR_NO_PERMISSION_TO_WRITE_GROUP, :uuid => nil }
			end
		else
			return { :errorCode => DATA_SERVICE_ERROR_INVALID_AUTHCODE, :uuid => nil }
		end
	end

	def create_data_group(authCode, parent, objMeta)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			# The user exists! Hooray!
			
			# If: 1) No parent was specified, or 2) A parent was specified and they can write to it,
			# Then: They can get in.
			if (parent != nil && DataService.canWrite?(parent, user.uuid)) || (parent == nil)
				# They can write, create the data!
				if parent != nil
					parent_md = DataService.getDataGroupMetadata(parent)
					owner = parent_md.owner
				else
					owner = user.uuid
				end				
				new_meta = Metadata.new do |m|
    				m.title = objMeta.title == "" ? nil : objMeta.title
    				m.description = objMeta.description == "" ? nil : objMeta.description
    				m.datacreator = objMeta.datacreator == "" ? nil : objMeta.datacreator
    				m.creator = user.uuid
    				m.owner = owner
    				m.type = objMeta.type				
				end
				
				uuid = DataService.createDataGroup(nil, parent, objMeta)
				return { :errorCode => DATA_SERVICE_ERROR_OK, :uuid => uuid }
			else
				return { :errorCode => DATA_SERVICE_ERROR_NO_PERMISSION_TO_WRITE_GROUP, :uuid => nil }
			end
		else
			return { :errorCode => DATA_SERVICE_ERROR_INVALID_AUTHCODE, :uuid => nil }
		end
	end
	
	# Deletes a data group. Leaves orphan data items!
	def delete_data_group(authCode, groupUUID)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if DataService.canWrite?(groupUUID, user.uuid)
				result = DataService.deleteDataGroup(groupUUID)
				return result
			else
				return false
			end
		else
			return false
		end	
	end
	
	# Gets all or some of the data items for a particular user.
	# +groupUUID+ is optional; if nil/null is passed in, we will
	# return ALL data items.
	def get_data_items(authCode, groupUUID)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			if groupUUID != nil && groupUUID != ""
				items = DataItem.find(:all, :conditions => ["grouping = ? AND (creator = ? OR owner = ?)", groupUUID, user.uuid, user.uuid])
			else
				items = DataItem.find(:all, :conditions => ["creator = ? OR owner = ?", user.uuid, user.uuid])
			end
			data_items = Array.new
			items.each do |item|
				# Initialize the return object
				retval = DataServiceCustomTypes::ReturnItem.new
				retval.data = DataServiceCustomTypes::ItemData.new
				retval.data.objectData = DataServiceCustomTypes::YAML.new
				retval.permissions = DataServiceCustomTypes::Permissions.new
				retval.permissions.readPermissions = DataServiceCustomTypes::YAML.new
				retval.permissions.writePermissions = DataServiceCustomTypes::YAML.new
				# Okay, now set the values to the ones from the data items.
				retval.uuid = item.dataid
				retval.dataType = item.datatype
				retval.groupUUID = item.grouping
				retval.creator = item.creator
				retval.owner = item.owner
				retval.creation = item.creation
				retval.creatorApp = item.datacreator
				retval.tags = item.tags
				retval.title = item.title
				retval.description = item.description
				retval.data.integerData = item.integerdata
				retval.data.stringData = item.stringdata
				retval.data.objectData.yamlContent = item.objectdata
				retval.permissions.readPermissions.yamlContent = item.read_permissions
				retval.permissions.writePermissions.yamlContent = item.write_permissions
				retval.isRemoteData = item.remote_data
				retval.remoteSourceId = item.sourceid
				data_items << retval
			end
			return data_items
		else
			return nil
		end
	end
	# Gets all of the data groups for a particular user
	def get_data_groups(authCode)
		user = UserService.userFromAuthCode(authCode)
		if user != nil
			groups = DataGroup.find(:all, :conditions => ["creator = ? OR owner = ?", user.uuid, user.uuid])
			data_groups = Array.new
			groups.each do |group|
				# Initialize the return object
				retval = DataServiceCustomTypes::ReturnGroup.new
				retval.permissions = DataServiceCustomTypes::Permissions.new
				retval.permissions.readPermissions = DataServiceCustomTypes::YAML.new
				retval.permissions.writePermissions = DataServiceCustomTypes::YAML.new
				retval.remoteSourcesIncluded = DataServiceCustomTypes::YAML.new
				# Okay, now set the values to the ones from the data items.
				retval.uuid = group.groupingid
				retval.groupType = group.groupingtype
				retval.creator = group.creator
				retval.owner = group.owner
				retval.tags = group.tags
				retval.title = group.title
				retval.description = group.description
				retval.permissions.readPermissions.yamlContent = group.read_permissions
				retval.permissions.writePermissions.yamlContent = group.write_permissions
				retval.isRemoteData = group.remote_data
				retval.remoteSourceId = group.sourceid
				retval.remoteSourcesIncluded.yamlContent = group.include_sources
				data_groups << retval
			end
			return data_groups
		else
			return nil
		end
	end	
end