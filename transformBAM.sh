#!/bin/bash 
if [[ "$VERBOSE" = U ]];then
    set -x
fi

PROGRAM=$0

usage() {
    echo -e "Usage:\tbash $PROGRAM [-i|--file-in] [-o|--file-out] [-p|--pm-in] [-r|--pm-out]"
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
        -o | --file-out )   shift
                            FILE_OUT=$1
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
logMsg "INFO" "Creating new header"
samtools view -H $FILE_IN -@ 8 | sed "s%$PM_IN%$PM_OUT%g" > BAM.new.header.sam.txt
logMsg "INFO" "Checking new header for PM IDs"
if [[ $(grep -c $PM_IN BAM.new.header.sam.txt) -gt 0 ]];then
        logMsg "ERROR" "Found PM ID in header"
fi
logMsg "INFO" "Checking BAM file for PM IDs"
if [[ $(samtools view $FILE_IN | grep -c $PM_IN) -lt 1 ]];then
        logMsg "INFO" "No PM IDs found in BAM file. Simply re-head the BAM file"
        samtools reheader -P BAM.new.header.sam.txt $FILE_IN > $FILE_OUT
else
        logMsg "WARN" "Found PM IDs in BAM file. Need to change it. See an example:"
        samtools view $FILE_IN | grep $PM_IN | head -n 2
        cleanUp -3
fi
echo "Checking the final output for PM IDs"
if [[ $(samtools view -H  -@8 $FILE_OUT | grep -c $PM_IN) -gt 0 ]];then
        logMsg "ERROR" "Found PM IDs in the header"
fi
if [[ $(samtools view     -@8 $FILE_OUT | grep -c $PM_IN) -gt 0 ]];then
        logMsg "ERROR" "Found PM IDs in the BAM file"
fi
logMsg "INFO" "No PM IDs found in the header or the BAM file"
logMsg "INFO" "Indexing the file"
samtools index -@ 8 $FILE_OUT
logMsg "INFO" "-------- END Transformation ----"
cleanUp 0
