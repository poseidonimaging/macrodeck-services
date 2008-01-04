class Category < ActiveRecord::Base
    
	# update attibutes from metaData object
    def loadMetadata(objMeta)
        update_attributes(objMeta.to_hash)
    end

	# Returns the parent category. If there is one.
	def parent
		if self.parent_uuid != nil
			# cache the result
			if @parent.nil?
				@parent = Category.find_by_uuid(self.parent_uuid)
			end

			if @parent != nil
				return @parent
			else
				raise "Parent is set but parent object does not exist in #{self.inspect}"
			end
		else
			return nil
		end
	end

	# Returns children categories.
	def children
		if @children.nil?
			@children = Category.find(:all, :conditions => ["parent_uuid = ?", self.uuid], :order => "title ASC")
		end
		return @children
	end

	# Returns a Category for the child name specified (either by title or url_part)
	def getChild(childName)
		c = Category.find(:first, :conditions => ["parent_uuid = ? AND (url_part LIKE ? OR title LIKE ?)", self.uuid, childName, childName])
		if c != nil
			return c
		else
			return nil
		end
	end

	# DEPRECIATED: Gets a child by its url_part
	# FIXME: Everything that calls this should call getChild instead.
	def getChildByURL(url_part)
		return Category.find(:first, :conditions => ["parent_uuid = ? AND url_part = ?", self.uuid, url_part])
	end

	# Creates a child category
	def createChild(objMetadata = Metadata.new)
		child = Category.new do |c|
			c.uuid = UUIDService.generateUUID
			c.loadMetadata(objMetadata)
			c.parent_uuid = self.uuid
		end
		child.save!
		return child
	end

	# Returns true if this category has the child specified.
	# Checks url_part and title. Case-insensitive.
	def hasChild?(childName)
		c = Category.find(:first, :conditions => ["parent_uuid = ? AND (url_part LIKE ? OR title LIKE ?)", self.uuid, childName, childName])
		if c != nil
			return true
		else
			return false
		end
	end
end
