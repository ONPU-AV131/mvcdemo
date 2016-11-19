require 'rack'

namespace :rack_examples do
    desc "rack examples"
    task "fcgi_simple" do
        # This is the real code:
        rack_proc = lambda {|env| [200, {}, ["Hello. The time is #{Time.now}"]] }
        Rack::Handler::FastCGI.run rack_proc, :Port => 4000
    end

    desc "full object example"
    task "fcgi_simple_object" do
        class RackSimpleClass
            def call(env)
                puts env
                [200, {"Content-Type" => "text/html"}, ["Hello from Rack full object"]]
            end
        end
        Rack::Handler::FastCGI.run RackSimpleClass.new, :Port => 4000
    end
end
