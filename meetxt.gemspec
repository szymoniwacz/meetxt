# frozen_string_literal: true

require_relative "lib/meetxt/version"

Gem::Specification.new do |spec|
  spec.name = "meetxt"
  spec.version = Meetxt::VERSION
  spec.authors = ["Szymon Iwacz"]
  spec.email = ["szymon@iwacz.pl"]

  spec.summary = "Turn meeting audio into timestamped Markdown transcripts"
  spec.description = "A local-first Ruby CLI that transcribes meeting audio through OpenAI."
  spec.homepage = "https://github.com/szymoniwacz/meetxt"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/main"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["exe/*", "lib/**/*.rb", "LICENSE", "README.md"]
  spec.bindir = "exe"
  spec.executables = ["meetxt"]
  spec.require_paths = ["lib"]

  spec.add_dependency "openai", "~> 0.80.0"
end
