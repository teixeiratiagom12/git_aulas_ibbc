#!/bin/bash

#This script verifies if i have the main packages installed in the environment tools_qc, if any of those packages is missing, they get installed

#Atribute with the environment name
env_name="tools_qc"

#List of main packages of tools_qc
packages=(
    "fastqc"
    "fastq-screen"
    "multiqc"
    "fastp"
    "trimmomatic"
)

#Anouncing the start of the process
echo "Checking conda packages from the environment '$env_name'..."

#For cicle that searches the listed packages sequentially
for pkg in "${packages[@]}"; 
do

    #Name package that is being searched
    echo "Checking $pkg"

    # if condition that verifies if the package is installed, by comparing $pkg with the packages presented by the command "conda list tools_qc" 
    # "|"" is a pipe. It passes the "conda list..." output as input for the grep function
    # grep -q (quiet - supresses the output to the user), searches for a line that starts (^) with the package name
    if conda list -n "$env_name" | grep -q "^$pkg"; then
        
        #if the package is found within the list, then it is already installed
        echo "$pkg already installed"

    #if the package isn't found within the list, then it needs to be installed
    else
        echo "$pkg not found. Installing..."

        #as multiqc and trimmomatic use the bioconda channel to get installed, they need "-c bioconda" to be added to the conda install command
        #-y accept automatically all the questions presented during the instalation process
        if [[ "$pkg" == "multiqc" || "$pkg" == "trimmomatic" ]]; 
        then
            conda install -y -n "$env_name" -c bioconda "$pkg"
        
        #sfor the other packages use the standard conda install command
        else
            conda install -y -n "$env_name" "$pkg"
        fi
    fi
done
echo "Script concluded!"

