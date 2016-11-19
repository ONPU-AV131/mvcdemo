#!/usr/bin/env ruby

require 'rack'
require 'erb'

require 'cgi'
require 'csv'
require 'json'

class Record
    attr_reader :have_errors
    @@guest_records_path = '/srv/www/mvcdemo.onpu/private/guest_records.csv'
    @@guest_records_mandatory_columns = [:name, :email, :city, :country, :comments ]
    @@guest_records_optional_columns = [:state, :url]
    @@guest_records_columns = @@guest_records_mandatory_columns + @@guest_records_optional_columns

    def initialize(params)
        @have_errors = false
        @errors = '<div class="alert alert-danger" role="alert"><strong>Ups, you missed these fields:</strong><ul>'


        @@guest_records_mandatory_columns.each do |column|
            if !params[column] || params[column].empty?
                @have_errors = true
                @errors += "<li>#{column.to_s.upcase}</li>"
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

    def errors
        @have_errors ? @errors + "</ul></div>" : nil
    end

    def self.all
        records = "<div>"
        if File.exists? @@guest_records_path
            CSV.foreach @@guest_records_path do |row|
                record = Hash[ @@guest_records_columns.each_index.map {|i| [@@guest_records_columns[i], row[i]]} ]
                records += "<div class='container'>
                    <div class='panel panel-default'>
                    <div class='panel-heading'>
                        <h4 class='panel-title'>
                        "

                        records += if record[:url].empty?
                                       "#{record[:name]} (#{record[:email]})"
                                   else
                                       "<a href=#{record[:url]}>  #{record[:name]} </a> (#{record[:email]})"
                                   end

                        records +="</h4>
                        <strong> From: </strong> #{record[:city]}, #{record[:state] + ',' unless record[:state].empty?} #{record[:country]}
                    </div>

                    <div class='panel-body'>
                        #{record[:comments]}
                    </div>
                    </div>
                </div>
                "
            end
        end
        records += "</div>"
        records

    end
end


class GuestbookApp
    def initialize
        @guest_records_path = '/srv/www/mvcdemo.onpu/private/guest_records.csv'
        @guest_records_mandatory_columns = [:name, :email, :city, :country, :comments ]
        @guest_records_optional_columns = [:state, :url]
        @guest_records_columns = @guest_records_mandatory_columns + @guest_records_optional_columns
    end

    def call(env)
        p env

        request = Rack::Request.new(env)
        @params = Hash[ request.params.map {|k, v| [k.to_sym, v] }]



        #####  Process params, save new records,  search for missing fields
        if env['REQUEST_METHOD'] == 'POST'
             record = Record.new @params
             if !record.have_errors
               record.save
             else
               errors = record.errors
             end
        end

        ##### output everything
        #response =  "#{head}<html><body>#{ errors if errors}#{form}#{records}#{footer}#{saved_form_values}</body></html>"
        response = render
        [200, {"Content-Type" => "text/html"}, [response]]
    end

    def render
        template = File.read('/srv/www/mvcdemo.onpu/ruby/templates/guestbook.html.erb')
        ERB.new(template).result(binding)
    end

    private

    def records
        Record.all
    end

end
