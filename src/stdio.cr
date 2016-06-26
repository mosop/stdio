require "./stdio/*"

module Stdio
  def self.capture
    io = Capture.new
    io.capture do
      yield io
    end
  end
end
