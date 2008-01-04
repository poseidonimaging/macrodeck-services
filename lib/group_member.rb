# This model is used by UserService to interact with the group_members table

class GroupMember < ActiveRecord::Base
	belongs_to :group

	# Returns a User for this current GroupMember.
	def getUser
		return User.find(:first, :conditions => ["uuid = ?", userid])		
	end
end
