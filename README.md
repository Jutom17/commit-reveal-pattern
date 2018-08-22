# commit-reveal-pattern
A smart contract demonstrating how the commit reveal design pattern works.  

This is a game where there are 2 parties, the House and the Guesser.
First, the House picks a number 1 to 10 and a random string to hash the number, as well as 1 ether for the payout.
Then the Guesser will pick a number and a random string to hash the guess, as well as 1 ether for the payout.
Once both parties have picked a number, they can start revealing their choices.
They will need to enter their random string again during the reveal phase to ensure they did not change their initial input.
Once the first party reveals their choice, the second party has 5 minutes to reveal their answer, otherwise the first party to reveal their choice is declared the winner.
