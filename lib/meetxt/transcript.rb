# frozen_string_literal: true

module Meetxt
  Segment = Data.define(:start, :text)
  Transcript = Data.define(:provider, :model, :segments, :duration)
end
