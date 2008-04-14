# This is the representation of a specific event.
class Event < DataObject
	acts_as_macrodeck_wall

	# Override the inspect method to give us something a bit more useful.
	def inspect
		return "#<Event:#{title}>"
	end

	# Gets the summary (title)
	def summary
		return self.title
	end

	# Sets the summary (title)
	def summary=(value)
		self.title = value
	end

	# Returns a symbol representing the recurrence value of this event
	def recurrence
		return self.extended_data[:recurrence]
	end

	# Sets the recurrence of this event. Available options:
	# :weekly (occurs on same day of week for every week afterwards)
	# :monthly (occurs on same day of month for every month afterwards)
	# :none (event is not recurring)
	def recurrence=(value)
		if value != :weekly || value != :monthly || value != :none
			raise ArgumentError, "recurrence must be a valid symbol"
		else
			self.extended_data[:recurrence] = value
		end
	end

	# Returns the start time of the event
	def start_time
		if !self.extended_data[:start_time].nil?
			start_time = Time.at(self.extended_data[:start_time])
		else
			start_time = nil
		end
		return start_time
	end
	
	# Sets the start time of the event
	def start_time=(newtime)
		if newtime.class == Time || newtime.class == Date || newtime.class == DateTime
			self.extended_data[:start_time] = newtime
		else
			raise ArgumentError, "start_time must be a Time"
		end
	end

	# All day event: getter.
	def all_day
		return self.extended_data[:all_day]
	end

	# All day event: setter.
	def all_day=(value)
		if value
			self.extended_data[:all_day] = true
			# End time is set to midnight.
			dtstart = self.start_time
			self.extended_data[:end_time] = Time.mktime(dtstart.year, dtstart.month, dtstart.day + 1, 0, 0)
		else
			self.extended_data[:all_day] = false
		end
	end

	# No specified end time: getter.
	def no_end_time
		return self.extended_data[:no_end_time]
	end

	# No specified end time: setter
	def no_end_time=(value)
		if value
			self.extended_data[:no_end_time] = true
		else
			self.extended_data[:no_end_time] = false
		end
	end

	# Returns the start time of the event
	def end_time
		if !self.extended_data[:end_time].nil?
			end_time = Time.at(self.extended_data[:end_time])
		else
			end_time = nil
		end
		return end_time
	end

	# Sets the start time of the event
	def end_time=(newtime)
		if newtime.class == Time || newtime.class == Date || newtime.class == DateTime
			self.extended_data[:end_time] = newtime
		else
			raise ArgumentError, "end_time must be a Time"
		end
	end

	# FIXME
	def url_part
		return uuid
	end
end
