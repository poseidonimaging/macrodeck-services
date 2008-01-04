class ForumService < BaseService
  	@serviceAuthor = "Eugene Hlyzov <ehlyzov@issart.com>"
	@serviceID = "com.macrodeck.ForumService"
	@serviceName = "ForumService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 1	
    @serviceUUID = "110920b4-c110-4f54-8b86-fdda9daf08c7"
    
  def ForumService.createBoard(metadata)
    obj = ForumBoard.new do
      groupingid = UUIDService.generateUUID
      groupingtype = ForumBoard::UUID
      update_attributes(metadata)
      datacreator = @serviceUUID unless post.datacreator
    end
    obj.save ? obj.uuid : nil
  end
  
  def ForumService.updateBoardMetadata(board_uuid,metadata)
      board = ForumCategory.checkUUID(board_uuid)
      raise unless board
      board.update_attrubutes(metadata.to_hash)
  end
  
  def ForumService.deleteBoard(board_uuid)
    obj = ForumBoard.checkUUID(uuid)
    # TODO: have to verify this action.  
    obj ? obj.destroy : nil
  end  
  
  def ForumService.createCategory(board_uuid,objMetadata)
    obj = ForumCategory.new do
      groupingid = UUIDService.generateUUID
      groupingtype = ForumCategory::UUID
      board = board_uuid
      update_attributes(objMetadata.to_hash)
      datacreator = @serviceUUID unless post.datacreator
    end  
    obj.save ? obj.uuid : nil
  end
  
  def ForumService.updateCategoryMetadata(category_uuid,metadata)
    category = ForumCategory.check(category_uuid)
    raise unless category
    category.update_attrubutes(metadata.to_hash)
  end
  
  def ForumService.deleteCategory(category_uuid)
    obj = ForumCategory.check(uuid)
    # TODO: have to verify this action.  
    obj ? obj.destroy : nil  
  end

  
  def ForumService.createForum(category_uuid,metadata)
    return nil unless ForumCategory.checkUUID(category_uuid)
    obj = Forum.new do
      groupingid = UUIDService.generateUUID
      groupingtype = Forum::UUID
      parent = category_uuid
      update_attributes(metadata.to_hash)
      datacreator = @serviceUUID unless post.datacreator
    end  
    obj.save ? obj.uuid : nil
  end
  
  def ForumService.moveForumToCategory(forum_uuid,category_uuid)
    forum = Forum.checkUUID(forum_uuid)    
    return nil unless forum     
    return nil if (forum.category = category_uuid).nil?
    forum.save    
  end
  
  def ForumService.deleteForum(forum_uuid)
    obj = Forum.checkUUID(uuid)
    # TODO: have to verify this action.  
    obj ? obj.destroy : nil  
  end
  
  def ForumService.updateForumMetadata(forum_uuid,metadata)
      board = ForumCategory.checkUUID(board_uuid)
      raise unless board
      board.update_attrubutes(metadata.to_hash)  
  end
  
  # Create a new post in the given forum
  # +forum_uuid+:: forum where a post shoul be created
  # +msg+:: post's message
  # +metadata+:: hash of post's metadata
  # === Example
  # ForumService.createPost(@crazy_forum_uuid, 'I need few nuts.. khe..khe',{:author=>"Joe White", :title=>"I am a squirrel!" }
  def ForumService.createPost(forum_uuid,msg,metadata)     
      forum = Forum.checkUUID(forum_uuid)
      return nil unless forum
      
      post_group = ForumPostGroup.new do
          parent = forum_uuid
          groupingid = UUIDService.generateUUID
          datatype = ForumPostGroup::UUID
          datacreator = metadata[:datacreator] ? metadata[:datacreator] : @serviceUUID
      end
      post_group.save
                       
      post = ForumPost.new do              
          grouping = post_group.uuid
          stringdata = msg
          dataid = UUIDService.generateUUID
          datatype = ForumPost::UUID
          update_attributes(metadata.to_hash)
          datacreator = @serviceUUID unless post.datacreator
      end
      post.save ? dataid : nil                 
  end
  
  # Deletes a post and all its replies (!)
  def ForumService.deletePost(post_uuid)
      post = ForumPost.checkUUID(post_uuid)
      post ? post.destroy : nil
  end
  
  def ForumService.movePostToForum(post_uuid, forum_uuid)
    post = ForumPost.checkUUID(post_uuid)    
    return nil unless post     
    return nil if (post.forum = forum_uuid).nil?
    post.save    
  end
  
  # Get post by given uuid
  def ForumService.getPost(post_uuid)
      post = ForumPost.checkUUID(post_uuid)
      post ? post : nil
  end
  
  # Updates post by given uuid. 
  # +values+:: hash of updated values
  # == Example
  # ForumService.getPost(post_uuid,{:msg=>"hi Jo!"})
  def ForumService.updatePost(post_uuid,values)
      post = Post.find_by_uuid(post_uuid)
      post ? post.update_attributes(values) : nil          
  end
  
  # returns last post's reply
  def ForumService.getLastReply(post_uuid)
    post = ForumPost.checkUUID(post_uuid)
    return nil unless post    
    replys = post.replys    
    return nil if replys.empty?
    return replys[0].uuid
  end
  
  # returns true if post had been changed since given date
  def ForumService.isPostChanged?(post_uuid, since=nil)    
    post = ForumPost.checkUUID(post_uuid)
    return nil unless post    
    replys = post.replys    
    return false if replys.empty? 
    return true if since.nil?        
    return (replys[0].date > since)
  end
  

  # reply's methods' meaning are very similar to corresponding post's methods  
  
  def ForumService.createReply(post_uuid,msg,metadata)
      post = ForumPost.checkUUID(forum_uuid)
      return nil unless post           
      reply = ForumReply.new do              
          owner = post.uuid
          grouping = post.grouping
          stringdata = msg
          dataid = UUIDService.generateUUID
          datatype = FORUM_REPLY
          update_attributes(metadata.to_hash)
          datacreator = @serviceUUID unless post.datacreator
      end
      reply.save ? dataid : nil      
  end
  
  def ForumService.deleteReply(reply_uuid)
      reply = ForumReply.checkUUID(reply_uuid)
      reply ? reply.destroy : nil  
  end
  
  def ForumService.getReply(reply_uuid)
      reply = ForumReply.checkUUID(reply_uuid)
      reply ? reply : nil    
  end
  
  def ForumService.updateReply(reply_uuid,values)
      reply = ForumReply.checkUUID(reply_uuid)
      reply ? reply.update_attrbutes(values) : nil      
  end
    
end