
// Query 1:
// In how many games the position with FEN: r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R is found
// and in what percentage of these white won?

MATCH ()-[r:TO]-(p2:Position {fen:'r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R'}) with distinct r.GameNumber as gNumber
OPTIONAL MATCH (g1:Game {number: gNumber}) 
OPTIONAL MATCH (g2:Game {number: gNumber, result: 'White'}) 
RETURN COUNT(g1) as total_games, toFloat(COUNT(g2))/COUNT(g1) as white_percentage;

// Query 2:
// In the games where the position with FEN: r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R  is found, 
// in how many the result was draw and in how many white won or black won?

MATCH ()-[r:TO]-(p2:Position {fen:'r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R'}) with distinct r.GameNumber as gNumber 
OPTIONAL MATCH(g_white:Game {result:"White", number:gNumber}) with g_white as white_wins, gNumber 
OPTIONAL MATCH(g_black:Game {result:"Black", number:gNumber}) with g_black as black_wins, gNumber, white_wins 
OPTIONAL MATCH(g_draw:Game {result:"Draw", number:gNumber}) with g_draw as draws, white_wins,black_wins 
RETURN count(draws) as total_draws, count(white_wins) as total_whites, count(black_wins) as total_blacks

// Query 3:
// What is the tournament with the most games played and in how many of these Karpov Anatoly had either white or black?

// Select Tournament with most games:
MATCH (e:Event)-[t:CONTAINS]->(g:Game) RETURN e.name as eventName, count(t) as frequency 
ORDER BY frequency DESC LIMIT 2

// Select Tournament and the frequency of Karpov games in that tournament for the first result of the previous query.
MATCH (e:Event {name:"World Championship 31th"})-[t:CONTAINS]->(g:Game)-[pl:PLAYED]-(p:Player {name:"Karpov  Anatoly"}) 
RETURN e.name as eventName, count(t) as frequency_KA
ORDER BY frequency_KA DESC 

// Select Tournament and the frequency of Karpov games in that tournament for the second result of the previous query.
MATCH (e:Event {name:"World Championship 18th"})-[t:CONTAINS]->(g:Game)-[pl:PLAYED]-(p:Player {name:"Karpov  Anatoly"}) 
RETURN e.name as eventName, count(t) as frequency_KA
ORDER BY frequency_KA DESC 

// Query 4:
// Which player has most games with “Ruy Lopez” opening?
MATCH (g:Game {opening: "Ruy Lopez"})<-[pl:PLAYED]-(p:Player) 
RETURN p.name, count(pl) as frequency 
ORDER BY frequency 
DESC LIMIT 1

// Query 5:
// How many games have the moves “Nc6”, “Bb5”, “a6” and which players played these games?

// Demonstrate how many games have these moves:
MATCH ()-[r:TO {Move: "Nc6"}]->(p1:Position)-[r1:TO {Move: "Bb5"}]->(p2:Position)-[r2:TO {Move: "a6"}]->(p3:Position) 
with distinct r2.GameNumber as gNumber2  
RETURN count(distinct gNumber2) as number_of_games

// Which players played these games?
MATCH ()-[r:TO {Move: "Nc6"}]->(p1:Position)-[r1:TO {Move: "Bb5"}]->(p2:Position)-[r2:TO {Move: "a6"}]->(p3:Position) 
with distinct r2.GameNumber as gNumber2  
MATCH (p:Player)-[:PLAYED]->(g:Game {number: gNumber2}) 
RETURN distinct(p.name) as Player_name

// Query 6:
// For GameNumber:636 show the game’s information, the tournament where it was played,
// the players and all the moves played ordered. 

// Demonstrate game's information, tournament and players.
MATCH (g:Game {number: 636}) 
MATCH (e:Event)-[:CONTAINS]->(g)
MATCH (pl1:Player)-[:PLAYED]->(g) RETURN g, e, pl1

// Demonstrate moves
MATCH ()-[r:TO {GameNumber: 636}]->(p2:Position)
RETURN r.MoveNumber, r.Move ORDER BY r.MoveNumber

// Query 7:
// Show all the games with the position Fen: “1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R where the next move was not “a6”.
// Also show the alternative moves that were played after this position and the result of the games. 

MATCH ()-[r:TO]->(p2:Position {fen:'r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R'})-[r1:TO] -> (p3:Position) 
WHERE r1.Move <> 'a6' and r.GameNumber=r1.GameNumber with r.GameNumber as gNumber, r1.Move as altMove
OPTIONAL MATCH (g:Game {number:gNumber})
RETURN gNumber, g.result as gameResult, altMove 
ORDER BY gNumber

