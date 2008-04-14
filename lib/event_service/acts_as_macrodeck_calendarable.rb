module ActiveRecord
	module Acts
		module MacroDeckCalendarable
			def self.included(base)
				base.extend(ClassMethods)
			end

			module ClassMethods
				# acts as macrodeck calendarable function - no configuration options yet though
				def acts_as_macrodeck_calendarable(configuration = {})
					include ActiveRecord::Acts::MacroDeckCalendarable::InstanceMethods
				end
			end

			module InstanceMethods
				def calendar
					calendar = Calendar.find_by_parent_id(self.id)
					if calendar.nil?
						calendar = Calendar.new do |c|
							c.title = "#{self.title}'s Calendar"
							c.parent_id = self.id
							c.category_id = self.category_id
						end
						calendar.save!
					end
					return calendar
				end
			end
		end
	end
end

# extend the ActiveRecord with acts_as_macrodeck_calendarable
ActiveRecord::Base.send(:include, ActiveRecord::Acts::MacroDeckCalendarable)
