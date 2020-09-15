#!/bin/sh
echo "Program: $0"
echo "Parameter number: $#"
for var in "$@"
do
    echo "Param: $var"
done
echo "From Environmental variables"
echo "File In: $INPUT_FILE_IN"
echo "Dir Out: $INPUT_DIR_OUT"
echo "PM_IN  : $INPUT_PM_IN"
echo "PM_OUT : $INPUT_PM_OUT"

if [[ -e /usr/local/bin/transformBAM.sh ]];then
    echo "Transforming the data"
    ls -la /usr/local/bin/transformBAM.sh
    transformBAM.sh --file-in "$INPUT_FILE_IN" --dir-out "$INPUT_DIR_OUT" --pm-in "$INPUT_PM_IN" --pm-out "$INPUT_PM_OUT"
fi