require "dmatrix/executor"
require "dmatrix/logger"
require "support/output_capturer"

RSpec.describe Dmatrix::Logger do
  let(:output) { OutputCapturer.new }

  subject { described_class.new(std_out: output) }

  it "formats successes in green" do
    result = instance_double(
      Dmatrix::Executor::Result,
      build_success: true,
      run_success: true,
      tag: "tag"
    )

    subject.log_result(result)

    expect(output.captures.first).
      to eq "tag\tBuild: \e[32msuccess\e[0m\tRun: \e[32msuccess\e[0m"
  end

  it "formats failures in red" do
    result = instance_double(
      Dmatrix::Executor::Result,
      build_success: false,
      run_success: false,
      tag: "tag"
    )

    subject.log_result(result)

    expect(output.captures.first).
      to eq "tag\tBuild: \e[31mfailure\e[0m\tRun: \e[31mfailure\e[0m"
  end
end
