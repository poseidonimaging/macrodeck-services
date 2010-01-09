module ActiveRecord
	module Acts
		module MacroDeckWall
			def self.included(base)
				base.extend(ClassMethods)
			end

			module ClassMethods
				# acts as macrodeck wall function - no configuration options yet though
				def acts_as_macrodeck_wall(configuration = {})
					include ActiveRecord::Acts::MacroDeckWall::InstanceMethods
				end
			end

			module InstanceMethods
				def wall
					wall = Wall.find_by_parent_id(self.id)
					if wall.nil?
						wall = Wall.new do |w|
							w.title = "#{self.title}'s Wall"
							w.parent_id = self.id
							w.category_id = self.category_id
						end
						wall.save!
					else
						wall.category_id = self.category_id
						wall.save!
					end
					return wall
				end
			end
		end
	end
end

# extend the ActiveRecord with acts_as_macrodeck_wall
ActiveRecord::Base.send(:include, ActiveRecord::Acts::MacroDeckWall)
