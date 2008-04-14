# Breadcrumb class. Stores information about a link for use in the breadcrumbs bar
class Breadcrumb
	# Attributes
	attr_accessor :url		# URL of the breadcrumb
	attr_accessor :text		# What to display as the text of the breadcrumb
	attr_accessor :caption	# The HTML title attribute for the breadcumb

	# Can create a breadcrumb by going Breadcrumb.new(text, url)
	def initialize(text = nil, url = nil)
		if !text.nil? && !url.nil?
			@text, @url = text, url
		end
		puts inspect
	end

	def inspect
		return "#<Breadcrumb:'#{@text}' #{@url}>"
	end

	# Takes an Event object and returns a Breadcrumb object. Do this:
	# Breadcrumb.from_event(:event => <Event>, :baseurl => "whatever", :action => :view)
	def self.from_event(options = {})
		url = options[:baseurl]
		if options[:event] != nil && options[:event] != ""
			url << "#{url_sanitize(options[:event].parent.url_part)}/"
		end
		if options[:action] != nil && options[:action] != ""
			url << "#{url_sanitize(options[:action].to_s)}/"
		end
		if options[:event] != nil && options[:event] != ""
			url << "#{url_sanitize(options[:event].url_part.to_s)}/"
		end
		return Breadcrumb.new(options[:event].title, url)
	end

	# Takes an Calendar object and returns a Breadcrumb object. Do this:
	# Breadcrumb.from_calendar(:calendar => <Calendar>, :baseurl => "whatever", :action => :view)
	def self.from_calendar(options = {})
		url = options[:baseurl]
		if options[:calendar] != nil && options[:calendar] != ""
			url << "#{url_sanitize(options[:calendar].url_part)}/"
		end
		if options[:action] != nil && options[:action] != ""
			url << "#{url_sanitize(options[:action].to_s)}/"
		end
		return Breadcrumb.new(options[:calendar].title, url)
	end

	# Takes a Place object and returns a Breadcrumb object. Do this:
	# Breadcrumb.from_place(:place => <Place>, :baseurl => "whatever", :action => :view)
	def self.from_place(options = {})
		url = options[:baseurl]
		if options[:action] != nil && options[:action] != ""
			url << "#{url_sanitize(options[:action].to_s)}/"
		end
		# Country
		url << "#{url_sanitize(options[:place].parent.category.parent.parent.url_part)}/"
		# State
		url << "#{url_sanitize(options[:place].parent.category.parent.url_part)}/"
		# City
		url << "#{url_sanitize(options[:place].parent.url_part)}/"
		# Place
		url << "#{url_sanitize(options[:place].url_part)}/"
		return Breadcrumb.new(options[:place].name, url)
	end

	# Takes a Category object and returns a Breadcrumb object. Do this:
	# Breadcrumb.from_category(:category => <Category>, :baseurl => "whatever", :action => :view, :levels => 1)
	# Level is the number of levels to go back up the tree to make a URL. If the category is say, Austin, TX,
	# here's what a sample level set might be:
	# levels = 0 baseurl/action/austin
	# levels = 1 baseurl/action/tx/austin
	# levels = 2 baseurl/action/us/tx/austin
	# levels = 3 baseurl/action/places/us/tx/austin
	# levels = 4 <invalid>
	def self.from_category(options = {})
		url = options[:baseurl]
		if options[:action] != nil && options[:action] != ""
			url << "#{url_sanitize(options[:action].to_s)}/"
		end
		if options[:levels] != nil && options[:levels] > 0
			options[:levels].times do |l|
				levelnumber = options[:levels] - l
				curitem = options[:category]
				levelnumber.times do 
					curitem = curitem.parent
				end
				url << "#{url_sanitize(curitem.url_part)}/"
			end
		end
		# Last node (current category)
		url << "#{url_sanitize(options[:category].url_part)}/"
		return Breadcrumb.new(options[:category].title, url)
	end

    # This method takes a string and returns a suitable URL version.
    def self.url_sanitize(str)
		return str.chomp.strip.downcase.gsub(/[^0-9A-Za-z_\-\s]/, "").gsub(" ", "-")
    end

	# Returns the Breadcrumb as an <a /> tag
	def to_html
		html = "<a href=\"#{@url}\""
		if !@caption.nil?
			html << " title=\"#{@caption}\""
		end
		html << ">#{@text}</a>"
		return html
	end
end

