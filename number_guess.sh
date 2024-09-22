#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --tuples-only -c"

# global variables
NUMBER_OF_TRIES=0

GUESS() {
	echo "Guess the secret number between 1 and 1000:"
	NUMBER_TO_GUESS=$(( RANDOM % 1000 + 1))
  echo $NUMBER_TO_GUESS
	USER_GUESS=0
	TRY_NUMBER=0

	until [[ $NUMBER_TO_GUESS == $USER_GUESS ]]
	do
		read USER_GUESS
		let "NUMBER_OF_TRIES++"
    if ! [[ $(($USER_GUESS)) == $USER_GUESS ]]
    then
      echo "That is not an integer, guess again:"
		elif [[ $USER_GUESS -gt $NUMBER_TO_GUESS ]]					
		then
			echo "It's lower than that, guess again:"
		elif [[ $USER_GUESS -lt $NUMBER_TO_GUESS ]]
		then
			echo "It's higher than that, guess again:"
    elif [[ $USER_GUESS -eq $NUMBER_TO_GUESS ]]
    then
      echo You guessed it in $NUMBER_OF_TRIES tries. The secret number was $NUMBER_TO_GUESS. Nice job!
		else
			echo "That is not an integer, guess again:"
		fi
	done

}

MAIN() {
	echo Enter your username:
	read USERNAME
	BEST_GAME=0

	USER_DATA=$($PSQL "SELECT games_played, best_game FROM user_data WHERE username = '$USERNAME'")
	if ! [[ -z $USER_DATA ]]
	then
		echo "$USER_DATA" | while read GAMES_PLAYED BAR BEST_GAME
		do
			echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
		done
	else
		echo "Welcome, $USERNAME! It looks like this is your first time here."
		ADD_USER_RESULT=$($PSQL "INSERT INTO user_data(username) VALUES('$USERNAME')")
	fi

	# start game
  GUESS

	# save data
	UPDATE_DATA_RESULT=$($PSQL "UPDATE user_data SET games_played=(games_played + 1) WHERE username='$USERNAME'")
	if [[ $BEST_GAME -gt $NUMBER_OF_TRIES ]] || [[ $BEST_GAME -eq NULL ]]
	then
		UPDATE_DATA_RESULT=$($PSQL "UPDATE user_data SET best_game=$NUMBER_OF_TRIES WHERE username='$USERNAME'")
	fi
}

MAIN
