require "./spec_helper"

it "Capture" do
  out, err, in = Stdio.capture do |io|
    STDOUT.puts ":)"
    STDERR.puts ":("
    io.in.puts ":P"
    [io.out.gets, io.err.gets, STDIN.gets]
  end
  out.should eq ":)\n"
  err.should eq ":(\n"
  in.should eq ":P\n"
end
