# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)


ENV['CURRENT_SERVER'] = Rails::Server.new.server.to_s
ENV['ASYNC_SERVER?'] = 'true' if ENV['CURRENT_SERVER'] == 'Rack::Handler::Thin'

if ENV['ASYNC_SERVER?']
  require 'rack/fiber_pool'


  if ENV['TRACE_FIBERS']
    Fiber.current.instance_variable_set :@name, 'root'
    class Fiber
      def resume_with_logging(*args)
        # puts "Fiber.resume !"
        print ' |--> '
        resume_without_logging(*args)
      end
      alias_method_chain :resume, :logging

      class << self
        def yield_with_logging(*args)
          # puts "Fiber.yield !"
          print ' --][ '
          begin
            raise "miam"
          rescue => e
            e.backtrace[1..9].map do |line|
              puts "\t| #{line}"
            end
          end
          yield_without_logging(*args)
        end
        alias_method_chain :yield, :logging
      end
    end
  end

  require "em-http"
  require "em-net-http"

  use Rack::FiberPool

else
  puts "\n\nHey awesome, take me for a ride in asynchronous land ! \n\tbundle exec rails s thin\n\n\n"
end


run Dummy::Application
