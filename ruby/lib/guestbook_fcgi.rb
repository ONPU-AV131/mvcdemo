#!/usr/bin/env ruby

require 'rack'
require 'erb'

require 'cgi'
require 'csv'
require 'json'

class Record
    attr_reader :have_errors, :missing_fields
    @@guest_records_path = '/srv/www/mvcdemo.onpu/private/guest_records.csv'
    @@guest_records_mandatory_columns = [:name, :email, :city, :country, :comments ]
    @@guest_records_optional_columns = [:state, :url]
    @@guest_records_columns = @@guest_records_mandatory_columns + @@guest_records_optional_columns

    def initialize(params)
        @have_errors = false
        @errors = ''

        @missing_fields = []

        @@guest_records_mandatory_columns.each do |column|
            if !params[column] || params[column].empty?
                @have_errors = true
                @missing_fields.push column
            end
        end

        unless have_errors
            @new_record = @@guest_records_columns.map { |column| params[column] }
            return @new_record
        end
        return nil
    end

    def save
        unless @have_errors
            CSV.open(@@guest_records_path, "ab") do |csv|
                csv << @new_record
            end
        end
    end

    def have_missing_fields?
        !@missing_fields.empty?
    end

    def self.all
        records = []
        if File.exists? @@guest_records_path
            CSV.foreach @@guest_records_path do |row|
                record = Hash[ @@guest_records_columns.each_index.map {|i| [@@guest_records_columns[i], row[i]]} ]
                records.push record
            end
        end
        records
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
        template = File.read('/srv/www/mvcdemo.onpu/ruby/templates/guestbook.html.erb')
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
