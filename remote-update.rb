# MacroDeck Services Remote Data Updater
# (C) 2006 Keith Gable <ziggy@ignition-project.com>
#
# Released under a modified GPL license. See LICENSE.

# Start DataService and UUIDService
$LOAD_PATH << File.dirname(__FILE__) + "/lib"
require 'services.rb'
require 'rubygems'
require_gem 'activerecord'
Services.startService "uuid_service"
Services.startService "data_service"

# Load RSS feed reader
require 'rss/0.9'
require 'rss/1.0'
require 'rss/2.0'
require 'rss/dublincore'
require 'rss/syndication'
require 'rss/content'
require 'rss/trackback'
require 'rss/image'

# Load HTTP client
require 'net/http'
require 'uri'

# Line Feed Constant
NEWLINE = "\r\n"

# Version Number
UPDATER_VERSION = "0.3.20060826"

# Load your yml config from rails
db_config = YAML::load(File.open("../../../config/database.yml"))
# This is the real deal...run in production!
ActiveRecord::Base.establish_connection(db_config['production'])

# Clears the remote sources for the specified UUID
# This should be called when processing new entries.
def clear_remote_sources(uuid)
	ditems = DataItem.find(:all, :conditions => ["remote_data = 1 AND sourceid = ?", uuid])
	ditems.each do |ditem|
		ditem.destroy
	end
	dgroups = DataGroup.find(:all, :conditions => ["remote_data = 1 AND sourceid = ?", uuid])
	dgroups.each do |dgroup|
		dgroup.destroy
	end
	return true
end

# When a RSS file is specified, read its contents and
# insert it into the database. Each channel is considered
# a data group and each item is considered a data item.
def insert_rss(rss_content, source)
	begin
		feed = RSS::Parser.parse(rss_content)	
	rescue RSS::InvalidRSSError
		# for invalid RSS feeds
		feed = RSS::Parser.parse(rss_content, false)
	rescue StandardError
		puts "    ! Error parsing feed."
		return false
	end
	puts "    * Importing #{feed.items.length} RSS feed items..."
	uuid = UUIDService.generateUUID
	DataService.createRemoteDataGroup(source.data_type, uuid, nil, { :title => feed.channel.title, :description => feed.channel.description }, source.uuid)
	
	# Create Data Items for each feed item
	feed.items.each do |item|
		h = Hash.new
		# Find a link to associate with this item
		begin
			h[:link] = item.link
		rescue
			begin
				# primarily used in RDF+RSS files.
				h[:link] = item.about
			rescue
				# Didn't find either!
				h[:link] = nil
			end
		end
		# Next find an author.
		begin
			h[:author] = item.dc_creator
		rescue
			h[:author] = nil
		end
		# Now find the creation time
		begin
			d = item.dc_date
			h[:creation] = Time.parse(d).getutc.to_i
		rescue
			# RSS 2.0 uses this method
			begin
				d = item.pubDate
				h[:creation] = Time.parse(d).getutc.to_i
			rescue
				h[:creation] = nil
			end
		end
		duuid = DataService.createRemoteDataItem(source.data_type, :string, item.description, { :title => item.title, :grouping => uuid }, source.uuid)
		DataService.modifyDataItem(duuid, :object, h)
		puts "    * Inserted item '#{item.title}'."
	end
end

def main
	puts "MacroDeck Services Remote Data Updater" + NEWLINE
	puts "======================================" + NEWLINE
	
	sources = DataSource.find(:all)
	puts " * #{sources.length} sources exist in the database." + NEWLINE
	sources.each do |source|
		if (Time.now.to_i - source.updated) >= source.update_interval
			# The update interval has passed; fetch the content file.
			puts " ! #{source.title} is out of date, updating..." + NEWLINE
			url = URI.parse(source.uri)
			resource = Net::HTTP.start(url.host, url.port) do |http|
				http.get(url.path, {
					"Accept" => "*/*",
					"User-Agent" => "MacroDeckFeedUpdater/" + UPDATER_VERSION + " (+http://www.macrodeck.com/)"
					})
			end
			case source.file_type.downcase
				when "rss"
					clear_remote_sources(source.uuid)
					insert_rss(resource.body, source)
			end
		end
	end
end

# Run the program
main