# Ruby class that represents a recommendation for a place/event
class Recommendation
	include Comparable # allow comparing this object with other Recommendations

	attr_reader :recommended_item
	attr_accessor :users_recommending

	# rec = Recommendation.new(item)
	def initialize(recommended_item)
		@recommended_item = recommended_item
		@users_recommending = []
	end

	# Currently calculates this item's weight by the length of the users recommending array
	# This will be extended in the future.
	def weight
		return @users_recommending.length
	end

	# Handle comparisons
	def <=>(other_obj)
		if other_obj.respond_to?(:weight) && other_obj.weight > self.weight
			return -1
		elsif other_obj.respond_to?(:weight) && other_obj.weight < self.weight
			return 1
		elsif other_obj.respond_to?(:weight) && other_obj.weight == self.weight
			# since we're the same weight, sort by to_s
			if other_obj.to_s > self.to_s
				return -1
			elsif other_obj.to_s < self.to_s
				return 1
			else
				return 0
			end
		else
			raise ArgumentError, "Can't compare Recommendation against something that isn't a Recommendation"
		end
	end

	# String representation
	def to_s
		return "#{recommended_item.to_s} (weight: #{weight})"
	end

	# Inspect method
	def inspect
		return "#<Recommendation:#{self.to_s}>"
	end
end
