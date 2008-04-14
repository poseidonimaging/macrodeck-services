# This class is used to represent a Comment within a group of Comments.

class Comment < DataObject
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
end
