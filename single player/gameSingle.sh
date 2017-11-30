#!/bin/bash

#initial values
event=1
victory=0
death=0
continue=1

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

	# Single player choice handler
	echo -n Enter your choice:
	read choice

	# check for existance of B and C as options
	Bexist=`cat Choice/Choice$event | awk -F: ' NR == 2 { print $4 }'`
	Cexist=`cat Choice/Choice$event | awk -F: ' NR == 3 { print $4 }'`

	# Find out which number from the Choice file to add to event to get to the next event	
	if [ "$choice" = "A" ]
	then
		temp=`cat Choice/Choice$event | awk -F: ' NR == 1 { print $3 }'`
	elif [ "$choice" = "B" -a $Bexist -eq 1 ]
	then	
		temp=`cat Choice/Choice$event | awk -F: ' NR == 2 { print $3 }'`
	elif [ "$choice" = "C" -a $Cexist -eq 1 ]
	then
		temp=`cat Choice/Choice$event | awk -F: ' NR == 3 { print $3 }'`
	fi

	# Add temp to event
	event=`expr $event + $temp`

	#reset temp to 0 to avoid unseen errors
	temp=0

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
	echo "You killed the guy $death times!"
fi
	
done

return 0
