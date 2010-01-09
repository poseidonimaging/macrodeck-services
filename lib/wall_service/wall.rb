# This class is for a Wall, which can be attached to numerous data types and
# contains a bunch of comments.
class Wall < DataObject
	has_many :comments, :foreign_key => "parent_id"

	# Override the inspect method to give us something a bit more useful.
	def inspect
		return "#<Wall:#{title}>"
	end

	def path_of_partial
		return "models/wall"
	end

	# Return this wall's parent's URL since a wall is a page component, sending along options
	def url(options = {})
		return self.parent.url(options)
	end
end
