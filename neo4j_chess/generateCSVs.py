# import the necessary libraries
import pandas as pd
import csv

# the file with the initial data
file = "chessData.txt"

# open the data file
with open(file, 'r') as input_file:

    # initialize a dictionary for the information of each game
    game_info = {"White": [], "Black": [], "Date": [], "HalfMoves": [],
                 "Moves": [], "Result": [], "WhiteElo": [], "BlackElo": [],
                 "GameNumber": [], "Event": [], "Site": [], "EventDate": [],
                 "Round": [], "ECO": [], "Opening": []}

    # initialize a dictionary for the information of each move
    game_move = {"MoveNumber": [], "Side": [], "Move": [],
                 "FEN": [], "GameNumber": []}

    # create the file to save the information about the games
    gamesfile = open('games.csv', 'w', newline='', encoding="utf-8")

    # write the header of the file i.e. the the names of the columns
    # those information include the names of the players, their side
    # the reult of the game, the date of the game, the event, the result
    # the round, the opening etc.
    gameswriter = csv.DictWriter(gamesfile, fieldnames=list(game_info.keys()))
    gameswriter.writeheader()

    # initialize a en empty lizt for moves
    # the list will include all the moves for each game
    moveslist = []

    counter_moves = 0
    flag_moves = True

    for line in input_file:
        # if that condition is true it means that the following
        # lines of the initial .txt file refer to a game
        if "= Game =" in line:
            flag_moves = False
            continue

        # if that condition is true it means that the following
        # lines of the initial .txt file refer to the moves of the
        # respective game
        elif "- Game Moves -" in line:
            flag_moves = True
            # write the previously read game to the .csv file
            gameswriter.writerow(game_info)
            # empty the games dictionary for the next game
            game_info = {}
            continue
        # if that condition is true it means that both the general info
        # about the game and the moves have been parsed and stored
        elif "====================================================" in line:
            continue
        # if the general info of the game are currently read
        if flag_moves is False:
            # split the row on the colon (":")
            row = line.split(":")
            # store the info of the game in the dictionary
            game_info[row[0]] = row[1].strip()
        # if the moves of the game are currently read
        else:
            # split the row on the comma (",") firstly
            move_info = line.split(",")
            for info in move_info:
                # split again the row on the colon (":")
                row = info.split(":")
                if row[0].strip() == "MoveNumber":
                    # if the counter is zero
                    if counter_moves == 0:
                        # store the move number
                        game_move[row[0].strip()] = row[1].strip()
                        counter_moves += 1
                    else:
                        # store the moves of the games in the list
                        moveslist.append(game_move)
                        # empty the dictionary about moves
                        game_move = {}
                        # get to next move
                        game_move[row[0].strip()] = row[1].strip()
                else:
                    game_move[row[0].strip()] = row[1].strip()
    # close the file with the game info
    gamesfile.close()

# convert the moves' list to a pandas dataframe
movespd = pd.DataFrame(moveslist)
# each row of the dataframe contains the info of one move and
# the info of its next move
movesrel = {"MoveNumber": [], "Side": [], "Move": [], "FEN": [],
            "GameNumber": [], "MoveNumber1": [], "Side1": [],
            "Move1": [], "FEN1": []}
# create the file to save the information about the moves
movesfile = open('moves.csv', 'w', newline='', encoding="utf-8")
# write the header of the file i.e. the the names of the columns
# those information include the move number, the move itself,
# the side and the FEN code
moveswriter = csv.DictWriter(movesfile, fieldnames=list(movesrel.keys()))
moveswriter.writeheader()

# for each move combine its information with the information
# of the next move. This is useful for the graph creation in
# Neo4j
for index, _ in movespd.iterrows():
    if index - 1 >= 0 and movespd.GameNumber.loc[index] == movespd.GameNumber.loc[index - 1]:
        movesrel["MoveNumber"] = movespd.MoveNumber.loc[index - 1]
        movesrel["Side"] = movespd.Side.loc[index - 1]
        movesrel["Move"] = movespd.Move.loc[index - 1]
        movesrel["FEN"] = movespd.FEN.loc[index - 1]
        movesrel["GameNumber"] = movespd.GameNumber.loc[index - 1]
        movesrel["MoveNumber1"] = movespd.MoveNumber.loc[index]
        movesrel["Side1"] = movespd.Side.loc[index]
        movesrel["Move1"] = movespd.Move.loc[index]
        movesrel["FEN1"] = movespd.FEN.loc[index]
        moveswriter.writerow(movesrel)

# close the file with the moves info
movesfile.close()
