class Category < ActiveRecord::Base
	
	# Allows using name and title interchangably.
	def name
		return title
	end
	
	# Allows using name= and title= interchangably.
	def name=(new_name)
		title = new_name
	end

	# update attibutes from metaData object
    def metadata=(objMeta)
        update_attributes(objMeta.to_hash)
    end

	####### TODO: Redo the below with acts_as_tree

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
	def child(childName)
		# Caching for children.
		if @child.nil?
			@child = {}
		end
		if @child[childName].nil?
			@child[childName] = Category.find(:first, :conditions => ["parent_uuid = ? AND (url_part LIKE ? OR title LIKE ?)", self.uuid, childName, childName])
		end
		if @child[childName] != nil
			return @child[childName]
		else
			return nil
		end
	end

	# Creates a child category
	def create_child(objMetadata = Metadata.new)
		child = Category.new do |c|
			c.uuid = UUIDService.generateUUID
			c.metadata = objMetadata
			c.parent_uuid = self.uuid
		end
		child.save!
		return child
	end
end
