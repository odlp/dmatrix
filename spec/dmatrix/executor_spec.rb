require "dmatrix/executor"
require "dmatrix/matrix"

RSpec.describe Dmatrix::Executor do
  let(:fake_capture2e) { double("Open::#capture2e", call: exec_result) }
  let(:file_writer) { double("File::write", call: true) }
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
      executor: fake_capture2e,
      file_writer: file_writer,
    )
  end

  it "succeeds when the commands succeed" do
    allow(fake_capture2e).to receive(:call).and_return(exec_result(success: true))

    expect(subject.build_run).to be_a_success
  end

  it "builds the image with the supplied BUILD ARGs" do
    subject.build_run

    expect(fake_capture2e).to have_received(:call).twice
    expect(fake_capture2e).to have_received(:call).with(
      "docker",
      "build",
      "--build-arg",
      "BUILD_ARG1=1",
      "--build-arg",
      "BUILD_ARG2=2",
      "--tag",
      "dmatrix:a-b-1-2",
      "."
    )
  end

  it "runs the task with the supplied command and ENV variables" do
    subject.build_run

    expect(fake_capture2e).to have_received(:call).twice
    expect(fake_capture2e).to have_received(:call).with(
      "docker",
      "run",
      "--env",
      "ENV1=a",
      "--env",
      "ENV2=b",
      "dmatrix:a-b-1-2",
      *run_command
    )
  end

  it "writes log files for the build and the run calls" do
    build_result = exec_result(output: "build_output")
    run_result = exec_result(output: "run_output")
    allow(fake_capture2e).to receive(:call).and_return(build_result, run_result)

    subject.build_run

    expect(file_writer).to have_received(:call).once
      .with("/tmp/log/build-dmatrix-a-b-1-2.log", "build_output")

    expect(file_writer).to have_received(:call).once
      .with("/tmp/log/run-dmatrix-a-b-1-2.log", "run_output")
  end

  context "build fails" do
    it "marks the execution as a failure" do
      result = exec_result(success: false)
      allow(fake_capture2e).to receive(:call).and_return(result)

      expect(subject.build_run).to be_a_failure
    end

    it "doesn't run the command" do
      result = exec_result(success: false)
      allow(fake_capture2e).to receive(:call).and_return(result)

      subject.build_run

      expect(fake_capture2e).
        to have_received(:call).once.with("docker", "build", any_args)
    end

    context "run fails" do
      it "marks the execution as a failure" do
        build_result = exec_result(success: true)
        run_result = exec_result(success: false)
        allow(fake_capture2e).to receive(:call).and_return(build_result, run_result)

        expect(subject.build_run).to be_a_failure
        expect(fake_capture2e).to have_received(:call).twice
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

  def exec_result(output: "", success: true)
    status = instance_double(Process::Status, success?: success)
    [output, status]
  end
end
