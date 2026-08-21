# frozen_string_literal: true

require "tempfile"

module Meetxt
  class AtomicWriter
    def write(path, content)
      raise OutputExistsError, path if path.exist?

      Tempfile.create([".meetxt-", ".tmp"], path.dirname.to_s, encoding: Encoding::UTF_8) do |file|
        file.write(content)
        file.flush
        file.fsync
        File.link(file.path, path)
      end
      path
    rescue Errno::EEXIST
      raise OutputExistsError, path
    rescue OutputExistsError
      raise
    rescue SystemCallError, IOError
      raise FileWriteError, path
    end
  end
end
