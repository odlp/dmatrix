RSpec.describe "dmatrix logs" do
  let(:session) { JetBlack::Session.new }

  it "writes logs to a temporary folder" do
    session.create_file "Dockerfile", <<~DOCKERFILE
      ARG FROM_IMAGE=ruby:2.6-alpine
      FROM $FROM_IMAGE
    DOCKERFILE

    session.create_file ".matrix.yaml", <<~YAML
      matrix:
        build_arg:
          FROM_IMAGE:
            - ruby:2.5-alpine
            - ruby:2.6-alpine
    YAML

    expect(session.run("bundle exec dmatrix -- ruby -v")).to be_a_success

    expect(contents_of_first_match("tmp/dmatrix/build*2.5*.log")).to_not be_empty
    expect(contents_of_first_match("tmp/dmatrix/build*2.6*.log")).to_not be_empty

    expect(contents_of_first_match("tmp/dmatrix/run*2.5*.log")).to start_with "ruby 2.5"
    expect(contents_of_first_match("tmp/dmatrix/run*2.6*.log")).to start_with "ruby 2.6"
  end

  private

  def contents_of_first_match(path)
    path = Dir.glob(File.join(session.directory, path)).first
    expect(path).to_not be_nil

    File.read(path)
  end
end
