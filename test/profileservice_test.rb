require 'test_helper'
require 'profile'

class ProfileServiceTest < Test::Unit::TestCase
    fixtures :data_groups, :data_items
    MY_PROFILE = "00000000-1111-2222-3333-444444444444"
    ZERO_UUID = "00000000-0000-0000-0000-000000000000"
    
    def test_createProfile_and_deleteProfile
        assert profile_id = ProfileService.createProfile({:owner=>"owner_uuid", :creator=>"creator_uuid"})
        assert profile = Profile.find_by_profile_id(profile_id)
        assert_equal profile.owner, "owner_uuid"
        assert ProfileService.deleteProfile(profile_id)
        assert_nil Profile.find_by_profile_id(profile_id)        
    end
    
    def test_modifyProfileMetadata
        assert ProfileService.modifyProfileMetadata(MY_PROFILE,'description','some desc')
        assert profile = Profile.find(1)
        assert_equal profile.description,'some desc'
    end
    
    def test_addProfileItem_and_modifyProfileItemMetadata_and_getProfileItems
        assert item_id = ProfileService.addProfileItem(MY_PROFILE, 'string', 'Eugene', {:title => "First Name"})
        assert_equal Profile.find(MY_PROFILE).items[0].title, 'First Name'
        assert ProfileService.modifyProfileItemMetadata(item_id,{:title => 'Second Name'})
        assert_equal Profile.find(MY_PROFILE).items[0].title, 'Second Name'
        assert_equal ProfileService.getProfileItems(MY_PROFILE).length, 1
        assert_equal ProfileService.getProfileItems(ZERO_UUID),false
    end
    
    def test_getProfile
        assert ProfileService.getProfile('3248ebfc-18c2-413e-baa8-34219408d289')
        assert_nil ProfileService.getProfile(ZERO_UUID) 
    end
end