#!/bin/bash

trap "rm -f tmp_file" EXIT

dir=0
function showMsg(){
	dialog --clear --title "$1" --backtitle "Linux backup program" --msgbox "$2" 10 50
}


function copyFiles(){
	local device="$1"
	dialog --clear --title "Choose file or directory" \
		--fselect $HOME 10 50 2>tmp_file

	case $? in
		0)
			path=`cat tmp_file`;;
		1)
			showMsg "Exit" "Thanks for using my program"
			exit;;
	esac

	if [ -d $path ] || [ -f $path ]
	then
		dialog --clear --title "Copying files" --backtitle "Linux backup program" \
		--yesno "Are you sure to copy:\n$path\nTo:\n$device ?" 10 50
		case $? in 
			0) 
				if [ ! -d $device ]; then
					mkdir $device
				fi

				#Copying files, core of the program
				rsync -aq ${path} ${device}
				case $? in
					0) 
						showMsg "Done" "Operation run successful \nThanks for using program"
						;;

					1)
						showMsg "Error" "Operation Failed"
						;;
				esac
				;;
			1)
				showMsg "Error" "Operation cancelled"
				;;
		esac
	else
		showMsg "Error" "No such directory or file"
	fi
}

dialog --clear --title "[ M A I N - M E N U ]" \
				--backtitle "Linux backup program" \
				--menu "Choose destination of your backup:" 10 50 3 \
				1 "Directory on your computer" \
				2 "USB, external drive etc" \
				3 "SSH to another computer" 2> tmp_file

case $? in
	0) 
		# Checking for directory
		if [ `cat tmp_file` == 1 ]; then
			dialog --clear \
				--title "Select directory for backup" \
				--fselect $HOME 10 50 2> tmp_file
			case $? in
				0) dir=`cat tmp_file`;;
				1) showMsg "Exit" "Thanks for using my program";;
			esac

		# Checking for external device 
		elif [ `cat tmp_file` == 2 ]; then
			my_array=($(df | grep "Volumes" | awk '{print $9}'))
			if [ ${#my_array[@]} == 0 ]; then 
				showMsg "Error" "No external device connected"
				exit
			fi
			declare -a my_second_array
			for i in ${!my_array[@]}; do 
				my_second_array+=" $i "
				my_second_array+=${my_array[$i]}
			done
			dialog --clear --title "Backup program !!" \
				--menu "Choose destination:" 15 60 ${#my_array[@]} \
				${my_second_array[@]} 2> tmp_file

			case $? in
				0)
					index=`cat tmp_file`
					device=${my_array[$index]};;
				1)
					showMsg "Exit" "Thanks for using my program";;
			esac

			dialog --clear --title "Select directory on $device" \
				--fselect "$device/" 10 50 2> tmp_file
			case $? in
				0) 
					dir=`cat tmp_file`;;
				1) 
					showMsg "Exit" "Thanks for using my program";;
			esac
		elif [ `cat tmp_file` == 3 ]; then
			showMsg "TODO" "SOON"
			exit
			dialog --backtitle "Backup program !!" --title "SSH connection" \
				--form "\nPlease fill the fields" 25 60 5 \
				"User:" 1 1 "Value 1" 1 25 25 30 \
				"IP adress:" 2 1 "Value 2" 2 25 25 30 \
				"Password:" 3 1 "Value 3" 3 25 25 30 2> ssh_temp
				
				read -r -a array < `cat ssh_temp`
				ssh "${array[0]}@${array[1]}"
				#TODO
		fi
		;;
	1) 
		showMsg "Exit" "Thanks for using my program"
			;;
	esac


if [ $dir == 0 ]; then
	exit
else
	copyFiles $dir
fi

# # student@155.158.122.205
# # pass: ST1D1NT2019
