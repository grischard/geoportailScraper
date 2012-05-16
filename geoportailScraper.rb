# Load gems
require 'rubygems'
require 'trollop'
require 'mechanize'
require 'json'
require 'active_support'

# Define class loading path
$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), 'lib' ) )

# Load classes
require 'commune'

# Define some constants
VERSION = '0.1'
ROOT_URL = 'http://map.geoportal.lu/'

# Define the standard logger
# logger = Logger.new $stdout

# Define the options that will be accepted by geoportailScraper
opts = Trollop::options do
  version "geoportailScraper #{VERSION} CC-BY 2012 Sven Clement"
  opt :start, "Lowest ID of a commune to start with", :type => :int, :default => 1
  opt :end, "Highest ID of a commune to end with", :type => :int, :default => 106
end

# Verify that only valid parameters will be accepted before continuing
Trollop::die :start, "must be non-negative" if opts[:start] < 0
Trollop::die :start, "must be smaller than argument --end" if opts[:start] > opts[:end]
Trollop::die :end, "must be non-negative" if opts[:end] < 0
Trollop::die :end, "must be smaller than 106 due to the number of communes in Luxembourg" if opts[:end] > 106

# Warm up `mechanize`
agent = Mechanize.new
agent.get ROOT_URL

# Iterate through all the communes
communes = []
(opts[:start]..opts[:end]).each do |i|
  js = agent.get "http://map.geoportal.lu/bodfeature/geometry?layers=communes&ids=#{i}&ref=geoadmin&cb=mapFishApiPool.apiRefs%5B0%5D.showFeaturesCb&_dc=1337198437952&callback=stcCallback1001", nil, "http://map.geoportal.lu/?communes=#{i}&lang=lb"
  # Remove the JS function name to get clean JSON
  js.body.gsub!("mapFishApiPool.apiRefs[0].showFeaturesCb(", "").gsub!(");", "")
  c = Commune.new(js.body)
  communes << c
end

# Iterate over the results and output them
j = ActiveSupport::JSON
communes.each do |c|
  puts j.encode(c)
end