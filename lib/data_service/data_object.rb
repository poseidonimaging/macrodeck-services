class DataObject < ActiveRecord::Base
	# Callbacks
	before_validation :set_uuid_if_nil

	# data_objects is a tree
	acts_as_tree :order => "title"
	
	# Foreign Key definitions
	belongs_to	:category
	belongs_to	:data_sources
	# TODO: belongs_to	:application
	belongs_to	:created_by,	:class_name => "User", :foreign_key => "created_by_id"
	belongs_to	:updated_by,	:class_name => "User", :foreign_key => "updated_by_id"
	belongs_to	:owned_by,		:class_name => "User", :foreign_key => "owned_by_id"
	serialize	:extended_data

	# Validations
	validates_presence_of	:uuid
	validates_uniqueness_of	:uuid

	# Requires UltraSphinx
	if ActiveRecord::Base.respond_to?("is_indexed")
		puts "%%% DataService Search Enabled"
		is_indexed :fields => [
				'title',
				'type',
				'uuid',
				'description',
				'data',
				'extended_data',
				'parent_id',
				'category_id',
				'created_at',
				'updated_at'
			],
			:include => [
				{ :association_name => 'category',		:field => 'title',	:as => 'category_name' }
			],
			:delta => true
	end

	# Used for rendering unlike objects in lists; this is the "default"
	def path_of_partial
		return "models/data_object"
	end

	private
		def set_uuid_if_nil
			if self.uuid.nil? || self.uuid.empty?
				self.uuid = UUIDService.generateUUID()
			end
			return true
		end
end
