class Metadata
  attr_accessor :grouping, :type, :creator, :owner, :tags, :title, :creation, :description, :datacreator
  
  def initialize(grouping=nil, type=nil,creator=NOBODY,owner=NOBODY,tags=nil,title=nil,creation=nil,description=nil,datacreator=nil)
    set_instance_variables(binding, *local_variables)    
    yield self if block_given?
  end
 
  def loadFromHash(hash)
    hash.each do |key,val|
       instance_variable_set("@#{key}", val) if respond_to?(key)
    end 
  end
  
  def [](key)    
    return instance_variable_get("@#{key.to_s}") if instance_variables.include?("@#{key.to_s}")
    nil
  end
  
  def Metadata.makeFromHash(hash)
    obj = new
    obj.loadFromHash(hash)
    obj
  end
  
  def to_hash
      res = {}
      instance_variables.each do |var|
        var.sub!(/^@/,'')
        res[var] = instance_variable_get("@#{var}")
      end
      res      
  end  
  
#  def context(&block)
#      instance_eval(&block)
#  end
  
  def fetch(obj)    
    begin
      instance_variables.each do |var|
        var.sub!(/^@/,'')
        instance_variable_set("@#{var}",obj.send(var)) if obj.respond_to?(var)
      end  
    end
    self
  end
  
  def set_instance_variables(binding, *variables)
    variables.each do |var|
      instance_variable_set("@#{var}", eval(var, binding))
    end
  end
  
  
  
end