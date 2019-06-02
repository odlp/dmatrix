require "dmatrix/image_tag"

RSpec.describe Dmatrix::ImageTag do
  it "combines the repo name and the values" do
    values = ["ruby:2.6.3", "abc", "123", "foo/bar"]
    image_tag = described_class.new(values: values)

    expect(image_tag.tag).to eq "dmatrix:ruby-2-6-3-abc-123-foo-bar"
  end
end
