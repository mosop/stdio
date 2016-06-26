require "./spec_helper"

it "Capture" do
  out, err = Stdio.capture do |io|
    STDOUT.puts ":)"
    STDERR.puts ":("
    [io.out.gets, io.err.gets]
  end
  out.should eq ":)\n"
  err.should eq ":(\n"
end
