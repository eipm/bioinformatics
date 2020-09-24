#!/bin/bash 
if [[ "$VERBOSE" = U ]];then
    set -x
fi

PROGRAM=$0

usage() {
    echo -e "Usage:\tbash $PROGRAM [-i|--file-in] [-o|--dir-out] [-p|--pm-in] [-r|--pm-out]"
}
cleanUp() {
        if [[ -e BAM.new.header.sam.txt ]];then
                rm BAM.new.header.sam.txt
        fi
        exit $1
}
logMsg() {
        if [[ $# -lt 2 ]];then
                printf "\nUsage: logMsg 'message_type' msg\nwhere 'message_type is one of 'INFO', 'WARN', 'DEBUG', or 'ERROR'.\n"
                cleanUp -1
        fi
        printf "[%s]:\t[%s]\t%s\n" "$(date)" "$1" "$2"
        if [[ "$1" == ERROR ]];then
                cleanUp 9
        fi
}

if [[ $# -ne 8 ]];then
    usage
    cleanUp 127
fi

while [ "$1" != "" ]; do
    case $1 in
        -i | --file-in )    shift
                            FILE_IN=$1
                            ;;
        -o | --dir-out )    shift
                            DIR_OUT=$1
                            ;;
        -p | --pm-in )      shift
                            PM_IN=$1
                            ;;
        -r | --pm-out )     shift 
                            PM_OUT=$1
                            ;;
        * )                 usage
                            cleanUp 0
    esac
    shift
done

logMsg "INFO" "--------------------- START Transformation -----------------------"
if [[ ! -e "$FILE_IN" ]];then
    logMsg "ERROR" "Input file does not exists: ($FILE_IN)"
fi
DIR_IN="$(pwd)"
logMsg "INFO" "Calculating number of entries in original BAM."
originalSize=$(samtools view -c -@ 8 "$DIR_IN/$FILE_IN")
if [[ ! -e "$DIR_OUT" ]];then
    logMsg "WARN" "Output folder does not exist: ($DIR_OUT).\nCreating it now."
    mkdir -p $DIR_OUT
fi
logMsg "DEBUG" "Directory Out: ($DIR_OUT)"
FILE_OUT=$(basename $FILE_IN | sed "s%$PM_IN%$PM_OUT%g")
logMsg "DEBUG" "File Name Out: ($FILE_OUT)"

cd "$DIR_OUT"
logMsg "INFO" "Making sure it's in samtools v10 format"
samtools view -H "$DIR_IN/$FILE_IN" -@ 8 | sed "s%FCID:%FC:%g" | sed "s%BCID:%BC:%g" | sed "s%LNID:%LN:%g" > BAM.v10.header.txt || logMsg "ERROR" "Something wrong with generating the v10 header."
samtools reheader -P BAM.v10.header.txt "$DIR_IN/$FILE_IN" > sample.v10.bam || logMsg "ERROR" "Something wrong with v10 header transformation."
rm BAM.v10.header.txt
logMsg "INFO" "Checking that the v10 version is equivalent to the original BAM"
newSize=$(samtools view -c -@ 8 sample.v10.bam)
if [[ ! $originalSize -eq $newSize ]];then
        logMsg "ERROR" "The v10 version is different from the original BAM file."
fi      
logMsg "INFO" "Splitting the BAM by @RGs"
samtools split -@ 8 -u sample.v10.noRG.bam:sample.v10.bam -f "sample.v10_%#.%."  sample.v10.bam || logMsg "ERROR" "Splitting didn't work"
rm sample.v10.bam
if [[ $(samtools view -c -@ 8 sample.v10.noRG.bam ) == 0 ]];then
        logMsg "INFO" "All reads have a valid RG"
        rm sample.v10.noRG.bam
else
        logMsg "WARN" "Some reads don't have an RG"
fi
for currentBAM in sample.v10_*.bam
do
        logMsg "DEBUG" "Processing ($currentBAM)"
        logMsg "INFO" "Creating new header with the new IDs"
        samtools view -H "$currentBAM" -@ 8 | sed "s%$PM_IN%$PM_OUT%g"  > currentBAM.new.header.txt || logMsg "ERROR" "Something wrong with generating the sanitized header."

        logMsg "INFO" "Checking new header for old IDs"
        if [[ $(grep -c "$PM_IN" currentBAM.new.header.txt) -gt 0 ]];then
                logMsg "ERROR" "Found IDs in the new header for $currentBAM"
        fi        

        logMsg "INFO" "Getting the new RG_ID from the new header"
        RG_ID=$(grep "^@RG" currentBAM.new.header.txt | awk '{print $2}' | sed -r 's%^ID:(.*)$%\1%')
        
        logMsg "DEBUG" "New RG_ID: ($RG_ID)"

        logMsg "INFO" "Assigning the new header"
        samtools reheader -P currentBAM.new.header.txt "$currentBAM" > tmp.bam || logMsg "ERROR" "Reheader had some issues"
        rm "$currentBAM" # to save space
        logMsg "INFO" "Replacing RGs"
        samtools addreplacerg -@ 8 -R $RG_ID -o "$currentBAM".rg.bam tmp.bam || logMsg "ERROR" "Something wrong with replacing RG for $RG_ID"
        rm tmp.bam currentBAM.new.header.txt
        logMsg "INFO" "Checking BAM file for old IDs"
        if [[ $(samtools view -@ 8 "$currentBAM".rg.bam | grep -c $PM_IN) -gt 0 ]];then
                logMsg "ERROR" "Found old IDs in BAM file. Need to change it. See an example: $(samtools view -@ 8 "$currentBAM".rg.bam | grep $PM_IN | head -n 2)"
        else
                logMsg "INFO" "No old IDs found in BAM file."
        fi
done
logMsg "INFO" "Creating the list of BAM files to merge"
logMsg "DEBUG" "Current directory: $(pwd)"
ls -1 sample.v10_*.bam.rg.bam > bam_files_to_merge || logMsg "ERROR" "Cannot create a list of BAM files"
samtools merge -b bam_files_to_merge -c -p -@ 8 $FILE_OUT || logMsg "ERROR" "Merging didn't work"
logMsg "DEBUG" "Removing temporary files"
cat bam_files_to_merge | xargs rm || logMsg "ERROR" "Cannot remove temporary BAM files sample.v10*"
rm bam_files_to_merge|| logMsg "ERROR" "Cannot remove bam_files_to_merge"

logMsg "INFO" "Checking the final output for PM IDs"
if [[ $(samtools view -H  -@ 8 $FILE_OUT | grep -c $PM_IN) -gt 0 ]];then
        logMsg "ERROR" "Found old IDs in the header"
fi
if [[ $(samtools view     -@ 8 $FILE_OUT | grep -c $PM_IN) -gt 0 ]];then
        logMsg "ERROR" "Found old IDs in the BAM file"
fi
logMsg "INFO" "No old IDs found in the header or the BAM file"
logMsg "INFO" "Indexing the file"
samtools index -@ 8 $FILE_OUT || logMsg "ERROR" "Indexing failed $FILE_OUT"
logMsg "DEBUG" "Checking that all reads are included from the original BAM file"
newSize=$(samtools view -c -@ 8 $FILE_OUT)
if [[ ! $originalSize -eq $newSize ]];then
        logMsg "ERROR" "The new final version is different from the original BAM file."
fi  
logMsg "INFO" "-------- END Transformation ----"
cleanUp 0