#!/bin/bash
function help () {
echo "download_mb_roi.sh - A script that downloads mb data in chunks from a WESN ROI, runs blockmedian, and then converts to xyz."
    echo "Usage: $0 name_cell_extents cellsize"
    echo "* name_cell_extents: <csv with names, cellsize, and extents>"
    echo "* cellsize: <blockmedian cell size in arc-seconds>
    0.000092592596 = 1/3rd arc-second
    0.00027777777 = 1 arc-second"
}


if [ ${#@} == 4 ]; 
then
roi_str_gmt=$1
bm_cell=$2
min_val=$3
max_val=$4

echo "roi str gmt is" $roi_str_gmt
echo "bm cellsize is" $bm_cell
echo "min mb value is" $min_val
echo "max mb value is" $max_val

mkdir -p xyz
echo "downloading all fbt files in study area ROI"
fetches mb -R $roi_str_gmt -p

echo "Moving all xyz files to main directory"
find . -name '*.xyz*' -mindepth 2 -exec mv -i -- {} . \;

echo "Running Blockmedian on "
for i in *.xyz*;
do
	echo "Working on file" $i
	gmt blockmedian $i -I$bm_cell/$bm_cell -R$roi_str_gmt -V -Q > $(basename $i .xyz)"_bm_tmp.xyz"
	awk '{printf "%.8f %.8f %.2f\n", $1,$2,$3}' $(basename $i .xyz)"_bm_tmp.xyz" > xyz/$(basename $i .xyz)"_bm.xyz"
	rm $(basename $i .xyz)"_bm_tmp.xyz"
echo
echo
done

# echo "moving all xyz files to the same directory"
# find . -name '*.xyz' -exec mv {} xyz/ \; 2>/dev/null

echo "deleting all mb files"
#rm *.mb*

else
    help
fi

#for i in */; do echo $i; cd $i; mkdir xyz; for j in *.*; do mblist -R-92.255/-88.495/28.495/31.005 -MX20 -OXYZ -I$j > xyz/$j.xyz; done; cd ..; done
