#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Make sure the tables are empty
echo "Emptying tables ..."
echo $($PSQL "TRUNCATE TABLE games, teams;")

# Read the contents of games.csv and iterate over each record
echo "iterating through games.csv ...."
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]] # Make sure to skip the column headers
  then
  
    # Check if the teams of each game is already in the database
    DOES_WINNER_EXIST=$($PSQL "SELECT name FROM teams WHERE name = '$WINNER'")
    DOES_OPPONENT_EXIST=$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT'")

    # If the team isn't present, insert them into the database
    if [[ -z $DOES_WINNER_EXIST ]]
    then
      echo $($PSQL "INSERT INTO teams(name) VALUES ('$WINNER');")
    fi

    if [[ -z $DOES_OPPONENT_EXIST ]]
    then
      echo $($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT');")
    fi

    # Get the IDs for each team from the database
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")

    # Insert match data into the database
    echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")

  fi
done
echo "Data has been inserted."

# TEST - get all teams and game data
# echo $($PSQL "SELECT * FROM teams;")
# echo $($PSQL "SELECT * FROM games;")