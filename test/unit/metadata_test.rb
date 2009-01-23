require 'test_helper'
require 'services'

class SampleMetadataClass
  attr_reader :type, :creator
  def initialize
    @type = 'type'
    @creator = 'creator'
  end
end

class MetadataTest < Test::Unit::TestCase
  def test_creation_without_block
    assert meta = Metadata.new
    assert_nil meta.type       
  end
  
  def test_creation_with_block
    meta = Metadata.new do |m|
      m.type = 'type'
    end
    assert meta
    assert_equal 'type',meta.type
  end
  
  def test_loadFromHash
    meta = Metadata.new
    hash = {:type     =>  'type', 
            :creator  =>  'creator'            
            }
    assert meta.loadFromHash(hash)
    assert_equal hash[:type],meta.type
    assert_equal hash[:creator],meta.creator
    assert_nil meta.title            
  end
  
  def test_makeFromHash
    assert meta = Metadata.makeFromHash({:type=>'type',:creator=>'creator'})                            
    assert_equal 'type',meta.type
    assert_equal 'creator',meta.creator
    assert_nil meta.title            
  end
  
  def test_to_hash
    meta = Metadata.new
    assert hash = meta.to_hash
    assert_instance_of Hash, hash   
    assert hash.has_key?('type')
    assert_nil hash['type']
  end
  
  def test_fetch
    target = SampleMetadataClass.new
    meta = Metadata.new
    assert meta.fetch(target)
    assert_equal 'type',meta.type
    assert_equal 'creator',meta.creator
  end
  
  
end
