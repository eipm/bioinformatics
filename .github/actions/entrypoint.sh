#!/bin/sh
echo "Hello"
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
