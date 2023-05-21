#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE teams, games;")"
cat games.csv | while IFS="," read  YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

if [[ $YEAR != year && $ROUND != round && $WINNER != winner && $OPPONENT != opponent && $WINNER_GOALS != winner_goals && $OPPONENT_GOALS != opponent_goals ]]
then 

  #get winner team ID
  WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")"
  #if not found
  if [[ -z $WINNER_ID ]]
  then
    #insert new team
    INSERT_WINNER_TEAM_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")"
    if [[ $INSERT_WINNER_TEAM_RESULT = "INSERT 0 1" ]]
    then 
      echo $WINNER " was inserted successfully" 
    fi
    #get new inserted team id
    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name= '$WINNER';")"
  fi

  #get opponent team ID
  OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")"
  #if not found
  if [[ -z $OPPONENT_ID ]]
  then
    #insert new team
    INSERT_OPPONENT_TEAM_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")"
    if [[ $INSERT_OPPONENT_TEAM_RESULT = "INSERT 0 1" ]]
    then 
      echo $OPPONENT " was inserted successfully" 
    fi
    #get new inserted team id
    OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name= '$OPPONENT';")"
  fi


  #get game ID
  GAME_ID="$($PSQL "SELECT game_id FROM games INNER JOIN teams AS t1 ON games.winner_id = t1.team_id INNER JOIN teams as t2 ON games.opponent_id=t2.team_id WHERE year=$YEAR and round='$ROUND' and winner_id=$WINNER_ID and opponent_id=$OPPONENT_ID;")"
  echo $GAME_ID
  #if not found
  if [[ -z $GAME_ID ]]
  then
    #insert new game
    INSERT_GAME_RESULT="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")"
    if [[ $INSERT_GAME_RESULT = "INSERT 0 1" ]]
    then 
      echo $ROUND $YEAR " game was inserted successfully" 
    fi
    #get new game_id
    GAME_ID="$($PSQL "SELECT game_id FROM games INNER JOIN teams AS t1 ON games.winner_id = t1.team_id INNER JOIN teams as t2 ON games.opponent_id=t2.team_id WHERE year=$YEAR and round='$ROUND' and winner_id=$WINNER_ID and opponent_id=$OPPONENT_ID;")"
  fi

fi
done
