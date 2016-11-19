#!/usr/bin/env ruby

require 'rack'
require 'erb'

require 'cgi'
require 'csv'
require 'json'

class GuestBookConfig
    include Singleton
    attr_reader :guest_records_path, :guest_records_mandatory_columns, :guest_records_optional_columns, :guest_records_columns,:template_dir
    def initialize
        @guest_records_path = '/srv/www/mvcdemo.onpu/private/guest_records.csv'
        @guest_records_mandatory_columns = [:name, :email, :city, :country, :comments ]
        @guest_records_optional_columns = [:state, :url]
        @guest_records_columns = @guest_records_mandatory_columns + @guest_records_optional_columns
        @template_dir = '/srv/www/mvcdemo.onpu/ruby/templates'
    end

end

class Record
    attr_reader :missing_fields

    @@config = GuestBookConfig.instance

    def initialize(params)
        check_missing_fields(params)

        unless have_missing_fields?
            @new_record = @@config.guest_records_columns.map { |column| params[column] }
            return @new_record
        end
        return nil
    end

    def save
        unless have_missing_fields?
            CSV.open(@@config.guest_records_path, "ab") do |csv|
                csv << @new_record
            end
        end
    end

    def have_missing_fields?
        !@missing_fields.empty?
    end

    def self.all
        records = []
        if File.exists? @@config.guest_records_path
            CSV.foreach @@config.guest_records_path do |row|
                record = Hash[ @@config.guest_records_columns.each_index.map {|i| [@@config.guest_records_columns[i], row[i]]} ]
                records.push record
            end
        end
        records
    end

    private
    def check_missing_fields(params)
        @missing_fields = []
        @@config.guest_records_mandatory_columns.each do |column|
            if !params[column] || params[column].empty?
                @missing_fields.push column
            end
        end
    end
end


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
