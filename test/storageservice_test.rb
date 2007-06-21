require 'test_helper'
require 'profile'

class StorageServiceTest < Test::Unit::TestCase
    fixtures :storages, :quotas, :users
    
    def test_createFile
        assert storage = StorageService.createFile(:file,'test',nil,{:title => "test.dat"})
        assert_raise(RuntimeError) {StorageService.createFile(:fill,'test',nil,nil)}
    end
    
    def test_linkFileToFolder
        assert StorageService.linkFileToFolder("0003","0002","1")
        assert_equal storages(:storage2).parentObject.id, 3
        assert_raise(RuntimeError) { StorageService.linkFileToFolder("0002","0003","1") }
        assert_raise(ActiveRecord::RecordNotFound) { StorageService.linkFileToFolder("0002","xxx","1") }        
    end

    def test_addTagToFile
        assert true
    end
    
    def test_modifyFileMetadata
        assert StorageService.modifyFileMetadata("0003", {:title => "my_folder"})
        assert_equal storages(:storage3).title,'my_folder'
        assert_raise(ArgumentError) { StorageService.modifyFileMetadata("0003", {:title => "my_folder", :xxx => "bugaga"})}        
    end
    
    def test_modifyFileMetadataByName
        assert StorageService.modifyFileMetadataByName("0003", "title", "joel_folder")
        assert_equal storages(:storage3).title,'joel_folder'
        assert_raise(ArgumentError) { StorageService.modifyFileMetadataByName("0003", "attribut", "xxx")}
    end
    
    def test_renameFile
        assert StorageService.renameFile("0003", "pictures")
        assert_equal storages(:storage3).title,'pictures'
    end

    def test_deleteFile
        assert StorageService.deleteFile("0002")
        assert_nil Storage.find_by_objectid("0002")

    end
    
    def test_getFolderContents
        assert cont = StorageService.getFolderContents("0003")
        assert_equal cont.size,1
    end   
    
    def test_setupQuotas
        assert cont = StorageService.setupQuotas("0003", 1, {:max_file_size => "1", :max_total_size => "10"})        
    end
    
    def test_getFileData
        assert_equal StorageService.getFileData("0002"),'test'
        assert_nil StorageService.getFileData("0001")
        assert_raise(RuntimeError) { StorageService.getFileData("xxx") }
    end         
end    