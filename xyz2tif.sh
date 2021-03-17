#0.00003086420 = 1/9th arc-second 
#0.00009259259 = 1/3rd arc-second
#0.0002777778 = 1 arc-second
cellsize=0.0002777778

for i in $(find . -type f -name "*.xyz"); 
do 
	echo "$i"
	#Get minx, maxx, miny, maxy from temporary file
	minx="$(gmt gmtinfo  $i -C | awk '{print $1}')"
	maxx="$(gmt gmtinfo  $i -C | awk '{print $2}')"
	miny="$(gmt gmtinfo  $i -C | awk '{print $3}')"
	maxy="$(gmt gmtinfo  $i -C | awk '{print $4}')"
	x_diff=$(echo "$maxx - $minx " | bc -l)
	y_diff=$(echo "$maxy - $miny " | bc -l)
	cellsize_double=$(echo "$cellsize + $cellsize" | bc)

	#echo "minx is $minx"
	#echo "maxx is $maxx"
	#echo "miny is $miny"
	#echo "maxy is $maxy"
	#echo "x_diff is $x_diff"
	#echo "y_diff is $y_diff"
	#echo "cellsize_double is $cellsize_double"

	if [[ "$x_diff" < "$cellsize_double" && "$y_diff" < "$cellsize_double" ]]
	then
		echo "dims aren't twice as big as cellsize, increasing dims"
		minx=$(echo "$minx - $cellsize_double" | bc)
		miny=$(echo "$miny - $cellsize_double" | bc)
		#echo "New minx is" $minx
		#echo "New miny is" $miny

	else
		:
		#echo "dims are greater"
	fi

	full_path=$(readlink -f  "${i}")
	dir_path=$(dirname "$full_path")
	grd_name=$(basename $i .xyz).grd
	tif_name=$(basename $i .xyz).tif
	grd_full=$dir_path"/"$grd_name
	tif_full=$dir_path"/"$tif_name
	#echo $full_path
	#echo $dir_path
	#echo $grd_full
	#echo $tif_full

	echo "coverting $i to grd..."
	#echo "command: xyz2grd $i -R${minx}/${maxx}/${miny}/${maxy} -G$grd_full -I$cellsize"
	gmt xyz2grd $i -R${minx}/${maxx}/${miny}/${maxy} -G$grd_full -I$cellsize
	echo "coverting $i to tif..."
	gdal_translate -of GTiff $grd_full $tif_full -a_srs EPSG:4326 -a_nodata -999999
	rm $grd_full
	#rm $tif_full".aux.xml"
	echo

done
