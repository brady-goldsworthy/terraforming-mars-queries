-- Main query, can get all games one by either player or corporation
SELECT 
	all_scores.game_id,
	all_scores.corporation,
	all_scores.score,
	player_results.megacredits,
	player_results.name,
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
		(playerJson->>'megaCredits')::int as megaCredits,
		(playerJson->>'pickedCorporationCard') as corporation,
		(playerJson->>'name') as name
	FROM games
	CROSS JOIN json_array_elements((game::json->>'players')::json) playerJson
) player_results,
(
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
) all_scores,
(
	SELECT
		latest_games.game_id,
		MAX(player_results.megaCredits) as megaCredits
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
			(playerJson->>'megaCredits')::int as megaCredits,
			(playerJson->>'pickedCorporationCard') as corporation,
			(playerJson->>'name') as name
		FROM games
		CROSS JOIN json_array_elements((game::json->>'players')::json) playerJson
	) player_results,
	(
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
	WHERE latest_games.game_id = player_results.game_id
	AND latest_games.game_id = all_scores.game_id
	AND all_scores.game_id = max_scores.game_id
	AND latest_games.max_time = player_results.created_time
	AND max_scores.score = all_scores.score
	AND player_results.corporation is not null
	AND player_results.corporation = all_scores.corporation
	GROUP BY latest_games.game_id
) max_megaCredits
WHERE latest_games.game_id = player_results.game_id
AND latest_games.game_id = all_scores.game_id
AND all_scores.game_id = max_scores.game_id
AND latest_games.max_time = player_results.created_time
AND max_scores.score = all_scores.score
AND player_results.megaCredits = max_megaCredits.megaCredits
AND player_results.game_id = max_megaCredits.game_id
AND player_results.corporation is not null
AND player_results.corporation = all_scores.corporation
-- AND player_results.name = 'Justin'
AND player_results.corporation = 'Point Luna'
ORDER BY player_results.created_time ASC

-- Same Query, but just the count, for getting winrate
-- COUNT
SELECT 
	COUNT(*)
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
		(playerJson->>'megaCredits')::int as megaCredits,
		(playerJson->>'pickedCorporationCard') as corporation,
		(playerJson->>'name') as name
	FROM games
	CROSS JOIN json_array_elements((game::json->>'players')::json) playerJson
) player_results,
(
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
) all_scores,
(
	SELECT
		latest_games.game_id,
		MAX(player_results.megaCredits) as megaCredits
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
			(playerJson->>'megaCredits')::int as megaCredits,
			(playerJson->>'pickedCorporationCard') as corporation,
			(playerJson->>'name') as name
		FROM games
		CROSS JOIN json_array_elements((game::json->>'players')::json) playerJson
	) player_results,
	(
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
	WHERE latest_games.game_id = player_results.game_id
	AND latest_games.game_id = all_scores.game_id
	AND all_scores.game_id = max_scores.game_id
	AND latest_games.max_time = player_results.created_time
	AND max_scores.score = all_scores.score
	AND player_results.corporation is not null
	AND player_results.corporation = all_scores.corporation
	GROUP BY latest_games.game_id
) max_megaCredits
WHERE latest_games.game_id = player_results.game_id
AND latest_games.game_id = all_scores.game_id
AND all_scores.game_id = max_scores.game_id
AND latest_games.max_time = player_results.created_time
AND max_scores.score = all_scores.score
AND player_results.megaCredits = max_megaCredits.megaCredits
AND player_results.game_id = max_megaCredits.game_id
AND player_results.corporation is not null
AND player_results.corporation = all_scores.corporation
-- AND player_results.name = 'Justin'
AND player_results.corporation = 'Point Luna'

-- Get count total games played by corp
SELECT 
    (scoresJson->>'corporation') as corporation,
    COUNT((scoresJson->>'corporation'))
FROM game_results
CROSS JOIN json_array_elements(scores::json) scoresJson
WHERE (scoresJson->>'corporation')='Point Luna'
GROUP BY (scoresJson->>'corporation')

-- Get count of total games player by player
SELECT 
	COUNT(player_results.game_id)
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
		(playerJson->>'megaCredits')::int as megaCredits,
		(playerJson->>'pickedCorporationCard') as corporation,
		(playerJson->>'name') as name
	FROM games
	CROSS JOIN json_array_elements((game::json->>'players')::json) playerJson
) player_results
WHERE latest_games.game_id = player_results.game_id
AND latest_games.max_time = player_results.created_time
AND player_results.corporation is not null
AND player_results.name = 'Brady'



-- Get all games played by player, probably not needed for bot
SELECT 
	player_results.game_id,
	player_results.corporation,
	player_results.megaCredits,
	player_results.name,
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
		(playerJson->>'megaCredits')::int as megaCredits,
		(playerJson->>'pickedCorporationCard') as corporation,
		(playerJson->>'name') as name
	FROM games
	CROSS JOIN json_array_elements((game::json->>'players')::json) playerJson
) player_results
WHERE latest_games.game_id = player_results.game_id
AND latest_games.max_time = player_results.created_time
AND player_results.corporation is not null
AND player_results.name = 'Brady'
ORDER BY player_results.created_time
