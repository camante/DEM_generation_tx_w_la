#!/bin/bash

function help () {
echo "las2xyz - A simple script that converts all .las files in a directory to .xyz files and reprojects to geographic coords for a provided classification"
	echo "Usage: $0 class"
	echo "* class: <the desired lidar return>
	0 Never classified
	1 Unassigned
	2 Ground
	3 Low Vegetation
	4 Medium Vegetation
	5 High Vegetation
	6 Building
	7 Low Point
	8 Reserved
	9 Water
	10 Rail
	11 Road Surface
	12 Reserved
	13 Wire - Guard (Shield)
	14 Wire - Conductor (Phase)
	15 Transmission Tower
	16 Wire-Structure Connector (Insulator)
	17 Bridge Deck
	18 High Noise"
}

total_files=$(ls -1 | grep '\.zip$' | wc -l)
echo "Total number of zip files to process:" $total_files

file_num=1

#see if 5 parameters were provided
#show help if not
if [ ${#@} == 1 ]; 
then
	#User inputs    	
	class=$1
	for i in *.zip;
	do
		echo "Processing File" $file_num "out of" $total_files

		if [ -f $(basename $i .zip)"_class_"$class"_bm.xyz" ]; then
			echo "bm xyz already exists, skipping..."
		else
			echo "Unzipping:" $i
			unzip $i
			echo "Reprojecting:" $i
			las2las -i $(basename $i .zip)".las" -o $(basename $i .zip)"_latlon.las" -target_longlat -target_meter
			echo "Converting to xyz:" $i
			las2txt -i $(basename $i .zip)"_latlon.las" -keep_class $class -o $(basename $i .zip)"_class_"$class.xyz -parse xyz
			rm $(basename $i .zip)"_latlon.las"

			num_lines=$(< "$(basename $i .zip)"_class_"$class".xyz"" wc -l)
			echo "Number of lines in XYZ file is" $num_lines

			if (( $num_lines > 1000 )); then
				echo "Running blockmedian"
				gmt blockmedian $(basename $i .zip)"_class_"$class.xyz -I0.1s $(gmt gmtinfo $(basename $i .zip)"_class_"$class.xyz -I-) -Q > $(basename $i .zip)"_class_"$class"_bm.xyz";
			else
				echo "Small file, skipping blockmedian"
				cp $(basename $i .zip)"_class_"$class.xyz $(basename $i .zip)"_class_"$class"_bm.xyz"
			fi
				echo "Gzipping original xyz"
				gzip $(basename $i .zip)"_class_"$class.xyz
				rm $(basename $i .zip)".las"
				rm $(basename $i .zip)"_meta.html"
				rm $(basename $i .zip)"_meta.xml"
				rm $(basename $i .zip)"_meta.txt"
				rm NED_DataDictionary.url
				rm SpatialMetadata.url
		fi
		file_num=$((file_num + 1))
		echo
	done
else
	help
fi
