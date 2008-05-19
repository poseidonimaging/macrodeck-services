# This class is for a calendar (e.g. a group of events)

# Will at some point support generating ics (iCalendar) files
# using Ruby iCalendar: http://icalendar.rubyforge.org/

require 'event_service/calendar_sorting'

class Calendar < DataObject
	# Returns all events in a specific category
	def self.events_in_category(category_id)
		events_before_sort = Event.find(:all, :conditions => ["category_id = ?", category_id])
		if events_before_sort.length > 0
			events_before_sort.each do |e|
				if e.concluded?
					e.process_recurrence
				end
			end
			events_after_sort = EventServiceCommon::CalendarSorting::sort_events_by_start_time(events_before_sort)
			events_in_category = events_after_sort
		else
			events_in_category = nil
		end
		return events_in_category
	end

	# Returns all upcoming events in a specific category
	def self.upcoming_events_in_category(category_id)
		events_before_sort = Event.find(:all, :conditions => ["category_id = ?", category_id])
		if events_before_sort.length > 0
			events_before_sort.each do |e|
				if e.concluded?
					e.process_recurrence
				end
			end
			events_after_sort = EventServiceCommon::CalendarSorting::sort_events_by_start_time(events_before_sort, true)
			upcoming_events_in_category = events_after_sort
		else
			upcoming_events_in_category = nil
		end
		
		return upcoming_events_in_category
	end

	# Override the inspect method to give us something a bit more useful.
	def inspect
		return "#<Calendar:#{title}>"
	end

	def events?
		return !(Event.find(:all, :conditions => ["parent_id = ?", self.id]).empty?)
	end

	def upcoming_events
		events_before_sort = Event.find(:all, :conditions => ["parent_id = ?", self.id]) # will have to order specially next
		if events_before_sort.length > 0
			events_before_sort.each do |e|
				if e.concluded?
					e.process_recurrence
				end
			end
			events_after_sort = EventServiceCommon::CalendarSorting::sort_events_by_start_time(events_before_sort, true)
			upcoming_events = events_after_sort
		else
			upcoming_events = nil
		end
		return upcoming_events
	end

	def events
		events_before_sort = Event.find(:all, :conditions => ["parent_id = ?", self.id]) # will have to order specially next
		if events_before_sort.length > 0
			events_before_sort.each do |e|
				if e.concluded?
					e.process_recurrence
				end
			end
			events_after_sort = EventServiceCommon::CalendarSorting::sort_events_by_start_time(events_before_sort)
			events = events_after_sort
		else
			events = nil
		end
		
		return events
	end

	# TODO: FIXME: XXX: URL PART NEEDS TO BE IMPLEMENTED PROPERLY!
	def url_part
		return self.uuid
	end
end
