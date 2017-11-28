#!/bin/bash

#Potential expansion-
# Add a grep or awk on Event cat so we can add comments on each Event file
# Test if a tie between A, B, or C creates issues. Prioritize in case of ties?
# Add a check if the C option exists
# Add a chance to go to the death event during attack- use break to exit loop

#initial event
event=1

#while loop goes until specific events are completed, can be modified for specific event numbers to terminate- i.e. final events can add 100 to event to terminate loop
while [ $event -lt 4 ]; do

	#Use cat to print out event and choice. 
	#Can add comments in Choice files after 3rd :
	cat Event$event.txt
	cat Choice$event.txt | awk -F: '{ print $1 "." $2 }'

	#Logic for choice:
	#A, B, and C grab the number of votes each got from the server text file.
	A=`cat test.txt | grep 'A' | wc -l`
	B=`cat test.txt | grep 'B' | wc -l`
	C=`cat test.txt | grep 'C' | wc -l`

	# To clear test.txt for running program, remove comment on next line
	# >test.txt

	#reset temp to 0 to avoid unseen errors
	temp=0

	#Set temp to add to event modifier, highest count will decide where temp reads from
	# temp reads from the correct choice file and returns the associated destination operator to add to event
	if [ $A -gt $B -a $A -gt $C ]
	then
		temp=`cat Choice$event.txt | awk -F: ' NR == 1 { print $3 }'` #choice=A
	elif [ $B -gt $A -a $B -gt $C ]
	then
		temp=`cat Choice$event.txt | awk -F: ' NR == 2 { print $3 }'` #choice=B
	elif [ $C -gt $A -a $C -gt $B ]
	then
		temp=`cat Choice$event.txt | awk -F: ' NR == 3 { print $3 }'` #choice=C
	else
		echo "Command not recognized"
	fi


	: ' #this line is the syntax to ignore until next single quote
	#Old case for choice
	case $choice in
		A) temp=`cat Choice$event.txt | awk -F: ' NR == 1 { print $3 }'`;;
		B) temp=`cat Choice$event.txt | awk -F: ' NR == 2 { print $3 }'`;;
		C) temp=`cat Choice$event.txt | awk -F: ' NR == 3 { print $3 }'`;;
		*) echo "Input not recognized" ;;
	esac
	' #end comment out

	# add temp to event to proceed to next event and choice
	event=`expr $event + $temp`

	#Single line countdown
	#From https://serverfault.com/questions/532559/bash-script-count-down-5-minutes-display-on-single-line
	echo "Time left to enter a choice:"
	secs=5
	while [ $secs -gt 0 ]; do
		echo -ne "$secs\033[0K\r"
		sleep 1
		: $((secs--))
	done

	#clear screen
	clear
done

