module Dmatrix
  class ImageTag
    def initialize(values:)
      @values = values
    end

    def tag
      "#{repo}:#{combination_tag}"
    end

    private

    attr_reader :values

    INVALID_CHARS = /[^\w\-]/
    private_constant :INVALID_CHARS

    def repo
      File.split(Dir.pwd).last
    end

    def combination_tag
      values.join("-").gsub(INVALID_CHARS, "-")
    end
  end
end
