require "forwardable"
require "shellwords"
require_relative "image_tag"

module Dmatrix
  class Executor
    extend Forwardable

    def initialize(combination:, run_command:, log_dir:, executor: Kernel.method(:system))
      @combination = combination
      @run_command = run_command
      @log_dir = log_dir
      @executor = executor
    end

    def build_run
      run_success = false
      build_success = build

      if build_success
        run_success = run
      end

      Result.new(build_success, run_success, tag)
    end

    private

    attr_reader :combination, :run_command, :log_dir, :executor

    def_delegators :image_tag, :tag

    def build
      executor.call("docker build %{build_args} --tag %{tag} . > #{log_path(type: "build")} 2>&1" % build_params)
    end

    def run
      executor.call("docker run %{env_args} %{tag} %{run_command} > #{log_path(type: "run")} 2>&1" % run_params)
    end

    def build_params
      { tag: tag, build_args: build_args }
    end

    def run_params
      {
        tag: tag,
        env_args: env_args,
        run_command: formatted_run_command,
      }
    end

    def image_tag
      @image_tag ||= ImageTag.new(values: combination.aspects.map(&:value))
    end

    def build_args
      args = combination.aspects.select { |a| a[:type] == "build_arg" }

      if args.empty?
        return ""
      end

      args.map do |build_arg|
        "--build-arg #{build_arg.name}=#{build_arg.value}"
      end.join(" ")
    end

    def env_args
      args = combination.aspects.select { |a| a[:type] == "env" }

      if args.empty?
        return ""
      end

      args.map do |env_arg|
        "--env #{env_arg.name}=#{env_arg.value}"
      end.join(" ")
    end

    def formatted_run_command
      if run_command.nil? || run_command.empty?
        return ""
      end

      Shellwords.join(run_command)
    end

    def log_path(type:)
      File.join(log_dir, "#{type}-#{tag.gsub(":", "-")}.log")
    end

    Result = Struct.new(:build_success, :run_success, :tag) do
      def success?
        build_success && run_success
      end

      def failure?
        !success?
      end
    end
  end
end
