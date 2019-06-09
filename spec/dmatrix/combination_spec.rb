require "dmatrix/combination"

RSpec.describe Dmatrix::Combination do
  describe "#build_args" do
    it "selects aspects of the correct type" do
      aspects = [
        Dmatrix::Combination::Aspect.new("build_arg", "n1", "v1"),
        Dmatrix::Combination::Aspect.new("env", "n2", "v2"),
        Dmatrix::Combination::Aspect.new("build_arg", "n3", "v3"),
        Dmatrix::Combination::Aspect.new("other", "n4", "v4"),
      ]

      combination = described_class.new(aspects)

      expect(combination.build_args).to contain_exactly aspects[0], aspects[2]
    end
  end

  describe "#env_args" do
    it "selects aspects of the correct type" do
      aspects = [
        Dmatrix::Combination::Aspect.new("build_arg", "n1", "v1"),
        Dmatrix::Combination::Aspect.new("env", "n2", "v2"),
        Dmatrix::Combination::Aspect.new("other", "n3", "v3"),
        Dmatrix::Combination::Aspect.new("env", "n4", "v4"),
      ]

      combination = described_class.new(aspects)

      expect(combination.env_args).to contain_exactly aspects[1], aspects[3]
    end
  end
end
