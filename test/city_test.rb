require 'test_helper'
require 'services'
Services.startService("uuid_service")
Services.startService("data_service")
Services.startService("places_service")

class CityTest < Test::Unit::TestCase
	fixtures :data_groups, :categories

	def test_00_uuids
		assert_equal CREATOR_MACRODECK,	"7b7e7c62-0a56-4785-93d5-6e689c9793c9"
		assert_equal DTYPE_PLACE,		"76d337ea-2475-4fe5-8ab5-6389a7bd4405"
		assert_equal DTYPE_CITY,		"b9291eac-c591-41ee-b3cd-d892ae6a9530"
	end

	def test_01_cities_exist
		assert_equal 2, City.count, "Fixtures not properly loaded?"
	end

	def test_02_creation
		c = PlacesService.createCity("Okmulgee", "OK")
		assert_equal c.title, "Okmulgee"
		assert_equal c.groupingtype, DTYPE_CITY, "Grouping <#{c.groupingtype}> is not constant <#{DTYPE_CITY}>."
		assert_equal c.creator, CREATOR_MACRODECK, "Creator <#{c.creator}> is not constant <#{CREATOR_MACRODECK}>."
		assert_equal c.owner, CREATOR_MACRODECK, "Owner <#{c.owner}> is not constant <#{CREATOR_MACRODECK}>."
		assert_equal c.state, "Oklahoma", "State is not Oklahoma"
		assert_equal c.state(:abbreviation => true), "OK"
	end

	def test_03_place_creation
		c = PlacesService.createCity("Okmulgee", "OK")
		assert_equal c.places?, false
		p = c.create_place({ :title => "Kirby's Cafe", :description => "Good home cooking"})
		# Now that we have a valid place, this should return true
		assert_equal c.places?, true
		# The following should be equal to one another
		assert_equal p.title, "Kirby's Cafe"
		assert_equal c.places[0].title, "Kirby's Cafe"
		# Set some metadata using a hash
		p.place_metadata = { :address => "6th Street", :phone_number => "(918) 666-6666", :type => :restaurant, :restaurant_has_carryout => true }
		assert_equal p.place_metadata[:address], "6th Street"
		assert_equal p.place_metadata[:phone_number], "(918) 666-6666"
		assert_equal p.place_metadata[:type], :restaurant
		assert_equal p.place_metadata[:restaurant_has_carryout], true
		# Set the same metadata using a PlaceMetadata object
		pmd = PlaceMetadata.new
		pmd.address = "6th Street"
		pmd.phone_number = "(918) 666-6666"
		pmd.type = :restaurant
		pmd.restaurant_has_carryout = true
		p.place_metadata = pmd
		# Test it has the same values
		assert_equal p.place_metadata[:address], "6th Street"
		assert_equal p.place_metadata[:phone_number], "(918) 666-6666"
		assert_equal p.place_metadata[:type], :restaurant
		assert_equal p.place_metadata[:restaurant_has_carryout], true
		p.save!
	end
end
