
require 'yaml'

class StorageService < BaseService
    
	@serviceAuthor = "Eugene Hlyzov <ehlyzov@issart.com>"
	@serviceID = "com.macrodeck.StorageService"
	@serviceName = "StorageService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 1	
    @serviceUUID = "748fd45d-cd96-41a5-ab9c-6324ad6aedbb"    
    
    # Creates a file (of course, folder is a file too)
    # +type+ is a symbol, may be :file or :folder for now
    # Example: 
    #   StorageService.createFile(:file, my_text, my_storage, {:owner => ...})
    #   StorageService.createFile(:folder, nil, main.storage, {:owner => ...})
    def StorageService.createFile(type, data, parent, metadata=nil)
        storage = Storage.new        
        if metadata
            storage.creator = metadata[:creator]
			storage.creatorapp = metadata[:creatorapp]
			storage.description = metadata[:description]
			# creator is owner by default
			storage.owner = metadata[:owner] ? metadata[:owner] : storage.creator
			storage.tags = metadata[:tags]
			storage.title = metadata[:title]
        end
        case type
            when :folder, 'folder'
                storage.objectid = UUIDService.generateUUID
                storage.objecttype = STYPE_FOLDER
                storage.parent = parent unless parent.nil?
            when :file, 'file'
                storage.objectid = UUIDService.generateUUID
                storage.objecttype = STYPE_FILE
                storage.data = data
                storage.parent = parent unless parent.nil?
            else
                raise "invalid argument"
        end

		parent = storage.parentObject
		if parent != nil
			if parent.read_permissions != nil
				read_perms = YAML::load(parent.read_permissions)
			else
				read_perms = DEFAULT_READ_PERMISSIONS
			end
			if parent.write_permissions != nil
				write_perms = YAML::load(parent.write_permissions)
			else
				write_perms = DEFAULT_WRITE_PERMISSIONS
			end
		else
			read_perms = DEFAULT_READ_PERMISSIONS
			write_perms = DEFAULT_WRITE_PERMISSIONS
		end
		storage.read_permissions = read_perms       
		storage.write_permissions = write_perms
		storage.save!
		return storage.objectid       		
    end

    # links file to specified folder
    # Example:
    #   StorageService.linkFileToFolder(my_folder,my_file)
    def StorageService.linkFileToFolder(folder_id,file_id, user_or_group_id = NOBODY)
        file = Storage.find_by_objectid(file_id)
        raise_no_record(file_id) unless file
        file.parent= folder_id
        file.save        
        
#        quota = Quota.find_by_storageid_and_objectid(folder_id,user_or_group_id)
#        if quota
#            if file.size 
#        else
#        
#        end
   
    end
    
    # Adds a specify tag to the file
    # Example:
    #   StorageService.addTagToFile(some_file, 'SCORESHEET')
    def StorageService.addTagToFile(file_id, tag)
    end

    # Modifies the file metadata. Second param is a hash or Metadata object.
    def StorageService.modifyFileMetadata(file_id, metadata)
        file = Storage.find_by_objectid(file_id)
        raise_no_record(file_id) unless file
        if metadata.instance_of? Metadata
            file.update_attribute(metadata.to_hash)
        else
            metadata.each { |name, value|            
                if file.has_attribute?(name)
                    file.update_attribute(name,value)
                else 
                    raise ArgumentError, "can't update attribute: " + name.to_s                
                end
            }
        end
    end
    
    # Modifies the file metadata by specified +name+. 
    # This is a just proxy to modifyFileMetadata method
    def StorageService.modifyFileMetadataByName(file_id, name, value)
        return modifyFileMetadata(file_id,Hash[name,value])
    end

    # Renames the file
    # Example:
    #   StorageService.renameFile(some_file, "me.jpg")
    def StorageService.renameFile(file_id, file_name)
        StorageService.modifyFileMetadataByName(file_id,"title",file_name)
    end
    
    # Deletes the file
    def StorageService.deleteFile(file_id)
        file = Storage.find_by_objectid(file_id)
        if file
            folder = file.parentObject
            folder.data = (folder.size - file.size).to_s if folder
            file.destroy
        end
    end

    # Gets folder contents. Result is an array of hashes
    # +level+ is a level of the scan, it is 1 by default
    # (i.e. we are looking only )
    # Example:
    #   StorageService.getFolderContents(my_folder)
    #   => [
    #         {:id => 1, :name => "me.jpg", ...},
    #         {:id => 2, :name => "the_sun.jpg", ...},
    #         {:id => 3, :name => "after_the_rain.png", ...}
    #      ]
    #   
    def StorageService.getFolderContents(folder_id, level = 1)        
        objects = Storage.find_all_by_parent(folder_id)
        raise_no_record(folder_id) unless objects
        result = Array.new
        ## XXX: Recursion! 
        objects.each { |storage|
            if storage.objecttype == STYPE_FOLDER
                result.push(StorageService.getFolderContents(storage.objectid,level-1))
            else
                result.push(storage.attributes)
            end
        }
        result            
    end

    # Manages with file's quotas.
    # Quota is a hash with several params (:max_file_size, :total_size)
    # Example:
    #   StorageService.setupQuotas(my_storage, friends, {:max_file_size => "2Mb", ...})
    #   StorageService.setupQuotas(my_storage, friends, {}) # removes friends quota

##    def StorageService.setupQuotas(file_id, user_or_group_id, quota = {})
##        begin
##            storage = Storage.find_by_storageid(file_id)
##        rescue ActiveRecord::RecordNotFound => e
##            logger.info e.message
##            return false
##        end
##        raise "quota must be a instance of Hash class" unless quota.instance_of? Hash
##        quotas = YAML::load(storage.quotas)
##        if quota.empty?
##            quotas.delete_if {|key, value| key == user_or_group_id}
##        else
##            quotas.update(quota)
##        end
##        quotas_yaml = YAML::dump(quotas)
##        storage.quotas = quotas_yaml        
##        storage.save!
##    end    
  
    # new version (where we using additional table to store quotas)
    def StorageService.setupQuotas(file_id, user_or_group_id, quota = {})
        storage = Storage.find_by_objectid(file_id)
        raise_no_record(folder_id) unless storage
        storage_quota = Quota.find_or_create_by_storageid_and_objectid(file_id,user_or_group_id)
        storage_quota.limitations=quota
        storage_quota.save    
        return true
    end

    # returm netadata for existing storage
    def StorageService.getFileMetadata(file_id)
        storage = Storage.find_by_objectid(file_id)
        raise_no_record(folder_id) unless storage
        meta = Metadata.new
        meta.fetch(storage)
        return meta
    end
    
    def StorageService.getFileData(file_id)
        file = Storage.find_file(file_id)
        raise "Can't find file with UUID: " + file_id.to_s unless file
        file.data
    end

    private
    
    def StorageService.raise_no_record(id)
        raise ActiveRecord::RecordNotFound, "Can't find file with UUID: " + id
    end
        
end
Services.registerService(StorageService)
