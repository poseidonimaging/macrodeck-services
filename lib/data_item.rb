# This is the the ActiveRecord model that
# represents data items. A bunch of
# convienence methods will be added here
# to help DataService do its job.
# Of course, this means that DataService will
# absolutely not be able to run outside of
# Rails. At least not without some hack.

class DataItem < ActiveRecord::Base
    
    acts_as_ferret :fields => ['tags', 'description', 'title']        

    # write time of item's creation to updated field
    def after_create
        updated = Time.new.to_i
    end

    def uuid
        self.dataid
    end

    def type
        self.datatype
    end
    
    def type=(type_uuid)
        self.datatype = type_uuid
    end
    
    def context(&block)
        instance_eval(&block)       
    end
    
    def uuid=(item_uuid)
        self.dataid = item_uuid
    end
    
    # write time of item's update to updated field
    def after_update
        updated = Time.new.to_i
    end

    # update attibutes from metaData object
    def loadMetadata(objMeta)
        update_attributes(objMeta.to_hash)
    end
    # update value
    def loadValue(type,value)
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
    
	# Returns true if there are children DataGroups.
	# A child DataGroup is one whose `parent` field is
	# set to the UUID of this item.
	def children?
		dgroups = DataGroup.find(:all, :conditions => ["parent = ?", dataid])
		if dgroups != nil && dgroups.length > 0
			return true
		else
			return false
		end
	end

	# Returns children DataGroups
	def children
		dgroups = DataGroup.find(:all, :conditions => ["parent = ?", dataid])
		return dgroups
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

	# Finds a group of data based on the grouping
	# UUID specified. Can limit to a certain data
	# type if desired. The order the data is returned
	# can be specified using :desc or :asc.
	def self.findDataByGrouping(groupID, dataType = nil, order = :desc)
		if order == :desc
			sql_order = "DESC"
		elsif order == :asc
			sql_order = "ASC"
		else
			sql_order = "DESC"
		end
		if dataType != nil
			return self.find(:all, :conditions => ["grouping = ? AND datatype = ?", groupID, dataType], :order => "creation #{sql_order}")
		else
			return self.find(:all, :conditions => ["grouping = ?", groupID], :order => "creation #{sql_order}")
		end
	end
	
	# Finds a specific data item based on its UUID
	def self.findDataItem(dataID)
		return self.find(:first, :conditions => ["dataid = ?", dataID])
	end
end
