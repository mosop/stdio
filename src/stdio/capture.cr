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

      def uncapture
        return if @dup == -1
        raise "dup2() error." if ::LibC.dup2(@dup, @io.fd) == -1
        @io.close_on_exec = @close_on_exec
        @dup = -1
      end
    end

    alias ReadersType = NamedTuple(out: IO::FileDescriptor, err: IO::FileDescriptor)

    @readers : ReadersType?
    def readers
      @readers ||= begin
        close_writers
        @stdout.uncapture
        @stderr.uncapture
        {out: @stdout.reader, err: @stderr.reader}
      end
    end

    def initialize
      @stdout = Out.new(STDOUT)
      @stderr = Out.new(STDERR)
    end

    def out
      readers[:out]
    end

    def err
      readers[:err]
    end

    def close_writers
      @stdout.writer.close
      @stderr.writer.close
    end

    def close_readers
      @stdout.reader.close
      @stderr.reader.close
    end

    def capture(&block)
      @stdout.capture
      @stderr.capture
      begin
        yield
      ensure
        close_writers
        close_readers
        @stdout.uncapture
        @stderr.uncapture
      end
    end
  end
end
