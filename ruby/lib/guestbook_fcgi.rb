#!/usr/bin/env ruby

require 'rack'

require 'cgi'
require 'csv'
require 'json'

cgi = CGI.new
params = Hash[ cgi.params.map {|k,v| [k.to_sym,CGI::escapeHTML(v.join)]}]
puts cgi.header

guest_records_path = '/srv/www/mvcdemo.onpu/private/guest_records.csv'
guest_records_mandatory_columns = [:name, :email, :city, :country, :comments ]
guest_records_optional_columns = [:state, :url]
guest_records_columns = guest_records_mandatory_columns + guest_records_optional_columns

#####  Process params, save new records,  search for missing fields
have_errors = false
errors = '<div class="alert alert-danger" role="alert"><strong>Ups, you missed these fields:</strong><ul>'
if ENV['REQUEST_METHOD'] == 'POST'
    guest_records_mandatory_columns.each do |column|
        if !params[column] || params[column].empty?
            have_errors = true
            errors += "<li>#{column.to_s.upcase}</li>"
        end
    end


    unless have_errors
        new_record = guest_records_columns.map { |column| params[column] }
        CSV.open(guest_records_path, "ab") do |csv|
            csv << new_record
        end
    end
end
errors += "</ul></div>"

#####  Get saved records
records = "<div>"
if File.exists? guest_records_path
    CSV.foreach guest_records_path do |row|
        record = Hash[ guest_records_columns.each_index.map {|i| [guest_records_columns[i], row[i]]} ]
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

###### header
head = '
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Guestbook</title>
    <link href="/css/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <style>
    .panel-title a {
        color: #337ab7;
    }
    .control-label.required:after {
        content: " *";
        color: red;
    }
    </style>
</head>
'
header = ''

##### footer
footer = '<h6> (c) 2016, Vasyl Lytovchenko, mvcdemo.onpu</h6>'

##### form
form = '
<div class="container">
    <div class="">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">add to our guestbook</h3>
                Fill in the blanks below to add to our guestbook. The only blanks that you have to fill in are the comments and name section. Thanks!</div>
            <div class="panel-body">
                <form method="POST" class="form-horizontal">
                    <div class="form-group">
                        <label for="name" class="control-label col-sm-2 required">Name:</label>
                        <div class="col-sm-8">
                            <input type = "text" class="form-control" id="name" name="name" required="true">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="email" class="control-label col-sm-2 required">E-Mail:</label>
                        <div class="col-sm-8">
                            <input type = "email" class="form-control" id="email" name="email" required="true">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="url" class="control-label col-sm-2">URL: </label>
                        <div class="col-sm-8">
                            <input type = "url" class="form-control" id="url" name="url">
                        </div>
                    </div>

                    <div class="col-sm-12 form-group">
                        <label for="city" class="control-label col-sm-2 required" required>City: </label>
                        <div class="col-sm-2">
                            <input type = "text" class="form-control" id="city" name="city" size="10" required="true">
                        </div>

                        <label for="state" class="control-label col-sm-1">State: </label>
                        <div class="col-sm-1">
                            <input type = "text" class="form-control" id="state" name="state" size="2">
                        </div>

                        <label for="country" class="control-label col-sm-2 required">Country: </label>
                        <div class="col-sm-2">
                            <input type = "text" class="form-control" id="country" name = "country" size="15" required="true">
                        </div>
                    </div>

                    <div class="col-sm-10">
                        <div class="form-group">
                            <label for="comments" class="control-label col-sm-3 required">Comments: </label>
                            <div class="col-sm-8">
                                <textarea class="form-control" id="comments" name="comments"></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-10">
                        <button type = "reset" class="btn btn-danger"> Reset </button>
                        <button type = "submit" class="btn btn-primary"> Submit </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
'
saved_form_values = "<script>";
saved_form_values += 'saved_form_values = new Map(' + JSON.generate(params.map{|k,v| [k,v]}) + ');';
saved_form_values += '
    function restoreValues(value, key, map){
        document.getElementById(key).setAttribute("value", value);
    }
    saved_form_values.forEach(restoreValues);
'
saved_form_values += "</script>"

##### output everything
puts "#{head}<html><body>#{header}#{ errors if have_errors}#{form}#{records}#{footer}#{saved_form_values}</body></html>"
