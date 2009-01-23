require 'test_helper'
require 'services'
Services.startService("uuid_service")
Services.startService("data_service")
Services.startService("places_service")

class RecommendationTest < Test::Unit::TestCase
	def test_00_sort_behavior
		# default, equal weights
		r1 = Recommendation.new("test 1")
		r2 = Recommendation.new("test 2")
		r3 = Recommendation.new("test 3")
		assert r1 < r2
		assert r1 < r3
		assert r2 < r3
		
		# increase weight.
		r1.users_recommending << "User One"
		assert r1 > r2
		r2.users_recommending << "User Two"
		assert r1 < r2
		r3.users_recommending << "User One"
		r3.users_recommending << "User Two"
		assert r1 < r3
		assert r2 < r3
	end
end

