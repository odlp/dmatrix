module Dmatrix
  class Logger
    def initialize(std_out: STDOUT)
      @std_out = std_out
    end

    def log_result(result)
      message = [
        result.tag,
        format_status("Build", result.build_success),
        format_status("Run", result.run_success)
      ]

      std_out.puts(message.join("\t"))
    end

    private

    attr_reader :std_out

    def format_status(label, success)
      if success
        "#{label}: #{green('success')}"
      else
        "#{label}: #{red('failure')}"
      end
    end

    def red(text)
      "\e[31m#{text}\e[0m"
    end

    def green(text)
      "\e[32m#{text}\e[0m"
    end
  end
end
