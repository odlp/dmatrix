RSpec.describe "dmatrix exit status" do
  let(:session) { JetBlack::Session.new }

  it "exits with a non-zero status if a build fails" do
    session.create_file "Dockerfile", <<~DOCKERFILE
      ARG FROM_IMAGE=ruby:2.6-alpine
      FROM $FROM_IMAGE
    DOCKERFILE

    session.create_file ".matrix.yaml", <<~YAML
      matrix:
        build_arg:
          FROM_IMAGE:
            - ruby:2.5-alpine
            - ruby:2.99-alpine
    YAML

    expect(session.run("bundle exec dmatrix -- ruby -v")).to be_a_failure

    expect(contents_of_first_match("tmp/dmatrix/build*2.99*.log")).
      to include "manifest for ruby:2.99-alpine not found"
  end

  it "exits with a non-zero status if a run command fails" do
    session.create_file "Dockerfile", <<~DOCKERFILE
      ARG FROM_IMAGE=ruby:2.6-alpine
      FROM $FROM_IMAGE
    DOCKERFILE

    session.create_file ".matrix.yaml", <<~YAML
      matrix:
        build_arg:
          FROM_IMAGE:
            - ruby:2.5-alpine
    YAML

    expect(session.run("bundle exec dmatrix -- ruby foo")).to be_a_failure

    expect(contents_of_first_match("tmp/dmatrix/run*2.5*.log")).
      to include "No such file or directory -- foo"
  end

  private

  def contents_of_first_match(path)
    path = Dir.glob(File.join(session.directory, path)).first
    expect(path).to_not be_nil

    File.read(path)
  end
end
