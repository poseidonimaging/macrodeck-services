# This is ActiveRecord model for profiles table. 

require 'services'
require 'data_group'
require 'data_item'

class Profile < DataGroup
            
    attr_protected :groupingtype
    
  #  has_many :items, :class_name=>"DataItem", :foreign_key=>"grouping"
    UUID = DGROUP_PROFILE

    # we should be sure that we create exactly Profile element
    def before_create        
        write_attribute :groupingtype, UUID
        write_attribute :groupingid, UUIDService.generateUUID
    end
    
    # return all data items for this profile
    def items
        DataItem.find_all_by_grouping(profile_id)
    end

    # we block ability 
    def groupingtype=(newtype)
        raise "groupingtype is unchangeable attribute for this class"
    end
    
    # reading accessor for groupingid attribute
    def profile_id
        read_attribute :groupingid
    end
    
    def uuid
        read_attribute :groupingid
    end
    
    # writing accessor for groupingid attribute    
    def profile_id=(id)
        write_attribute :groupingid, id
    end
    
    # check presence of element with specific groupingid
    def Profile.Exist?(profile_id)
        Profile.find_by_profile_id(profile_id)        
    end
        
    # create new profile with given metdata    
    def Profile.createNewProfile(objMetadata=Metadata.new)
         profile = new
         profile.loadMetadata(objMetadata)
         profile.save
         profile.uuid
    end

    # additional accessor for groupingid
    def Profile.find_by_profile_id(profile_id)
        return Profile.find_by_groupingid(profile_id)
    end

    # small hack - we want to find Profile with only profile id not real db's id.    
    def Profile.find(*args)
        if (args.size == 1) and (args.first.instance_of? String)
            return find_by_profile_id(args.first)
        end
        super
    end
    
    # add new item to the profile
    def addNewItem(type,value,objMetadata = Metadata.new)
        objMetadata.owner = self.owner
        objMetadata.grouping = self.uuid
        DataService.createData(type,value,objMetadata)  
#        profile_item = ProfileItem.new do |i|
#          i.loadValue(type,value)
#          i.loadMetadata(objMetadata)          
#        end
#        profile_item.save
#        profile_item.uuid                                       
    end
  
    # update exist metadata or create one  
    def updateMetadata(name,value)
        DataService.modifyDataGroupMetadata(profile_id,name,value)
        reload
    end
    
    private 
    # this is another small hack of AR:Base class. we just want to be sure that
    # we will operate only with real Profile objects (i.e. groupingtype is 
    # equal DGROUP_PROFILE)
    def Profile.find_every(options)
        conditions = " AND (#{sanitize_sql(options[:conditions])})" if options[:conditions]
        options.update :conditions => "#{table_name}.groupingtype = '#{DGROUP_PROFILE}'#{conditions}"
        super
    end
    
end