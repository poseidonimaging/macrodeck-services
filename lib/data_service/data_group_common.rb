# Common DataGroup methods.

module DataGroupCommon

	# Class methods. Eg. DataGroup.whatever.
	module ClassMethods
		# Returns true if the group exists, false if not. Specified by UUID.
		# Commented code is happy code. You want happy code, right? :)
		def isGroup?(uuid)
			g = self.getGroup(uuid)
			if g != nil
				return true
			else
				return false
			end
		end

		def find_by_uuid(uuid)
			return self.find(:first, :conditions => ["groupingid = ?", uuid])
		end
	end

	# Instance methods. Duh.
	module InstanceMethods

		# Returns the UUID of this grouping.
		def uuid
			self.groupingid 
		end

		# Sets the UUID of this grouping.
		def uuid=(new_uuid)
			self.groupingid = new_uuid
		end
		
		# Returns grouping type.
		def type
			self.groupingtype
		end

		# Sets grouping type.
		def type=(new_type)
			self.groupingtype = new_type
		end
	
		# Fake proxy - DataGroups don't have a creator program ID.
		def datacreator=(uuid)
			nil
		end
		
		# Fake proxy - you can't change your creation time. I smell an audit.
		def creation=(value)
			nil
		end
		
		# Fake proxy - grouping cannot be set for DataGroups because they don't belong in a grouping, they are one.
		def grouping=(uuid)
			nil
		end

		# String representation of this group.
		def to_s
			return groupingid
		end

		# update attibutes from metaData object
		def loadMetadata(objMeta)
			update_attributes(objMeta.to_hash)
		end
		
		###########################################################################

		# Returns true if there are data items in this grouping.
		def items?
			ditems = DataItem.find(:all, :conditions => ["grouping = ?", groupingid])
			if ditems != nil && ditems.length > 0
				return true
			else
				return false
			end
		end

		# Returns data items in this grouping
		def items
			ditems = DataItem.find(:all, :conditions => ["grouping = ?", groupingid])
			return ditems
		end

		# Returns a human-readable version of the creation
		def human_creation
			if creation != nil
				return Time.at(creation).strftime("%B %d, %Y at %I:%M %p")
			else
				return "Unknown"
			end
		end

		# Returns a human-readable version of the updated time.
		def human_updated
			if updated != nil
				return Time.at(updated).strftime("%B %d, %Y at %I:%M %p")
			else
				return "Unknown"
			end
		end

		# Returns a User for the creator
		def created_by_user
			if @created_by_user.nil?
				@created_by_user = User.find_by_uuid(self.creator)
			end
			return @created_by_user
		end

		# Returns a User for the owner
		def owned_by_user
			if @owned_by_user.nil?
				@owned_by_user = User.find_by_uuid(self.owner)
			end
			return @owned_by_user
		end

		# Creates a data item, with the metadata specified. It can be a Metadata
		# object or a regular hash
		# FIXME: Why does this return the item's UUID?
		# FIXME: This doesn't even work! WTF EUGENE?! **DOUCHEBAG**
		def createItem(objMetadata = Metadata.new)
			item = DataItem.new do |i| 
			  i.update_attributes(objMetadata.to_hash)

			  # defaults if not set in Metadata
			  i.datacreator = @serviceUUID unless i.datacreator
			  i.grouping = self.groupingid

			  i.creation = Time.now.to_i # XXX: it should be replaced by creation_at

			  # NB: The code that was here previously doesn't work. No wonder
			  # data item creation was broken!

			  i.setValue(type,value) # <-- BAM! Won't work, type does not exist, value does not exist
			end
			item.save!    
			return item.uuid
		end
	end
end
