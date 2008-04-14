module EventServiceCommon
	# Calendar sorting functions; implemented as EventServiceCommon::CalendarSorting
	module CalendarSorting
	        # takes an array of events and sorts them by their start time
	        # returns a sorted array
	        def self.sort_events_by_start_time(events_before_sort, ignore_past_entries = false)
	        	# Theory:
	                # Create an array containing event times, sort it, and have
	                # a hash of event times => Event, then iterate array,
	                # pointing at hash, and build a final array in event time
	                # order
	                event_times = []
	                events_by_time = {}
	                events_before_sort.each do |event|
	                        event_times << event.start_time
	                        events_by_time[event.start_time] = event
	                end
	                # Sort the events now
	                event_times.sort!
	                # Now build the result
	                events_after_sort = []
	                event_times.each do |event_time|
	                  # if the event ends now or later than now, show it if they requested, or show all if they didn't
	                        if	(ignore_past_entries && 
						!events_by_time[event_time].end_time.nil? &&		# if there is an end time and we ignore past entries
						events_by_time[event_time].end_time >= Time.now) || 
					(ignore_past_entries &&
						events_by_time[event_time].end_time.nil? &&		# if there is no end time and we ignore past entries
						event_time >= Time.now) ||
					!ignore_past_entries						# if we ignore past entries
					# if any of the above three conditions are met, add the event.
	                                events_after_sort << events_by_time[event_time]
	                        end
	                end
	                # Now return the result
	                return events_after_sort
	        end
	end
end
