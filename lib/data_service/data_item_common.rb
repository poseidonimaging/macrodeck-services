# Common DataItem methods

module DataItemCommon

	# DataItem class methods
	module ClassMethods
		#belongs_to :data_group
	end

	# DataItem instance methods
	module InstanceMethods		
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
			if self.children != nil && self.children.length > 0
				return true
			else
				return false
			end
		end

		# Returns children DataGroups
		def children
			if @children.nil?
				@children = DataGroup.find(:all, :conditions => { :parent_uuid => self.uuid })
			end
			return @children
		end

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
	end
end
