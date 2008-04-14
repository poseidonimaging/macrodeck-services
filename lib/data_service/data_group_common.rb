# Common DataGroup methods.

module DataGroupCommon

	# Class methods. Eg. DataGroup.whatever.
	module ClassMethods
		#has_many :data_items, :dependent => :destroy
		#belongs_to :category
	end

	# Instance methods. Duh.
	module InstanceMethods

		# String representation of this group.
		def to_s
			return self.uuid
		end

		# update attibutes from metaData object
		def loadMetadata(objMeta)
			update_attributes(objMeta.to_hash)
		end
		
		###########################################################################


		# Returns a User for the creator
		def created_by_user
			if @created_by_user.nil?
				@created_by_user = User.find_by_uuid(self.created_by)
			end
			return @created_by_user
		end

		# Returns a User for the owner
		def owned_by_user
			if @owned_by_user.nil?
				@owned_by_user = User.find_by_uuid(self.owned_by)
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
			  i.grouping = self.uuid

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
