require 'rubygems'
require 'trollop'

# Define the options that will be accepted by geoportailScraper
opts = Trollop::options do
  version "geoportailScraper 0.1 CC-BY 2012 Sven Clement"
  opt :start, "Lowest ID of a commune to start with", :type => :int, :default => 1
  opt :end, "Highest ID of a commune to end with", :type => :int, :default => 106
end

# Verify that only valid parameters will be accepted before continuing
Trollop::die :start, "must be non-negative" if opts[:start] < 0
Trollop::die :start, "must be smaller than argument --end" if opts[:start] > opts[:end]
Trollop::die :end, "must be non-negative" if opts[:end] < 0
Trollop::die :end, "must be smaller than 106 due to the number of communes in Luxembourg" if opts[:end] > 106

