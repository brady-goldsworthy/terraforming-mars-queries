
select scores from game_results

select scores from game_results where game_id='gc725d1dda510'

select * from games
select * from games where game_id='g7d0dada22067'
select game_id, game from games where game_id='g7d0dada22067'

SELECT
	all_scores.game_id,
	all_scores.corporation,
  	all_scores.score 
FROM(
	select 
		game_id,
		MAX((scoresJson->>'playerScore')::int) as score
	from game_results
	cross join json_array_elements(scores::json) scoresJson
	GROUP BY game_id
) max_scores, 
(
	select 
		game_id,
		(scoresJson->>'corporation') as corporation,
		(scoresJson->>'playerScore')::int as score
	from game_results
	cross join json_array_elements(scores::json) scoresJson
) all_scores
WHERE max_scores.game_id = all_scores.game_id 
AND max_scores.score = all_scores.score
AND all_scores.corporation != 'Beginner Corporation'

SELECT
	all_scores.corporation,
	COUNT(all_scores.corporation)
FROM(
	select 
		game_id,
		MAX((scoresJson->>'playerScore')::int) as score
	from game_results
	cross join json_array_elements(scores::json) scoresJson
	GROUP BY game_id
) max_scores, 
(
	select 
		game_id,
		(scoresJson->>'corporation') as corporation,
		(scoresJson->>'playerScore')::int as score
	from game_results
	cross join json_array_elements(scores::json) scoresJson
) all_scores
WHERE max_scores.game_id = all_scores.game_id 
AND max_scores.score = all_scores.score
AND all_scores.corporation = 'Valley Trust'
GROUP BY all_scores.corporation

SELECT 
	player_results.game_id,
	player_results.playerId,
	player_results.megaCredits,
	player_results.corporation,
	player_results.created_time
FROM (
	select 
		game_id,
		MAX(created_time) as max_time
	from games
	GROUP BY game_id
) latest_games,
(
	SELECT
		game_id,
		created_time,
		(playerJson->>'id') as playerId,
		(playerJson->>'megaCredits') as megaCredits,
		(playerJson->>'pickedCorporationCard') as corporation
	FROM games
	CROSS JOIN json_array_elements((game::json->>'players')::json) playerJson
) player_results
WHERE latest_games.game_id = player_results.game_id
AND latest_games.max_time = player_results.created_time
AND player_results.corporation is not null
AND player_results.game_id='ge73c224c1a1b'
ORDER BY player_results.created_time ASC

SELECT 
	(scoresJson->>'corporation') as corporation,
	COUNT((scoresJson->>'corporation'))
FROM game_results
CROSS JOIN json_array_elements(scores::json) scoresJson
GROUP BY (scoresJson->>'corporation')
ORDER BY COUNT((scoresJson->>'corporation')) DESC


SELECT 
	(scoresJson->>'corporation') as corporation
FROM game_results
CROSS JOIN json_array_elements(scores::json) scoresJson
GROUP BY (scoresJson->>'corporation')
ORDER BY COUNT((scoresJson->>'corporation')) DESC

SELECT 
	(scoresJson->>'corporation') as corporation,
	COUNT((scoresJson->>'corporation'))
FROM game_results
CROSS JOIN json_array_elements(scores::json) scoresJson
WHERE (scoresJson->>'corporation')='Valley Trust'
GROUP BY (scoresJson->>'corporation')
