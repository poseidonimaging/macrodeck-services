# Common DataItem methods

module DataItemCommon

	# DataItem class methods
	module ClassMethods

		# Finds a specific data item based on its UUID
		# FIXME: This is stupid and already done for us as find_by_uuid.
		def getItem(dataID)
			return self.find(:first, :conditions => ["dataid = ?", dataID])
		end

		# Returns true if the item specified exists.
		# I think you can figure out what it returns if it doesn't exist..
		def isItem?(dataID)
			i = self.getItem(dataID)
			if i != nil
				return true
			else
				return false
			end
		end

		# Wrapper function that finds by dataid instead but makes it easier for me to write
		# less stupid code.
		def find_by_uuid(value)
			return self.find(:first, :conditions => ["dataid = ?", value])
		end
	end

	# DataItem instance methods
	module InstanceMethods

		# Provides a transparent interface to get the item's UUID (stored as dataid)
		def uuid
			self.dataid
		end

		# Set the UUID of the item
		def uuid=(item_uuid)
			self.dataid = item_uuid
		end

		# Returns the data type of the item
		def type
			self.datatype
		end
		
		# Sets the type of the item.
		def type=(type_uuid)
			self.datatype = type_uuid
		end
		
		# FIXME: Why is this here? What calls this? Eugene...!
		def context(&block)
			instance_eval(&block)       
		end
		
		# update attibutes from metaData object
		# FIXME: change this and all instances of loadMetadata to metadata= as it makes more sense
		def loadMetadata(objMeta)
			update_attributes(objMeta.to_hash)
		end

		# A convienence method so you can set the value and using
		# black magic, Ruby, Ms. Dash, and a teaspoon of vanilla
		# extract, we put it in the table correctly. We hope.
		def value=(val)
			if val != nil && val.class != nil
				case value.class
				when String
					self.stringdata = value
				when Fixnum, Float, Integer, Number
					self.integerdata = value
				else
					# this works for objects. so if you're fucking crazy
					# you can do something like this:
					#	myitem.value = myotheritem
					# ...and that will embed a DataItem in another. which
					# is totally stupid but possible and easy to do...
					self.objectdata = value.to_yaml
				end
			end
		end

		# update value
		def setValue(type,value)
		  case type
			when :string, "string"
			  self.stringdata = value
			when :integer, "integer"
			  self.integerdata = value
			when :object, "object"
			  self.objectdata = value.to_yaml
			when :nothing, "nothing"
			else
			  raise ArgumentError
		  end
		end

		# get value
		def getValue(type)
			case type
			when :string, "string"
				return self.stringdata
			when :integer, "integer"
				return self.integerdata
			when :object, "object"
				return YAML::load(self.objectdata)
			when :nothing, "nothing"
			else
				raise ArgumentError
			end
		end

		# alias doesn't work so here's a proxy method
		def value(type)
			getValue(type)
		end
		
		# Returns true if there are children DataGroups.
		# A child DataGroup is one whose `parent` field is
		# set to the UUID of this item.
		def children?
			if @children.nil?
				@children = DataGroup.find(:all, :conditions => ["parent = ?", dataid])
			end
			if @children != nil && @children.length > 0
				return true
			else
				return false
			end
		end

		# Is this DataItem on a quest to find its parents? You won't find
		# out until you call this method!
		def parent?
			if @parent.nil?
				@parent = DataGroup.find(:first, :conditions => ["groupingid = ?", grouping])
			end
			if @parent != nil
				return true
			else
				return false
			end
		end

		# Returns this data item's parent group
		def parent
			if @parent.nil?
				@parent = DataGroup.find(:first, :conditions => ["groupingid = ?", grouping])
			end
			return @parent
		end

		# Returns children DataGroups
		def children
			if @children.nil?
				@children = DataGroup.find(:all, :conditions => ["parent = ?", dataid])
			end
			return @children
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
	end
end
