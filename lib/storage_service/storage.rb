
class Storage < ActiveRecord::Base
     # validates_presence_of :creator, :title
    
    acts_as_ferret :fields => [:tags, :description, :title] 
    
     # write time of storage's creation to updated field
    def after_create
        updated = Time.new.to_i
    end

    # write time of storage's update to updated field
    def after_update
        updated = Time.new.to_i
    end
                   
    def parentObject
        Storage.find_by_objectid(self.parent)
    end
    
    def parent=(folder_id, user_or_group_id = NOBODY)
        folder = Storage.find_folder(folder_id)
        raise "Can't find folder with uuid:" + folder_id.to_s unless folder
        quota = Quota.find_by_storageid_and_objectid(folder_id,user_or_group_id)
        if quota
            raise "Max file size: " + quota[:max_file_size].to_s if size > quota[:max_file_size]
            raise "Max total size: " + quota[:max_total_size].to_s if size + folder.size> quota[:max_total_size]        
        end            
        write_attribute :parent, folder_id
        folder.data = folder.data.to_i + size
    end
    
    def size
        if objecttype == STYPE_FOLDER
            return data
        else
            if attribute_present?(data)
                return data.size
            else
                return 0
            end
        end
    end
    
    def Storage.find_folder(folder_uuid)
        Storage.find_by_objectid_and_objecttype(folder_uuid,STYPE_FOLDER)
    end    
    
    
    def Storage.find_file(file_uuid)
        Storage.find_by_objectid_and_objecttype(file_uuid,STYPE_FILE)            
    end  
   
end