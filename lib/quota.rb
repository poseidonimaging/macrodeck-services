class Quota < ActiveRecord::Base

    def before_create
        raise "Can't find user or group with UUID:" + objectid.to_s unless (User.find_by_uuid(objectid) or Group.find_by_uuid(objectid))            
    end
    
    def limitations= (quota)
        raise "A parameter must be a instance of Hash class" unless quota.instance_of? Hash
        write_attribute :max_file_size, quota[:max_file_size]
        write_attribute :max_total_size, quota[:max_total_size]
    end
end
