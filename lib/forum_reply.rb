class ForumReply < ActiveRecord::Base
    set_table_name 'data_items'
    UUID = FORUM_REPLY
#    def checkUUID(uuid)
#      data_group = find_by_uuid(uuid)
#      data_group.groupingtype == FORUM_REPLY ? data_group : false
#    end

end