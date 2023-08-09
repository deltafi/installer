#!/usr/bin/env ruby
# frozen_string_literal: true

if ARGV.size != 1
  puts "USAGE: #{__FILE__} version"
  exit 1
end

version = ARGV.first
values_file = File.join(__dir__, 'deltafi', 'values.yaml')
values = File.read(values_file)
%w[api auth core core-actions egress-sink ingress nodemonitor].each do |image|
  values.gsub!(/image: .*deltafi-#{image}:.*$/, "image: deltafi-#{image}:#{version}")
end

File.write(values_file, values)
