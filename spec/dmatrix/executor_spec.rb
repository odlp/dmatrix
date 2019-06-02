require "dmatrix/executor"
require "dmatrix/matrix"

RSpec.describe Dmatrix::Executor do
  let(:fake_system) { double("system", call: true) }
  let(:log_dir) { "/tmp/log" }
  let(:run_command) { ["bin/my_program", "commandArg1", "commandArg2"] }
  let(:combination) do
    new_combination(
      env: {
        "ENV1" => "a",
        "ENV2" => "b",
      },
      build_args: {
        "BUILD_ARG1" => "1",
        "BUILD_ARG2" => "2",
      }
    )
  end

  subject do
    described_class.new(
      combination: combination,
      run_command: run_command,
      log_dir: log_dir,
      executor: fake_system,
    )
  end

  it "succeeds when the commands succeed" do
    allow(fake_system).to receive(:call).and_return(true)

    expect(subject.build_run).to be_a_success
  end

  it "builds the image with the supplied BUILD ARGs" do
    subject.build_run

    expect(fake_system).to have_received(:call).twice
    expect(fake_system).to have_received(:call).with(
      [
        "docker build",
        "--build-arg BUILD_ARG1=1",
        "--build-arg BUILD_ARG2=2",
        "--tag dmatrix:a-b-1-2",
        ".",
        "> /tmp/log/build-dmatrix-a-b-1-2.log",
        "2>&1"
      ].join(" ")
    )
  end

  it "runs the task with the supplied command and ENV variables" do
    subject.build_run

    expect(fake_system).to have_received(:call).twice
    expect(fake_system).to have_received(:call).with(
      [
        "docker run",
        "--env ENV1=a",
        "--env ENV2=b",
        "dmatrix:a-b-1-2",
        *run_command,
        "> /tmp/log/run-dmatrix-a-b-1-2.log",
        "2>&1"
      ].join(" ")
    )
  end

  context "build fails" do
    it "marks the execution as a failure" do
      allow(fake_system).to receive(:call).and_return(false)

      expect(subject.build_run).to be_a_failure
    end

    it "doesn't run the command" do
      allow(fake_system).to receive(:call).and_return(false)

      subject.build_run

      expect(fake_system).to have_received(:call).once
      expect(fake_system).to have_received(:call).with(starting_with("docker build"))
    end

    context "run fails" do
      it "marks the execution as a failure" do
        allow(fake_system).to receive(:call).and_return(true, false)

        expect(subject.build_run).to be_a_failure
        expect(fake_system).to have_received(:call).twice
      end
    end
  end

  private

  def new_combination(env: {}, build_args: {})
    Dmatrix::Matrix::Combination.new(
      env.map { |name, value| new_aspect("env", name, value) } +
      build_args.map { |name, value| new_aspect("build_arg", name, value) }
    )
  end

  def new_aspect(*args)
    Dmatrix::Matrix::Aspect.new(*args)
  end
end
