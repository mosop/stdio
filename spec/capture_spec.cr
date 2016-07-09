require "./spec_helper"

module StdioCaptureFeature
  describe name do
    it "captures" do
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

    it "keeps capturing" do
      Stdio.capture do |io|
        STDOUT.puts ":)"
        io.out!.gets.should eq ":)\n"
        STDOUT.puts ":X"
        io.out!.gets.should eq ":X\n"
      end
    end
  end
end
