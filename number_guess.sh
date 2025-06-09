#!/bin/bash

# Set up PostgreSQL connection command (quiet mode)
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -q -c"

# Ask for the username
echo "Enter your username:"
read USERNAME

# Get user_id if exists
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
USER_ID=$(echo "$USER_ID" | xargs)  # Trim whitespace

# Check if user is new
if [[ -z $USER_ID ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" 2>/dev/null
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  USER_ID=$(echo "$USER_ID" | xargs)
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  GAMES_PLAYED=$(echo "$GAMES_PLAYED" | xargs)
  BEST_GAME=$(echo "$BEST_GAME" | xargs)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0

# Loop until correct guess
while true; do
  read GUESS

  # Validate input is an integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((NUMBER_OF_GUESSES++))

  if (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    $PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)" 2>/dev/null
    break
  fi
done
