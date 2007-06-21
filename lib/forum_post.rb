class ForumPost < ActiveRecord::Base
    set_table_name 'data_items'
    UUID = FORUM_POST  

    def forum
      Forum.checkUUID(self.parent)
    end
    
    def forum=(forum_ref)
      return self.parent = forum_ref.uuid if forum_uuid.instance_of? Forum
      ForumCategory.checkUUID(forum_ref) ? self.parent = forum_ref : nil
    end

end