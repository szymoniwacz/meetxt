# frozen_string_literal: true

RSpec.describe Meetxt::AtomicWriter do
  subject(:writer) { described_class.new }

  around do |example|
    Dir.mktmpdir do |directory|
      @directory = Pathname(directory)
      example.run
    end
  end

  it "writes a complete UTF-8 file" do
    path = @directory.join("meeting.md")

    expect(writer.write(path, "# Héllo\n")).to eq(path)
    expect(path.binread.force_encoding(Encoding::UTF_8)).to eq("# Héllo\n")
    expect(@directory.children.map(&:basename)).to contain_exactly(Pathname("meeting.md"))
  end

  it "never overwrites an existing file" do
    path = @directory.join("meeting.md")
    path.write("original")

    expect { writer.write(path, "replacement") }.to raise_error(Meetxt::OutputExistsError)
    expect(path.read).to eq("original")
  end

  it "leaves no target or temporary file when publication fails" do
    path = @directory.join("meeting.md")
    allow(File).to receive(:link).and_raise(Errno::EACCES)

    expect { writer.write(path, "content") }.to raise_error(Meetxt::FileWriteError)
    expect(path).not_to exist
    expect(@directory.children).to be_empty
  end
end
