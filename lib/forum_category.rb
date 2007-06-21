class ForumCategory < ActiveRecord::Base
    set_table_name 'data_group'
    UUID = FORUM_CATEGORY
    
    def board=(board_ref)    
      return self.parent = board_ref.uuid if board_ref.instance_of? ForumBoard
      ForumCategory.checkUUID(board_ref) ? self.parent = board_ref : nil
    end
    
    def board
       return ForumBoard.checkUUID(self.parent) 
    end     
end