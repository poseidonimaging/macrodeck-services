
class ProfileItem < DataItem
     
    belongs_to :parent, :class_name=>"Profile", :foreign_key=>"grouping"
    
    UUID = DTYPE_PROFILE_FIELD
    def before_create
        write_attribute :owner, UUID        
    end 
    
    private
    
    # this is a small hack of AR:Base class. we just want to be sure that
    # we will operate only with real Profile objects (i.e. groupingtype is 
    # equal DGROUP_PROFILE)
    def ProfileItem.find_every(options)
        conditions = " AND (#{sanitize_sql(options[:conditions])})" if options[:conditions]
        options.update :conditions => "#{table_name}.datatype = '#{DGROUP_PROFILE_FIELD}'#{conditions}"
        super
    end
end