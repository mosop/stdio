module Stdio
  module C
    lib Lib
      fun dup(oldfd : LibC::Int) : LibC::Int
    end
  end
end
