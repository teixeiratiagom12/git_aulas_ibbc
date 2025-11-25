#!/bin/bash

personal_area='/home/fc59542'  
working_dir='Project_ibbc_TiagoTeixeira' 
sub_dir=(
    "01_rawdata"
    "02_qc_data"
    "03_trimmed_data"
    "04_logs"
)

env_name="tools_qc"

#paths to the several subdirectories
raw_path="$personal_area/$working_dir/${sub_dir[0]}"
qc_path="$personal_area/$working_dir/${sub_dir[1]}"
trim_path="$personal_area/$working_dir/${sub_dir[2]}"
log_path="$personal_area/$working_dir/${sub_dir[3]}"

#default trimming settings (for the user)
trim_settings="ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36"

#default trimming settings (for trimmomatic)
illuminaclip="ILLUMINACLIP:TruSeq3-PE.fa:2:30:10"
leading="LEADING:3"
trailing="TRAILING:3"
slidingwindow="SLIDINGWINDOW:4:15"
minlen="MINLEN:36"



#Start
#Making sure that all the files follow the <sample_name>_R<x>.fastq.gz standard
echo "Before starting, make sure that all the files are named <sample_name>_R1.fastq.gz or <sample_name>_R2.fastq.gz."
ls "$raw_path"
echo "Do you want to proceed? <yes/no>"

while true; do
    read -r answr #-r avoids missinterpretation of scpecial charachters
    
    if [ "$answr" == "yes" ]; then
        break #gets out of the while loop

    elif [ "$answr" == "no" ]; then
        exit 0 #gets out of the script without an error 

    else
        echo "Please answer with <yes/no>"
    fi
done

#presents the trimming settings and allows to change the trimming settings
echo "trimming will be made with the script default settings: $trim_settings"
echo "Do you want to change the trimming settings? <yes/no>"
while true; do
    read -r answr2
    
    if [ "$answr2" == "no" ]; then
        break

    elif [ "$answr2" == "yes" ]; then
        echo "Define the trimming settings:"

        echo ILLUMINACLIP:
        read -r answrILLUMINACLIP
        illuminaclip="ILLUMINACLIP:$answrILLUMINACLIP"

        echo LEADING:
        read -r answrLEADING
        leading="LEADING:$answrLEADING"

        echo TRAILING:
        read -r answrTRAILING
        trailing="TRAILING:$answrTRAILING"

        echo SLIDINGWINDOW:
        read -r answrSLIDINGWINDOW
        slidingwindow="SLIDINGWINDOW:$answrSLIDINGWINDOW"

        echo MINLEN:
        read -r answrMINLEN
        minlen="MINLEN:$answrMINLEN"
        break

    else
        echo "Please answer with <yes/no>"
    fi
done

#Knowing if the scrip is being rerun to improve parameters, allows to overwrite present output files in that case
echo "Are you rerunning the script to improve parameters? <yes/no>"
while true; do
    read -r answr4
    
    if [ "$answr4" == "yes" ]; then
        break

    elif [ "$answr4" == "no" ]; then
        break

    else
        echo "Please answer with <yes/no>"
    fi
done
echo "Starting script!"


#record proceedings from script in log file, by default the standing output (1), by doing 2>&1, the standing error will also follow the stdout to the log file, 
#tee allows for the output to be presented while the script is running and -a appends that output to the file instead of overwriting
exec > >(tee -a "$log_path/proceedings_record.log") 2>&1


#Activating miniconda environment tools_qc
    echo "Activating environment $env_name ..."
    #as the script initiates a new shell simply doing conda activate doesnt work
    #first we need to get the conda path wsing which conda
    # 2x dirname makes us go up 2 directories getting to the miniconda3 path
    # $ gets the output 
    conda_base=$(dirname "$(dirname "$(which conda)")")
    #trough this direcotry we can call the conda.sh that activates the conda environment
    source "$conda_base/etc/profile.d/conda.sh"
    conda activate "$env_name"

    #$CONDA_DEFAULT_ENV is a command already present in conda, that tells the active environment we are on
    if [ "$CONDA_DEFAULT_ENV" = "$env_name" ]; then
        echo "Environment activated!"
    else
        echo "Failed to activate environment!"
        exit 1 #exits the script and the 1 indicates to the log file that the an error occured
    fi



#loop through all samples with "_R1.fastq" in the name
for R1 in "$raw_path"/*_R1.fastq.gz; do

    #get the sample name - basename removes the path name and _R1.fastq.gz
    sample_name=$(basename "$R1" "_R1.fastq.gz")

    # finds the respective R2 by associating _R2.fastq... to the sample name 
    R2="$raw_path/${sample_name}_R2.fastq.gz"

    #check if R2 exists in the 01_rawdata
    if  [ -f  "$R2" ]; then
    echo "The paired R2 read exists in the directory: $raw_path"
    else
    echo  "Make sure to put the paired fasta file (..._R2.fastq.gz) in the directory: $raw_path"
    continue #skip to the next iteration
    fi

    #atributes with the path to the output files 
    ptrim_R1="$trim_path/${sample_name}_R1_trimmed.fastq.gz"
    ptrim_R2="$trim_path/${sample_name}_R2_trimmed.fastq.gz"
    utrim_R1="$trim_path/${sample_name}_R1_unpaired.fastq.gz"
    utrim_R2="$trim_path/${sample_name}_R2_unpaired.fastq.gz"

    #Checks if the files trimmed with the paired reads already exist, it will skip the ones that exist if this isnt a rerun to improve parameters
    if  [[ -f "$ptrim_R1" && -f "$ptrim_R2" && "$answr4" == "no" ]]; then
    echo "The paired output files already exist in the directory: $trim_path"
    continue #skip to the next iteration
    fi

    #dizer que esta a fazer o QC
    echo "Executing QC for sample: $sample_name"

    #Creates a directory inside 02_qc_data for untrimmed files for each sample, -p allows to overwrite files
    ut_sample_qc_path="$qc_path/${sample_name}_ut"
    mkdir -p "$ut_sample_qc_path"

    #qc for the untrimmed files
    fastqc -o "$ut_sample_qc_path" "$R1" "$R2"

    #Anouncing the begining of trimming
    echo "Executing trimming for sample: $sample_name"

    #talvez explicar as definicoes
    trimmomatic PE -threads 4 \
        "$R1" "$R2" \
        "$ptrim_R1" "$utrim_R1" \
        "$ptrim_R2" "$utrim_R2" \
        "$illuminaclip" \
        "$leading" \
        "$trailing" \
        "$slidingwindow" \
        "$minlen"

    
    #Creates a directory inside 02_qc_data for trimmed files for each sample, -p allows to overwrite files
    t_sample_qc_path="$qc_path/${sample_name}_t"
    mkdir -p "$t_sample_qc_path"

    #QC for paired trimmed files 
    echo "Executing QC for trimmed files in: $sample_name"
    fastqc -o "$t_sample_qc_path" "$ptrim_R1" "$ptrim_R2"

    #multi qc - selects first fastqc report produced for the sample
    multiqc "$ut_sample_qc_path" \
        -o "$ut_sample_qc_path/${sample_name}_ut_multiqc" \
        -n "${sample_name}_ut_multiqc_report.html"  #create a subdirectory for each sample  and name the report for each sample

    #multi qc - selects first fastqc report produced for the sample
    multiqc "$t_sample_qc_path" \
        -o "$t_sample_qc_path/${sample_name}_t_multiqc" \
        -n "${sample_name}_t_multiqc_report.html"  #create a subdirectory for each sample  and name the report for each sample

    echo "MultiQC for $sample_name done"

done