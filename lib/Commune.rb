require 'rubygems'
require 'mechanize'
require 'json'

class Commune
  attr_accessor :name, :canton, :district, :id, :coordinates
  
  def initialize(json)
    # Save coordinates
    @coordinates = []
    json_object = JSON.parse(json)
    json_object2 = JSON.parse(json_object['rows'][0]["features"])
    json_object2["features"][0]["geometry"]["coordinates"].each do |c|
      c.each do |d|
        @coordinates << d
      end
    end
    
    # Save the UID from geoportail
    @id = json_object2["features"][0]["id"]
    
    # Try to get the name from geoportail
    get_details(@coordinates[0][0], @coordinates[0][1])
  end
  
  def get_details(x, y)
    # Warm up `mechanize`
    agent = Mechanize.new
    page = agent.get "http://map.geoportal.lu/bodfeature/search?lang=lu&layers=communes&scale=141732&bbox=#{x},#{y},#{x+500},#{y+500}", nil, "http://map.geoportal.lu/"
    json_object = JSON.parse(page.body)
    json_object["features"].each do |obj|
      if(obj["id"] == @id)
        # Get the string including the HTML
        str = obj["properties"]["html"]
        # Load HTML into Nokogiri
        doc = Nokogiri::HTML(str)
        # Commune name
        @name = doc.css(".tooltip_footer table tr")[0].css("td")[1].content
        # Canton name
        @canton = doc.css(".tooltip_footer table tr")[1].css("td")[1].content
        # District name
        @district = doc.css(".tooltip_footer table tr")[2].css("td")[1].content
      end
    end
  end
  
  def to_s
    "<Commune: ID = #{@id}; name = #{@name}; canton = #{@canton}; district = #{@district}>"
  end
end