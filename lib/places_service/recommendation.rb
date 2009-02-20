# Ruby class that represents a recommendation for a place/event
class Recommendation
	include Comparable # allow comparing this object with other Recommendations

	attr_reader :recommended_item
	attr_accessor :users_recommending
	attr_accessor :popularity

	# rec = Recommendation.new(item)
	def initialize(recommended_item)
		@recommended_item = recommended_item
		@users_recommending = []
		@popularity = 0
	end

	# If popularity is > 0, we compute the weight as 45% of the popularity number
	# Otherwise, use the length of recommending users.
	def weight
		if popularity > 0
			return ((@popularity * 0.45) + @users_recommending.length)
		else
			return @users_recommending.length
		end
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
