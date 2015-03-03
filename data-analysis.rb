## THEORY
# "Nothing to hide": anonymous players negatively impact the performance of their team
# Meaning: if a team has a higher number of anonymous players, its odds to win are lower
#
# Stuff to test:
# - Straightforward global test
# - Number of anonymous difference to make an impact
# - Whether the high number of anonymous players in a game makes the outcome hard to predict
#
# Expected results:
# - Overall anonymous have very low impact
# - There will be a sweet spot where they have a significant impact, ex: the 3 anonymous players are all in one team
#
## WHY
# - Prove that anonymous players are not intrinsically bad: many valid reasons to be anonymous other than hiding your poor performance
# - Prove that a bad repartition of anonymous players can skew the results of the game, thus proving the need of balancing the amount of anonymous players via matchmaking ==> VALVE


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



@matches = Match.all

## STATS COLLECTED
# checking the proportion of anonymous players
no_anonymous_players_total = 0
no_players_total = @matches.count * 10

# testing the straightfoward theory
general_validation = 0
no_matches_with_anonymous_disparity = 0

# win chance with 0,1,2,3,4,5 anonymous more than the other team [number_of_games_lost, number_of_games_in_cat]
anonymous_impact = [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]]

# tentative stat on whether the total number of anonymous players in game has an impact on the theory [number_of_games_lost, number_of_games_in_cat]
prediction_accuracy = [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]]



@matches.each do |match|

	#count the number of anonymous players
	no_anonymous_players_total += match.anonymous_radiant + match.anonymous_dire

	# calculate the distance of anonymous players between the two teams
	anonymous_distance = Math.sqrt((match.anonymous_radiant - match.anonymous_dire) ** 2)

	# testing against the theory, note the >= in order to have an origin point for 0 anonymous distance (should be 50% if game is perfect)
	if (match.anonymous_radiant >= match.anonymous_dire and match.victory == "dire") or (match.anonymous_radiant < match.anonymous_dire and match.victory == "radiant")

		# increment associated counters
		anonymous_impact[anonymous_distance][0] += 1
		prediction_accuracy[match.anonymous_radiant + match.anonymous_dire][0] += 1
		general_validation += 1 unless anonymous_distance == 0
	end

	# increment total counters
	anonymous_impact[anonymous_distance][1] += 1
	prediction_accuracy[match.anonymous_radiant + match.anonymous_dire][1] += 1
	no_matches_with_anonymous_disparity += 1 unless anonymous_distance == 0
end



# now export the results in a CSV

def impact(x,y)
	((x.to_f / y.to_f * 100) - 50).round(2).to_s + "%"
end

CSV.open("analysis-results.csv", "wb", encoding: "UTF-8") do |csv|
	csv << ["No of anonymous players", no_anonymous_players_total]
	csv << ["Total no of players", no_players_total]
	csv << ["", ((no_anonymous_players_total.to_f / no_players_total.to_f * 100).round(2).to_s)+"%" ]
	csv << [""]
	csv << ["Straightforward theory testing"]
	csv << ["No of matches where theory was valid", general_validation]
	csv << ["No of matches where theory was tested", no_matches_with_anonymous_disparity]
	csv << ["Impact of anonynoobs", impact(general_validation, no_matches_with_anonymous_disparity)]
	csv << [""]
	csv << ["Impact of distance in anonymous players count"]
	csv << ["", "0","1","2","3","4","5"]
	csv << ["Theory valid", anonymous_impact[0][0],anonymous_impact[1][0],anonymous_impact[2][0],anonymous_impact[3][0],anonymous_impact[4][0],anonymous_impact[5][0]]
	csv << ["Theory tested", anonymous_impact[0][1],anonymous_impact[1][1],anonymous_impact[2][1],anonymous_impact[3][1],anonymous_impact[4][1],anonymous_impact[5][1]]
	csv << ["Impact of anonynoobs", impact(anonymous_impact[0][0], anonymous_impact[0][1]), impact(anonymous_impact[1][0], anonymous_impact[1][1]), impact(anonymous_impact[2][0], anonymous_impact[2][1]), impact(anonymous_impact[3][0], anonymous_impact[3][1]), impact(anonymous_impact[4][0], anonymous_impact[4][1]), impact(anonymous_impact[5][0], anonymous_impact[5][1])]
	csv << [""]
	csv << ["Impact of total number of anonynoobs in match"]
	csv << ["", "0","1","2","3","4","5","6","7","8","9","10"]
	csv << ["Theory valid", prediction_accuracy[0][0],prediction_accuracy[1][0],prediction_accuracy[2][0],prediction_accuracy[3][0],prediction_accuracy[4][0],prediction_accuracy[5][0],prediction_accuracy[6][0],prediction_accuracy[7][0],prediction_accuracy[8][0],prediction_accuracy[9][0],prediction_accuracy[10][0]]
	csv << ["Theory tested", prediction_accuracy[0][1],prediction_accuracy[1][1],prediction_accuracy[2][1],prediction_accuracy[3][1],prediction_accuracy[4][1],prediction_accuracy[5][1],prediction_accuracy[6][1],prediction_accuracy[7][1],prediction_accuracy[8][1],prediction_accuracy[9][1],prediction_accuracy[10][1]]
	csv << ["Impact of anonynoobs", impact(prediction_accuracy[0][0], prediction_accuracy[0][1]), impact(prediction_accuracy[1][0], prediction_accuracy[1][1]), impact(prediction_accuracy[2][0], prediction_accuracy[2][1]), impact(prediction_accuracy[3][0], prediction_accuracy[3][1]), impact(prediction_accuracy[4][0], prediction_accuracy[4][1]), impact(prediction_accuracy[5][0], prediction_accuracy[5][1]), impact(prediction_accuracy[6][0], prediction_accuracy[6][1]), impact(prediction_accuracy[7][0], prediction_accuracy[7][1]), impact(prediction_accuracy[8][0], prediction_accuracy[8][1]), impact(prediction_accuracy[9][0], prediction_accuracy[9][1]), impact(prediction_accuracy[10][0], prediction_accuracy[10][1])]

end








