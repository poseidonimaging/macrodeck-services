require 'test_helper'
require 'profile'

class StorageTest < Test::Unit::TestCase
    fixtures :storages

    def test_parentObject
        assert storage1 = storages(:storage1)
        assert storage3 = storages(:storage3)
        assert_equal storage1.parentObject,storage3
        assert_nil storage3.parentObject
    end
    
    def test_parent_accessor
        assert storage = Storage.new
        storage.parent = "0003"
        assert_equal storage.parentObject.id, 3
        assert_raise(RuntimeError) { storage.parent = "xxx"}
    end
end