#!/bin/bash

# Connect to database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Ask for username
echo "Enter your username:"
read USERNAME

# Get user_id from DB
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# If user doesn't exist, insert them
if [[ -z $USER_ID ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')"
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number
SECRET=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0

# Loop until correct guess
while true; do
  read GUESS
  ((NUMBER_OF_GUESSES++))

  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif (( GUESS < SECRET )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET )); then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET. Nice job!"
    $PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)"
    break
  fi
done
