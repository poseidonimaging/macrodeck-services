# Add features to Time...
module MacroDeck
	module Extensions
		module Time
			module InstanceMethods
				def to_chronic
					retval = strftime("%B ")
					retval << day.to_s
					retval << strftime(", %Y at %I:%M %p")
					retval.gsub!("at 0", "at ")
					return retval
				end
			end
		end
	end
end

Time.class_eval { include MacroDeck::Extensions::Time::InstanceMethods }
