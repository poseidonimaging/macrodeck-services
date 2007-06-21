require 'test_helper'
require 'profile'

class ProfilesTest < Test::Unit::TestCase

  fixtures :data_groups    

  def test_constructor_and_desctructor
      # test creating new profile with default metadata
      assert p1 = Profile.new({:creator=>"aaa", :owner=>"bbb"})
      p1.save!      
      assert p2 = Profile.createNewProfile({:creator=>"aaa", :owner=>"bbb"})
      assert_equal p1.groupingtype, DGROUP_PROFILE
      assert p = Profile.find_all_by_creator('aaa')
      assert p.length, 2
      assert_equal p[0].owner, "bbb"
      p.each {|pr|
          assert pr.destroy
      }      
      
  end

  def test_methods
      assert profile = Profile.find_by_id(1) # it is same as data_groups(:my_profile)

      # profile_id(groupingid) accessors
      assert_equal profile.profile_id, '00000000-1111-2222-3333-444444444444'
      assert profile.profile_id = '01234567-0123-0123-0123-012345678901'
      assert_equal profile.groupingid, '01234567-0123-0123-0123-012345678901'
      profile.reload
      
      # Exist?
      assert Profile.Exist?('00000000-1111-2222-3333-444444444444')
      
      # find_by_profile_id
      assert Profile.find_by_profile_id('00000000-1111-2222-3333-444444444444')

      # find - we can find profiles not by default ID but by groupingid
      assert_equal Profile.find('00000000-1111-2222-3333-444444444444'), Profile.find(1)
    
      # addNewItem
      assert profile.addNewItem('string','test string')
      #p profile.items
      assert_equal profile.items[0].stringdata,'test string'
      
      # updateMetadata
      assert profile.updateMetadata('description','test')
      assert profile.description,'test'
      
  end
end
