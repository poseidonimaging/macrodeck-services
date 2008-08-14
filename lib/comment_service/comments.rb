# This class is for a group of comments.

class Comments < DataObject

	# Override the inspect method to give us something a bit more useful.
	def inspect
		return "#<Comments:#{title}>"
	end

	# Returns ten of the latest comments
	def latest_comments
		if @latest_comments.nil?
			@latest_comments = Comment.find(:all, :conditions => ["parent_id = ?", self.id], :order => "created_at DESC", :limit => 10)
		end
		return @latest_comments
	end

	# Returns true if the comments exist, false otherwise.
	def comments?
		return !(Comment.find(:all, :conditions => ["parent_id = ?", self.id]).empty?)
	end

	# Returns all of the comments in this comment group 
	def comments
		if @comments.nil?
			@comments = Comment.find(:all, :conditions => ["parent_id = ?", self.id], :order => "created_at DESC") # order newest first
		end
		return @comments
	end
	
	# Creates a comment. First parameter is the text second is the Metadata (hash or otherwise)
	def create_comment(text, meta = Metadata.new)
		item = Comment.new do |i|
			i.update_attributes(meta.to_hash)
			i.parent_id = self.id
			i.category_id = self.category_id
		end
		item.message = text
		item.save!    
		return item
	end

	def path_of_partial
		return "models/comments"
	end
end
