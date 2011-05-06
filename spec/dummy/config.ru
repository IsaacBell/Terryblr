# This file is used by Rack-based servers to start the application.
puts ">> config.ru"

puts "Requiring envitonment.rb..."
require ::File.expand_path('../config/environment',  __FILE__)
puts "Envitonment.rb loaded..."


if defined? Thin
  puts "Thin detected."
  require 'rack/fiber_pool'
  puts "Removing Rack::Lock from the middleware list"
  Dummy::Application.config.middleware.delete Rack::Lock

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

  use Rack::CommonLogger
  use Rack::ShowExceptions
  use Rack::FiberPool

else
  puts "\n\nHey awesome, take me for a ride in asynchronous land ! \n\tbundle exec rails s thin\n\n\n"
end

puts "Rails Middleware stack: #{Dummy::Application.config.middleware.inspect}"

puts "Applicaiton Run !"
run Dummy::Application
puts "<< config.ru"
