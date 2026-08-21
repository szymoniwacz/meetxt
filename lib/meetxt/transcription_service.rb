# frozen_string_literal: true

require "pathname"
require "time"

module Meetxt
  class TranscriptionService
    def initialize(provider:, validator: InputValidator.new, renderer: MarkdownRenderer.new,
                   writer: AtomicWriter.new, clock: -> { Time.now })
      @provider = provider
      @validator = validator
      @renderer = renderer
      @writer = writer
      @clock = clock
    end

    def call(input)
      source = @validator.validate!(Pathname(input))
      output = source.sub_ext(".md")
      raise OutputExistsError, output if output.exist?

      transcript = @provider.transcribe(source)
      markdown = @renderer.render(source: source, transcript: transcript, transcribed_at: @clock.call)
      @writer.write(output, markdown)
    end
  end
end
