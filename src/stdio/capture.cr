module Stdio
  class Capture
    class Out
      @dup : LibC::Int
      @close_on_exec : ::Bool
      @reader : IO::FileDescriptor
      @writer : IO::FileDescriptor
      getter :reader, :writer

      def initialize(@io : ::IO::FileDescriptor)
        @io = io
        @dup = -1
        @close_on_exec = true
        @reader, @writer = IO.pipe
      end

      def capture
        raise "Already captured." if @dup != -1
        @close_on_exec = @io.close_on_exec?
        @dup = C::Lib.dup(@io.fd)
        raise "dup() error." if @dup == -1
        @io.reopen @writer
        @io.close_on_exec = @close_on_exec
      end

      def decapture
        return if @dup == -1
        raise "dup2() error." if ::LibC.dup2(@dup, @io.fd) == -1
        @io.close_on_exec = @close_on_exec
        @dup = -1
      end
    end

    def initialize
      @stdout = Out.new(STDOUT)
      @stderr = Out.new(STDERR)
    end

    def out
      decaptured_out
    end

    def err
      decaptured_err
    end

    def out?
      @stdout.reader
    end

    def err?
      @stderr.reader
    end

    def out!
      @stdout.writer
    end

    def err!
      @stderr.writer
    end

    @decaptured_out : IO::FileDescriptor?
    def decaptured_out
      @decaptured_out ||= begin
        @stdout.decapture
        @stdout.writer.close
        @stdout.reader
      end
    end

    @decaptured_err : IO::FileDescriptor?
    def decaptured_err
      @decaptured_err ||= begin
        @stderr.decapture
        @stderr.writer.close
        @stderr.reader
      end
    end

    def capture(&block)
      @stdout.capture
      @stderr.capture
      begin
        yield
      ensure
        @stdout.decapture
        @stderr.decapture
        @stdout.writer.close
        @stderr.writer.close
        @stdout.reader.close
        @stderr.reader.close
      end
    end
  end
end
