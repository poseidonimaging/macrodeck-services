# This ActiveRecord model is for the data_groups table. 
# This table defines groupings for DataItem objects,
# and gives each group a type. Its columns are
# similar to DataItem.

class DataGroup < ActiveRecord::Base

    acts_as_ferret :fields => [:tags, :description, :title]     

    # write time of group's creation to updated field
    def after_create
        updated = Time.new.to_i
    end

    # write time of group's update to updated field
    def after_update
        updated = Time.new.to_i
    end
 
    def uuid
        self.groupingid 
    end
    
    # It's just a alias to make this model close to DataItem 
    def type
        self.groupingtype
    end

    # update attibutes from metaData object
    def loadMetadata(objMeta)
        update_attributes(objMeta.to_hash)
    end
    
    # fake proxy
    def datacreator=(uuid)
      nil
    end
    
    # fake proxy
    def creation=(value)
      nil
    end
    
    # fake proxy
    def grouping=(uuid)
      nil
    end
    
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

	# Finds groupings by their type
	def self.findGroupings(dataType, resultsToReturn = :all)
		return self::find(resultsToReturn, :conditions => ["groupingtype = ?", dataType])
	end
	
	# Finds groupings by type and their creator.
	def self.findGroupingsByCreator(dataType, creator, resultsToReturn = :all)
		return self::find(resultsToReturn, :conditions => ["groupingtype = ? AND creator = ?", dataType, creator])
	end
	
	# Finds groupings by type and owner.
	def self.findGroupingsByOwner(dataType, owner, resultsToReturn = :all)
		return self::find(resultsToReturn, :conditions => ["groupingtype = ? AND owner = ?", dataType, owner])
	end
	
	# Finds groupings by their type and parent
	def self.findGroupingsByParent(dataType, parent, resultsToReturn = :all)
		return self::find(resultsToReturn, :conditions => ["groupingtype = ? AND parent = ?", dataType, parent])
	end
end
