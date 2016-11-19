#!/usr/bin/env ruby

require 'erb'

name = "Whatznear";
puts ERB.new("<h1>Hello ERB World!! </h1><h3><%= name %></h3>").result(binding)




