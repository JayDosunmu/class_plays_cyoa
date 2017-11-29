#!/bin/bash

#Potential expansion-
# Add a grep or awk on Event cat so we can add comments on each Event file
# Test if a tie between A, B, or C creates issues. Prioritize in case of ties?
# Add a check if the C option exists
# Add a chance to go to the death event during attack- use break to exit loop

#initial event
event=1
name=0
death=0
continue=1

while [ $continue -eq 1 ]; ## main loop, to allow for multiple endings
do

#while loop goes until specific events are completed, can be modified for specific event numbers to terminate- i.e. final events can add 100 to event to terminate loop
while [ $event -lt 10 ]; 
do

	#Use cat to print out event and choice. 
	#Can add comments in Choice files after 3rd :
	cat Event$event | fmt
	if [ $event -eq 6 -a $name -eq 1 ] #checking if the name is known
        then
                cat Choice$event | awk -F: '{ print $1 "." $3 }'
        else
                cat Choice$event | awk -F: '{ print $1 "." $2 }'
        fi

	# death or victory handler
	if [ $event -eq 8 -o $event -eq 10 -o $event -eq 30 ]	#### 30 placeholder
	then	
		death=1
		break
	elif [ $event = 90 ] ##### winning event
	then
		continue=0
		break
	fi

	###### 15 is a placeholder, whichever event reveals the man in the red hat's name.
	if [ $event -eq 15 ]
        then
                name=1
        fi
	
	################
	echo -n Enter your choice:
	read choice

	if [ "$choice" = "A" ]
	then
		temp=`cat Choice$event | awk -F: ' NR == 1 { print $3 }'`
	elif [ "$choice" = "B" ]
	then	
		temp=`cat Choice$event | awk -F: ' NR == 2 { print $3 }'`
	elif [ "$choice" = "C" ]
	then
		temp=`cat Choice$event | awk -F: ' NR == 3 { print $3 }'`
	fi
	#################

	# add temp to event to proceed to next event and choice
	if [ $event -eq 6 -a $name -eq 1 ]  ## test if name is figured out
	then	
		event=60		#########placeholder at 60
	else
		event=`expr $event + $temp`
	fi

	# To clear test.txt for running program, remove comment on next line
	# >test.txt

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

if [ $death -eq 1 ]
then
	sleep 10
	echo Congratulations, you have died. 
	sleep 2
	echo But there is probably more to see, so let's try again!
	sleep 2
	echo Good luck!
	sleep 2

	event=1
	death=0
else
	sleep 10
	echo Congratulations! You did it. You won.
	sleep 2
	echo It's finally over. Thanks for playing!
	sleep 2
fi
	
done

