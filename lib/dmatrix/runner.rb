require "fileutils"
require "parallel"
require "yaml"

require_relative "executor"
require_relative "logger"
require_relative "matrix"

module Dmatrix
  class Runner
    def initialize(options:, run_command:, logger: Logger.new)
      @options = options
      @run_command = run_command
      @logger = logger
    end

    def call
      reset_log_dir

      results = Parallel.map(combinations, in_threads: 4) do |combination|
        Executor.new(
          combination: combination,
          run_command: run_command,
          log_dir: log_dir
        ).build_run.tap do |result|
          logger.log_result(result)
        end
      end

      if results.any?(&:failure?)
        exit(1)
      end
    end

    private

    attr_reader :options, :run_command, :logger

    def combinations
      Matrix.new(input_combinations).combinations
    end

    def input_combinations
      YAML.load_file(matrix_path).fetch("matrix")
    end

    def matrix_path
      options.fetch(:matrix)
    end

    def reset_log_dir
      FileUtils.mkdir_p(log_dir)
      FileUtils.rm_r(log_files)
    end

    def log_dir
      options.fetch(:log_dir)
    end

    def log_files
      Dir.glob(File.join(log_dir, "*.log"))
    end
  end
end
