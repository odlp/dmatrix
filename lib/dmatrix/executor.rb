require "forwardable"
require "open3"
require "shellwords"
require_relative "image_tag"

module Dmatrix
  class Executor
    extend Forwardable

    def self.build(combination:, run_command:, log_dir:)
      new(
        combination: combination,
        run_command: run_command,
        log_dir: log_dir,
        executor: Open3.method(:capture2e),
        file_writer: File.method(:write),
      )
    end

    def initialize(combination:, run_command:, log_dir:, executor:, file_writer:)
      @combination = combination
      @run_command = run_command
      @log_dir = log_dir
      @executor = executor
      @file_writer = file_writer
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

    attr_reader :combination, :run_command, :log_dir, :executor, :file_writer

    def_delegators :image_tag, :tag

    def build
      output, status = perform_build
      file_writer.call(log_path(type: "build"), output)
      status.success?
    end

    def perform_build
      executor.call(
        "docker",
        "build",
        *build_args,
        "--tag",
        tag,
        ".",
      )
    end

    def run
      output, status = perform_run
      file_writer.call(log_path(type: "run"), output)
      status.success?
    end

    def perform_run
      executor.call(
        "docker",
        "run",
        *env_args,
        tag,
        *run_command
      )
    end

    def image_tag
      @image_tag ||= ImageTag.new(values: combination.aspects.map(&:value))
    end

    def build_args
      args = combination.aspects.select { |a| a[:type] == "build_arg" }

      if args.empty?
        return []
      end

      args.flat_map do |build_arg|
        ["--build-arg", "#{build_arg.name}=#{build_arg.value}"]
      end
    end

    def env_args
      args = combination.aspects.select { |a| a[:type] == "env" }

      if args.empty?
        return []
      end

      args.flat_map do |env_arg|
        ["--env", "#{env_arg.name}=#{env_arg.value}"]
      end
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
