# This service requires DataService to work.
# It provides some functions to work with profiles.

require 'profile'       # profile virtual model
require 'profile_item'  # profile item virtual model

class ProfileService < BaseService
  	@serviceAuthor = "Eugene Hlyzov <ehlyzov@issart.com>"
    @serviceID = "com.macrodeck.ProfileService"
    @serviceName = "ProfileService"	
    @serviceVersionMajor = 0
    @serviceVersionMinor = 1	
    @serviceUUID = "c38837a2-25dc-4ba3-8b7d-4c3a6afa828c"
    # Creates a new profile. You should use createProfileItem to add 
    # some data here. Parameter's format is {:owner => "...", etc.}
    def self.createProfile(metadata)
        case metadata.class.name
          when 'Metadata'
            objMetadata = metadata
          when 'Hash'
            objMetadata = Metadata.makeFromHash(metadata)
          else
            raise ArgumentError
        end
        Profile.createNewProfile(objMetadata)              
        #DataService.createDataGroup(nil,nil,objMetadata) 
    end
    
    # Deletes profile by its profileId. 
    # *NOTE*! This method also removes all profile items which have 
    # this profileId as parent. 
    def self.deleteProfile(profile_id)
        profile = Profile.find(profile_id)
        if profile
            profile.items.each { |item| item.destroy }
            return profile.destroy
         else
            return false
         end
    end
    
    # Modifies the metadata for the specified profile.
    def self.modifyProfileMetadata(profile_id, name, value)
        profile = Profile.find(profile_id)
        return profile.updateMetadata(name,value) if profile
        false
    end
    
    # Creates a new profile's item within given profile.
    def self.addProfileItem(profile_id, type, value, metadata)
        profile = Profile.checkUUID(profile_id)
        raise ArgumentError unless profile        
        case metadata.class.name
          when 'Metadata'
            objMetadata = metadata
          when 'Hash'
            objMetadata = Metadata.makeFromHash(metadata)
          else
            raise ArgumentError
        end
        objMetadata.datacreator = @serviceUUID
        profile.addNewItem(type,value,objMetadata)
    end
    
    # Deletes a specified profile field.
    # 
    def self.deleteProfileItem(item_id)        
        DataService.deleteDataItem(item_id)
    end
    
    # Modifies a profile field type and value.
    # 
    def self.modifyProfileItem(item_id, item_type, item_value)
        if DataService.doesDataItemExist?(item_id)
            DataService.modifyDataItem(item_id, item_type, item_value)
        else
            return false                
        end
    end

    # Modifies a profile field metadata.
    # 
    def self.modifyProfileItemMetadata(item_id, metadata)
        if DataService.doesDataItemExist?(item_id)
            metadata.each { |name,value|
                DataService.modifyDataItemMetadata(item_id, name, value)            
            }
        else
            return false                
        end
    end
    
    # Returns a list of all fileds of specified profile
    #
    def self.getProfileItems(profile_id)
        if Profile.Exist?(profile_id)
            profile = Profile.find(profile_id)
            return profile.items
        else
            return false         
        end
    end

    def self.getProfile(user_or_group_id)
        return Profile.find_by_owner(user_or_group_id)
    end
end

Services.registerService(ProfileService)