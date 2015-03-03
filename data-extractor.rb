require 'nokogiri'
require 'open-uri'
require 'csv'
require 'pg'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'postgresql',
  host:     'localhost',
  database: 'anonynoob',
  username: 'postgres'
)


class Match < ActiveRecord::Base
end


match_id = 1290371320
matches_recorded = 0


while matches_recorded < 3000 do

  puts "Opening Match ID: http://www.dotabuff.com/matches/"+match_id.to_s

  begin
  doc = Nokogiri::HTML(open('http://www.dotabuff.com/matches/'+match_id.to_s))

    match = Match.new
    match.match_id = match_id
    match.anonymous_radiant = 0
    match.anonymous_dire = 0

    doc.css(".faction-radiant").each do |result_line|
      match.anonymous_radiant += 1 if result_line.css("td")[1].text.include? "Anonymous"
    end
    puts "Radiant had " + match.anonymous_radiant.to_s + " anonymous players."

    doc.css(".faction-dire").each do |result_line|
      match.anonymous_dire += 1 if result_line.css("td")[1].text.include? "Anonymous"
    end
    puts "Dire had " + match.anonymous_dire.to_s + " anonymous players."

    if doc.css(".match-result").text == "Radiant Victory"
      match.victory = "radiant"
    else
      match.victory = "dire"
    end
    puts match.victory.capitalize + " won the match."

    match.save

    puts "Match saved in DB."
    matches_recorded += 1
  rescue
    puts "Page not found"
  end
  puts "This scraping session is at " + matches_recorded.to_s + " matches recorded."
  puts "Done. Moving to next match."
  match_id -= 1

  sleep(1)

end