# This class is used to represent a Comment within a Wall.
class Comment < DataObject
	belongs_to :wall, :foreign_key => "parent_id"
	before_create :set_category_id

	# Override the inspect method to give us something a bit more useful.
	def inspect
		return "#<Comment:#{title}>"
	end

	# Returns the body of the message
	def message
		return self.data
	end

	# Sets the message body
	def message=(msg)
		return self.data = msg
	end

	# Points to a file to render this
	def path_of_partial
		return "models/comment"
	end

	# URL is from the parent comments container (wall), which is in turn from the parent of the parent...
	def url(options = {})
		return self.parent.url(options)
	end

	private
		def set_category_id
			unless parent.nil?
				self.category_id = parent.category_id
			end
		end
end
