#!/bin/bash
### Blockmedian all the xyz files in the current directory to 1/9th arc-sec and gzip the originals.

if [ ${#@} == 1 ];
then
    inc=$1
else
    #slightly finer than 1/9th arc-sec
    inc=".1s"
fi


total_files=$(ls -1 | grep '\.xyz$' | wc -l)
echo "Total number of xyz files to process:" $total_files

file_num=1

gmt gmtset IO_COL_SEPARATOR space

for i in *.xyz; do
    echo "Running blockmedian on" $i;
    echo "Processing" $file_num "out of" $total_files
    gmt blockmedian $i -I$inc $(gmt gmtinfo $i -I-) -Q > $(basename $i .xyz)_bm.xyz;
    gzip $i;
    file_num=$((file_num + 1))
    echo
done
