# frozen_string_literal: true

require "open3"
require "rbconfig"

RSpec.describe "meetxt executable" do
  let(:executable) { File.expand_path("../../exe/meetxt", __dir__) }

  it "loads from the repository and prints its version" do
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      "-Ilib",
      executable,
      "--version",
      chdir: File.expand_path("../..", __dir__)
    )

    expect(status).to be_success
    expect(stdout).to eq("meetxt #{Meetxt::VERSION}\n")
    expect(stderr).to be_empty
  end

  it "returns a nonzero status and concise usage for an invalid command" do
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      "-Ilib",
      executable,
      "invalid",
      chdir: File.expand_path("../..", __dir__)
    )

    expect(status.exitstatus).to eq(64)
    expect(stdout).to be_empty
    expect(stderr).to eq(Meetxt::CLI::USAGE)
  end
end
