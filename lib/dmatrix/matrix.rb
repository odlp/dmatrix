module Dmatrix
  class Matrix
    def initialize(input)
      @input = input
    end

    def combinations
      dimensions = []

      input.each do |type, dimension_group|
        dimension_group.each do |(name, values)|
          dimensions << values.map { |value| Aspect.new(type, name, value) }
        end
      end

      dimensions.first.product(*dimensions.drop(1)).map do |aspects|
        Combination.new(aspects)
      end
    end

    private

    attr_reader :input

    Combination = Struct.new(:aspects)
    Aspect = Struct.new(:type, :name, :value)
  end
end
