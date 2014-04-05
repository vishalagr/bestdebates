if RUBY_PLATFORM =~ /win/
  p '[NOTICE] win_platform_compatibility loading..'

  begin
    require 'win32/open3' # gem install win32-open3
  rescue LoadError
    begin
      gem 'win32-open3'
    rescue Gem::LoadError
      puts "Install the win32-open3"
    end
  end
  
  module YUI
    class Compressor
      def compress(stream_or_string)
        streamify(stream_or_string) do |stream|
  #        Open3.popen3(*command) do |stdin, stdout, stderr|
          Open3.popen3(command.join(' ')) do |stdin, stdout, stderr|
            begin
              transfer(stream, stdin)

              if block_given?
                yield stdout
              else
                stdout.read
              end

            rescue Exception => e
              raise RuntimeError, "compression failed"
            end
          end
        end
      end
    end
  end

  module Closure
    class Compiler
      def compile(io)
#        Open3.popen3(*command) do |stdin, stdout, stderr|
        Open3.popen3(command.join(' ')) do |stdin, stdout, stderr|
          if io.respond_to? :read
            while buffer = io.read(4096) do
              stdin.write(buffer)
            end
          else
            stdin.write(io.to_s)
          end
          stdin.close
          block_given? ? yield(stdout) : stdout.read
        end
      end
    end
  end
  
end