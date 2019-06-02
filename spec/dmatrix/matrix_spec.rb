require "dmatrix/matrix"

RSpec.describe Dmatrix::Matrix do
  it "produces combinations from each series of values" do
    input = {
      build_arg: {
        arg1: ["1a", "1b"],
        arg2: ["2a", "2b", "2c"],
      },
      env: {
        env3: ["3a", "3b"],
      }
    }

    combinations = described_class.new(input).combinations

    expect(combinations.length).to eq 12
    expect(combinations.uniq).to eq combinations

    expect(combinations.first.aspects).to eq [
      new_aspect(:build_arg, :arg1, "1a"),
      new_aspect(:build_arg, :arg2, "2a"),
      new_aspect(:env, :env3, "3a"),
    ]

    expect(combinations.last.aspects).to eq [
      new_aspect(:build_arg, :arg1, "1b"),
      new_aspect(:build_arg, :arg2, "2c"),
      new_aspect(:env, :env3, "3b"),
    ]
  end

  private

  def new_aspect(*args)
    Dmatrix::Matrix::Aspect.new(*args)
  end
end
