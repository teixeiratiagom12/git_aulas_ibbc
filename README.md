[README.md](https://github.com/user-attachments/files/23776140/README.md)
------------------------------------------------------------------------

# 🔬 Quality Control & Trimming Pipeline

### *Project: Project\_ibbc\_TiagoTeixeira*

This repository contains **three bash scripts** designed to prepare the
environment, set up the project structure, and run a full QC + trimming
workflow for paired-end FASTQ files.

The scripts **must be executed in order**:

1.  **Script3.sh:** Verify and install required Conda packages
2.  **Script1.sh:** Create project directory structure
3.  **Script2.sh:** Perform QC, trimming, and reporting

------------------------------------------------------------------------

# 📌 Overview

This workflow automates:

-   Required packages installation
-   Directory and workspace creation
-   FASTQ quality control (raw and trimmed) with fastqc
-   Read trimming with Trimmomatic
-   MultiQC report generation
-   Logging of all pipeline steps

It is designed to work on a server environment where each user has a
personal directory (e.g., `/home/username`).

------------------------------------------------------------------------

# ⚙️ Requirements

Before running this pipeline, ensure:

-   **Conda** is installed and functional

-   You have a working user directory on the server

-   Your paired FASTQ files follow this naming format:

        <sample_name>_R1.fastq.gz
        <sample_name>_R2.fastq.gz

-   You have a conda environment to install the necessary packages
    (beware that in script 2 and 3 i use a conda environment called
    “tools\_qc”, so if your environment has other name you have to
    change the **env\_name** atribute in both scripts).

-   It is **necessary** to modify the **personal\_area** atribute in script1 and 2 to your own desired **base**
    path.

------------------------------------------------------------------------

# 🚀 Script3 - Package Verification

### `script3.sh`

## **Purpose**

Checks whether the essential ( plus some extra ) bioinformatics tools
are installed in the Conda environment **`tools_qc`**. If any are
missing, the script installs them automatically.

## **Packages Checked**

-   fastqc
-   fastq-screen
-   multiqc
-   fastp
-   trimmomatic

`multiqc` and `trimmomatic` are installed via the **bioconda** channel.

## **Usage**

    bash script3.sh

The script outputs the installation status of each package.

------------------------------------------------------------------------

# 📁 Script1 — Directory Structure Setup

### `Script1.sh`

## **Purpose**

Creates the required project directory and subdirectories inside the
user’s server area.

## **Directories Created**

    /home/<user>/
    └── Project_ibbc_TiagoTeixeira/
        ├── 01_rawdata
        ├── 02_qc_data
        ├── 03_trimmed_data
        └── 04_logs

## **Usage**

    bash script1.sh

This script should be run **after Script 1**, before placing FASTQ files
into `01_rawdata`.

------------------------------------------------------------------------

# 🧬 Script2 — QC & Trimming Pipeline

### `script2.sh`

## **Purpose**

Processes paired-end FASTQ files by performing:

1.  Filename verification
2.  Optional trimming parameter modification
3.  Optional rerun mode - rerun mode allows the overwriting of the
    existing files
4.  QC on raw (untrimmed) reads (FastQC)
5.  Trimming (Trimmomatic)
6.  QC on trimmed reads (FastQC)
7.  MultiQC reports (for both untrimmed and trimmed data)
8.  Logging all operations

------------------------------------------------------------------------

## **Input options**

### **Standardize raw data names**

Making sure that all the files follow the
<sample_name>\_R<paired_read_number>. fastq.gz standard.

    echo "Before starting, make sure that all the files are named <sample_name>_R1.
    fastq.gz or <sample_name>_R2.fastq.gz."
    <your files>
    echo "Do you want to proceed? <yes/no>"

Answering **yes** will continue the script, answering \***no** will exit
the script and allow you to standardize the file names for the raw data.

### **Change trimming settings**

Default Trimming Settings

    trimming will be made with the script default settings:ILLUMINACLIP:
    TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    Do you want to change the trimming settings? <yes/no>

Answering **no** continues the script with deafault settings. Answering
**yes** allows the user to modify each setting used. To modify, for
example, the ILLUMINACLIP setting you should follow the exact
Trimmomatic structure after “ILLUMINACLIP:”. This is the expected
output:

    Define the trimming settings:
    ILLUMINACLIP:

Your input should be something like this:

    TruSeq3-PE.fa:2:40:10

Be specially carefull to avoid adding spaces!

### **Rerun option**

    Are you rerunning the script to improve parameters? <yes/no>

Answering **yes** will allow overwriting the data, answering \***no**
will will not allow overwriting the data, and will skip already trimmed
samples in case the script stopped mid analysis.

------------------------------------------------------------------------

## **Output Generated per Sample**

### **Untrimmed QC**

    02_qc_data/<sample>_ut/
        *_fastqc.html
        *_fastqc.zip
        <sample>_ut_multiqc/<sample>_ut_multiqc_report.html

### **Trimmed FASTQ Files**

    03_trimmed_data/
        <sample>_R1_trimmed.fastq.gz
        <sample>_R2_trimmed.fastq.gz
        <sample>_R1_unpaired.fastq.gz
        <sample>_R2_unpaired.fastq.gz

### **Trimmed QC**

    02_qc_data/<sample>_t/
        *_fastqc.html
        *_fastqc.zip
        <sample>_t_multiqc/<sample>_t_multiqc_report.html

### **Logs**

    04_logs/proceedings_record.log

------------------------------------------------------------------------

## **Usage**

    bash script2.sh

The script will prompt the user to confirm filenames, adjust trimming
settings, and indicate whether this is a rerun.

------------------------------------------------------------------------

# 🧭 Recommended Workflow

1.  **Run script3.sh** to ensure all required tools are installed:

        bash 01_check_and_install_packages.sh

2.  **Run script1.sh** to create the project structure:

        bash 02_setup_directories.sh

3.  **Place your raw FASTQ files** into:

        01_rawdata/

4.  **Run Script 3** to process all samples:

        bash 03_qc_and_trimming_pipeline.sh

5.  Review generated **FastQC**, **MultiQC**, and **trimmed FASTQ
    files**.

------------------------------------------------------------------------

# 📂 Output Structure (Final Overview)

    Project_ibbc_TiagoTeixeira/
    ├── 01_rawdata/                     # Input FASTQ files
    ├── 02_qc_data/                     # QC outputs (raw + trimmed)
    │   ├── <sample>_ut/                # Indepently untrimmed QC files and
    │   │       │                         directory with multiqc files
    │   │       └── <sample>_ut_multiqc 
    │   └── <sample>_t/                 # Indepently trimmed QC files and
    │           │                         directory with multiqc files
    │           └── <sample>_t_multiqc
    ├── 03_trimmed_data/                # Final trimmed reads
    └── 04_logs/
        └── proceedings_record.log

------------------------------------------------------------------------
