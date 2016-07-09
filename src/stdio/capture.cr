module Stdio
  struct Capture
    abstract struct Io
      @dup : LibC::Int = -1
      @close_on_exec : Bool = true
      @reader : IO::FileDescriptor
      @writer : IO::FileDescriptor
      getter :io, :reader, :writer

      def initialize(@io : IO::FileDescriptor)
        @reader, @writer = IO.pipe
      end

      def capture
        raise "Already captured." if @dup != -1
        @close_on_exec = @io.close_on_exec?
        @dup = C::Lib.dup(@io.fd)
        raise "dup() error." if @dup == -1
        reopen
        @io.close_on_exec = @close_on_exec
      end

      def decapture
        return if @dup == -1
        raise "dup2() error." if ::LibC.dup2(@dup, @io.fd) == -1
        @io.close_on_exec = @close_on_exec
        @dup = -1
      end
    end

    struct Reader < Io
      def reopen
        io.reopen writer
      end

      def close
        decapture
        reader.close
        writer.close
      end
    end

    struct Writer < Io
      def reopen
        io.reopen reader
      end

      def close
        decapture
        writer.close
        reader.close
      end
    end

    def initialize
      @in = Writer.new(STDIN)
      @out = Reader.new(STDOUT)
      @err = Reader.new(STDERR)
    end

    def in
      @in.writer
    end

    def out
      decaptured_out
    end

    def err
      decaptured_err
    end

    def out!
      @out.reader
    end

    def err!
      @err.reader
    end

    @decaptured_out : IO::FileDescriptor?
    def decaptured_out
      @decaptured_out ||= begin
        @out.decapture
        @out.writer.close
        @out.reader
      end
    end

    @decaptured_err : IO::FileDescriptor?
    def decaptured_err
      @decaptured_err ||= begin
        @err.decapture
        @err.writer.close
        @err.reader
      end
    end

    def capture(&block)
      @in.capture
      @out.capture
      @err.capture
      begin
        yield
      ensure
        @in.close
        @out.close
        @err.close
      end
    end
  end
end
