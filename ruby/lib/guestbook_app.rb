
require 'rack'
require 'erb'
require 'json'

require 'record'
require 'guestbook_config'

class GuestbookApp

    def call(env)
        @env = env
        @params = request_params

        @missing_fields = []
        if is_POST_request?
            record = Record.new @params
            if record.have_missing_fields?
                @missing_fields = record.missing_fields
            else
                record.save
            end
        end

        @records = Record.all

        response = render
        [200, {"Content-Type" => "text/html"}, [response]]
    end

    def render
        template = File.read(GuestBookConfig.instance.template_dir + '/guestbook.html.erb')
        ERB.new(template).result(binding)
    end

    private
    def request_params
        request = Rack::Request.new(@env)
        Hash[ request.params.map {|k, v| [k.to_sym, v] }]
    end

    def is_POST_request?
        @env['REQUEST_METHOD'] == 'POST'
    end
end
