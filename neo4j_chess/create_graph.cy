// constraints to ensure uniqueness
CREATE CONSTRAINT ON (p:Player) ASSERT p.name IS UNIQUE;
CREATE CONSTRAINT ON (e:Event) ASSERT e.name IS UNIQUE;
CREATE CONSTRAINT ON (g:Game) ASSERT g.number IS UNIQUE;
CREATE CONSTRAINT ON (p:Position) ASSERT p.fen IS UNIQUE;

// import players using periodic commit
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///chess\\games.csv" AS line
MERGE (player:Player {name: line.White})
MERGE (player1:Player {name: line.Black})

// import events using periodic commit
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///chess\\games.csv" AS line
// split date with "." in order to get the date parts
WITH DISTINCT line, SPLIT(line.EventDate, '.') AS date
MERGE (event:Event {name: line.Event})
SET event.year = toInteger(date[0]),
event.month = toInteger(date[1]),
event.day = toInteger(date[2]),
event.site = line.Site

// import games using periodic commit
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///chess\\games.csv" AS line
// split date with "." in order to get the date parts
WITH DISTINCT line, SPLIT(line.Date, '.') AS date
// parse specific variables as integers
MERGE (game:Game {number: toInteger(line.GameNumber), halfmoves:toInteger(line.HalfMoves),
moves:toInteger(line.Moves), result:line.Result, whiteElo:line.WhiteElo, blackElo:line.BlackElo, eco:line.ECO,opening:line.Opening })
SET game.year = toInteger(date[0]),
game.month = toInteger(date[1]),
game.day = toInteger(date[2])

// create relationship between white player and game
// the side of the player is a property of the relationship
// as it is not constant
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///chess\\games.csv"  AS line
MATCH (player:Player { name: line.White})
MATCH (game:Game { number: toInteger(line.GameNumber) })
MERGE (player)-[r:PLAYED]->(game) 
    SET r.side = "White"
    
// create relationship between black player and game
// the side of the player is a property of the relationship
// as it is not constant
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///chess\\games.csv"  AS line
MATCH (player:Player { name: line.Black})
MATCH (game:Game { number: toInteger(line.GameNumber) })
MERGE (player)-[r:PLAYED]->(game) 
    SET r.side = "Black" 
    
// create relationship between event and game
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///chess\\games.csv"  AS line
MATCH (event:Event { name: line.Event})
MATCH (game:Game { number: toInteger(line.GameNumber) })
MERGE (event)-[:CONTAINS]->(game) 
    
// import positions (fen) using periodic commit    
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///chess\\moves.csv" AS line
MERGE (position:Position {fen: line.FEN})
MERGE (position1:Position {fen: line.FEN1})

// create connection between the first move of each game with the relevant position
// the properties of that relationship are the moveNumber, the Side, the Move
// and the GameNumber
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///chess\\moves.csv"  AS line
WITH line WHERE TOINT(line.MoveNumber) = 1
MATCH (position:Position {fen: line.FEN})
MATCH (game:Game { number: toInteger(line.GameNumber) })
MERGE (game)-[r:TO]->(position) 
    SET r.MoveNumber = toInteger(line.MoveNumber),
        r.Side = line.Side,
        r.Move = line.Move,
        r.GameNumber = toInteger(line.GameNumber);

// create connection between positions, based on the moves of each game
// except for the first move ( that relationship was created above directly with game)
// the properties of that relationship are the moveNumber, the Side, the Move
// and the GameNumber
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///chess\\moves.csv" AS line
MATCH (position2:Position {fen: line.FEN1})
MATCH (position1:Position {fen: line.FEN})
CREATE (position1)-[r:TO]->(position2) 
    SET r.MoveNumber = toInteger(line.MoveNumber1),
        r.Side = line.Side1,
        r.Move = line.Move1,
        r.GameNumber = toInteger(line.GameNumber);     
