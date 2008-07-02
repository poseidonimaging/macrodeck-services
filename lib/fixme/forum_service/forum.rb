class Forum < ActiveRecord::Base
    set_table_name 'data_groups'    
    UUID = FORUM
    
    def category=(category_ref)    
      return self.parent = category_ref.uuid if category_ref.instance_of? ForumCategory
      ForumCategory.checkUUID(category_ref) ? self.parent = category_ref : nil
    end
    
    def category
       return ForumCategory.checkUUID(self.parent) 
    end
    
#    def checkUUID(uuid)
#      data_group = find_by_uuid(uuid)
#      data_group.groupingtype == FORUM ? data_group : false
#    end    
end