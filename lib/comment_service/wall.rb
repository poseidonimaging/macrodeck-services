# This class is for a Wall, which can be attached to numerous data types and
# contains a bunch of comments.
class Wall < DataObject
	has_many :comments, :foreign_key => "parent_id"

	# Override the inspect method to give us something a bit more useful.
	def inspect
		return "#<Wall:#{title}>"
	end

	# Returns ten of the latest comments
	def latest_comments
		if @latest_comments.nil?
			@latest_comments = Comment.find(:all, :conditions => ["parent_id = ?", self.id], :order => "created_at DESC", :limit => 10)
		end

		# Workaround for bug that didn't set category ID...
		@latest_comments.each do |c|
			if c.category_id.nil? && !self.category_id.nil?
				c.category_id = self.category_id
				c.save!
			end
		end

		return @latest_comments
	end

	def path_of_partial
		return "models/wall"
	end

	# Return this wall's parent's URL since a wall is a page component, sending along options
	def url(options = {})
		return self.parent.url(options)
	end
end
