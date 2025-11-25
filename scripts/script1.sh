#!/bin/bash

#making an atribute with the base directory of my personal area in the server
personal_area='/home/fc59542'  

#making an atribute with the 
working_dir='Project_ibbc_TiagoTeixeira'

#lista com os nomes das pastas a criar
sub_dir=(
    "01_rawdata"
    "02_qc_data"
    "03_trimmed_data"
    "04_logs"
)


#This command compares $personal_area with the directory im currently in. If i am not in my base directory it gets me in my base directory or exits the script
if  [ "$(pwd)" = "$personal_area" ]

then
        echo "You are in your server area $personal_area"
else
        echo  "You are not in your server area $personal_area"
        cd "$personal_area" || exit
fi


#This command tells if the project directory exists, if it doesnt exist then creates it
if  [ -d  "$personal_area/$working_dir" ]
then
        echo "The working directory $working_dir exits"
else
        echo  "The working directory $working_dir does not exist, creating it..."
        mkdir "$personal_area/$working_dir"
        echo "$working_dir created!"
fi


##This command checks iteratively if the subdirectories directory exist, in case they do not exist, creates them
for dir in "${sub_dir[@]}";
do
    if  [ -d  "$personal_area/$working_dir/$dir" ]
    then
        echo "The subdirectory $dir exits"
    else
        echo  "The subdirectory $dir does not exist, creating it..."
        mkdir "$personal_area/$working_dir/$dir"
        echo "$dir created!"
    fi
done
echo "Script concluded!"