
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dmatrix/version"

Gem::Specification.new do |spec|
  spec.name = "dmatrix"
  spec.version = Dmatrix::VERSION
  spec.authors = ["Oliver Peate"]

  spec.summary       = "Docker matrix runner with parallel execution"
  spec.homepage      = "https://github.com/odlp/dmatrix"
  spec.license       = "MIT"

  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.8"
end
