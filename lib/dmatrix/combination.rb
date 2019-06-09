module Dmatrix
  class Combination
    attr_reader :aspects

    def initialize(aspects)
      @aspects = aspects
    end

    def build_args
      aspects.select { |a| a.type == "build_arg" }
    end

    def env_args
      aspects.select { |a| a.type == "env" }
    end

    Aspect = Struct.new(:type, :name, :value)
  end
end
