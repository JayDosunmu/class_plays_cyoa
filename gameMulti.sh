#!/bin/bash

#Potential expansion-
# Add a grep or awk on Event cat so we can add comments on each Event file
# Test if a tie between A, B, or C creates issues. Prioritize in case of ties?
# Add a check if the C option exists
# Add a chance to go to the death event during attack- use break to exit loop

#initial event
event=1
victory=0
death=0
continue=1
file=commands

while [ $continue -eq 1 ]; ## main loop, to allow for multiple endings
do
#initial clear
clear
#while loop goes until specific events are completed, can be modified for specific event numbers to terminate- i.e. final events can add 100 to event to terminate loop
while [ $event -lt 26 ]; 
do
	#victory handler to change initial event
	if [ $event -eq 21 ]
	then
		victory=1
	fi
	
	if [ $event -eq 1 -a $victory -eq 1 ]
	then
		event=22
	fi

	#Use cat to print out event and choice. 
	#Can add comments in Choice files after 3rd :
	cat Event/Event$event | fmt
        cat Choice/Choice$event | awk -F: '{ print $1 $2 }'

	# death or victory handler
	if [ $event -eq 8 -o $event -eq 10 -o $event -eq 12 -o $event -eq 14 -o $event -eq 16 -o $event -eq 21 -o $event -eq 23 ]
	then	
		death=`expr $death + 1` 
		break
	elif [ $event -eq 25 ] ##### winning event
	then
		continue=0
		break
	fi
	
	#Single line countdown
	#From https://serverfault.com/questions/532559/bash-script-count-down-5-minutes-display-on-single-line
	echo "Time left to enter a choice:"
	secs=10
	while [ $secs -gt 0 ]; 
	do
		echo -ne "$secs\033[0K\r"
		sleep 1
		: $((secs--))
	done

	# check for existance of B and C as options
	Bexist=`cat Choice/Choice$event | awk -F: ' NR == 2 { print $4 }'`
	Cexist=`cat Choice/Choice$event | awk -F: ' NR == 3 { print $4 }'`

	#Logic for choice:
	#A, B, and C grab the number of votes each got from the server text file.
	A=`cat "$file" | grep 'A' | wc -l`
	B=`cat "$file" | grep 'B' | wc -l`
	C=`cat "$file" | grep 'C' | wc -l`

	echo “Votes total:”
	echo A: $A
	if [ $Bexist -eq 1 ]
	then
		echo B: $B
	fi
	
	if [ $Cexist -eq 1 ]
	then
		echo C: $C
	fi

	#Set temp to add to event modifier, highest count will decide where temp reads from
	# temp reads from the correct choice file and returns the associated destination operator to add to event
	if [ $A -ge $B -a $A -ge $C ]
	then
		temp=`cat Choice/Choice$event | awk -F: ' NR == 1 { print $3 }'` #choice=A
		echo “A wins”
	elif [ $B -ge $A -a $B -ge $C -a $Bexist -eq 1 ]
	then
		temp=`cat Choice/Choice$event | awk -F: ' NR == 2 { print $3 }'` #choice=B
		echo “B wins”
	elif [ $C -ge $A -a $C -ge $B -a $Cexist -eq 1 ]
	then
		temp=`cat Choice/Choice$event | awk -F: ' NR == 3 { print $3 }'` #choice=C
		echo “C wins”
	else
		echo "Command not recognized, please choose a supplied option"
		temp=0
	fi

	# Add temp to event
	event=`expr $event + $temp`

	# To clear test.txt for running program, remove comment on next line
	>"$file"

	#reset temp to 0 to avoid unseen errors
	temp=0

	sleep 1
	echo -n .
	sleep 1
	echo -n .
	sleep 1
	echo -n .
	sleep 1

	#clear screen
	clear
done

if [ $continue -eq 1 ]
then
	sleep 10
	echo "Congratulations, you have died $death times now." 
	sleep 3
	echo "But there is probably more to see, so let's try again!"
	sleep 3
	echo "Good luck!"
	sleep 3
	event=1
else
	sleep 10
	echo "Congratulations! You did it. You won."
	sleep 2
	echo "It's finally over. Thanks for playing!"
	sleep 2
	echo "You you got your guy killed $death times!"
fi

done

