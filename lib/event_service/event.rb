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
		if value != :weekly || value != :monthly || value != :none || value != :yearly || value != :every_n_days || value != :monthly_nth_nday
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

	# returns true if the event is over with, false otherwise
	def concluded?
		# initialize values
		dtstart = Time.at(self.extended_data[:start_time])

		if self.extended_data[:no_end_time] != nil && self.extended_data[:no_end_time] != true
			dtend = Time.at(self.extended_data[:end_time])
		else
			dtend = nil
		end

		if (dtstart && dtend) && dtend < Time.new
			# event ended
			return true
		elsif (dtstart && !dtend) && (dtstart + 21600) < Time.new
			# event started more than 6 hours (21600 seconds) ago
			return true
		else
			# event not concluded yet
			return false
		end
	end
	
	# processes recurrence - will always run, doesn't check event is in the past. use with:
	# if event.concluded? then event.process_recurrence
	#
	# we'll do this manually cause as someone on IRC pointed out, doing it EVERY time is slow and will
	# cause problems. so Calendar's event roll stuff will have to be updated to process recurrence
	# if needed
	def process_recurrence
		if self.extended_data != nil && self.extended_data[:recurrence] != nil && self.extended_data[:recurrence] != :none
			# initialize values
			dtstart = Time.at(self.extended_data[:start_time])

			if self.extended_data[:no_end_time] != nil && self.extended_data[:no_end_time] != true
				dtend = Time.at(self.extended_data[:end_time])
			else
				dtend = nil
			end

			if self.extended_data[:recurrence] == :every_n_days
				days_between_recurrences = self.extended_data[:days_between_recurrences]
				
				if days_between_recurrences.nil?
					days_between_recurrences = 0
				end

				dtstart = days_between_recurrences.days.since dtstart
				if !dtend.nil?
					dtend = days_between_recurrences.days.since dtend
				end
			elsif self.extended_data[:recurrence] == :weekly # same day every week
				dtstart = 1.week.since dtstart
				if !dtend.nil?
					dtend = 1.week.since dtend
				end
			elsif self.extended_data[:recurrence] == :monthly # same day every month (day + 1 month)
				dtstart = 1.month.since dtstart
				if !dtend.nil?
					dtend = 1.month.since dtend
				end
			elsif self.extended_data[:recurrence] == :monthly_nth_nday # every 1st/2nd/3rd/4th N-day .. or every Nth Nday
				dtstart = 28.days.since dtstart
				if !dtend.nil?
					dtend = 28.days.since dtend
				end
			elsif self.extended_data[:recurrence] == :yearly # same day every year (day + 1 year)
				dtstart = 1.year.since dtstart
				if !dtend.nil?
					dtend = 1.year.since dtend
				end
			end
		end
	end
end
