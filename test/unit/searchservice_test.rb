require 'test_helper'
require 'profile'

class SearchServiceTest < Test::Unit::TestCase
    fixtures :data_items
    def test_search_with_dataitem
      items = DataItem.find(:all)
      assert_instance_of Array, rat_query = SearchService.search(items,'red rat',{:index=>'memory'})
#      assert_instance_of Array, rat_query2 = SearchService.search(items,'red rat') 
#      assert_equal rat_query, rat_query2
      assert_instance_of Hash, rat_query[0]
      assert_equal rat_query[0][:item], data_items(:item3)
      
      search = SearchService.search(items,"description: red rat")
      assert_equal search.size, 0
      
      search = SearchService.search(items,"description: gray AND (wolf OR fox)")
      assert_equal search.size, 2
      
      search = SearchService.search(items,"description: gray AND (wolf OR fox)")
      assert_equal search.size, 2
    end
end