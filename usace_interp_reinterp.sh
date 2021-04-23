#!/bin/bash

function help () {
echo "usace_interp - A simple script that converts all .xyz files in a directory to .grd files for a provided cell size, fills in no data to a specificed amounts, resamples to finer resolution, and converts to xyz"
	echo "Usage: $0 lastools_path concavity_val initial_cellsize final_cellsize nodata_fill smooth_iterations"
	echo "* lastools_path: <path to lastools bin with lasboundary64.exe>
	e.g., /media/sf_C_win_lx/software/LAStools/bin"
	echo "* concavity_val: <concavity value to generate shp to clip final xyz"
	echo "* initial_cellsize: <cell size in arc-seconds>
	0.00003086420 = 1/9th arc-second 
	0.00009259259 = 1/3rd arc-second
	0.00027777777 = 1 arc-second"
	echo "* final_cellsize: <cell size in arc-seconds>
	0.00003086420 = 1/9th arc-second 
	0.00009259259 = 1/3rd arc-second
	0.00027777777 = 1 arc-second"
	echo "* nodata_fill: <number of nodata cells to fill>"
	echo "* smooth_iterations: <number of smooth iterations for no data fill>"
	echo "* coast_shp: <coastline shp to clip survey to>"
	
}

#see if 5 parameters were provided
#show help if not
if [ ${#@} == 7 ]; 
then
	#User inputs    	
	lastools_path=$1
	concavity_val=$2
	initial_cellsize=$3
	final_cellsize=$4
	nodata_fill=$5
	smooth_iterations=$6
	coast_shp=$7

	#./usace_interp_reinterp.sh /media/sf_C_win_lx/software/LAStools/bin 0.01 0.00009259259 0.00003086420 20 5 

	

	echo "Copying LAStools license"
	cp $lastools_path/lastoolslicense.txt lastoolslicense.txt 

	echo "Copying lasboundary64.exe to current directory"
	cp $lastools_path/lasboundary64.exe lasboundary64.exe

	mkdir -p interp
	mkdir -p interp/shp

	for i in *.xyz;
	do
		#Create tmp text file of minmax for each xyz file
		#minmax $i > minmax_tmp.txt
	
		#Get minx, maxx, miny, maxy from temporary file
		minx="$(gmt gmtinfo  $i -C | awk '{print $1}')"
		maxx="$(gmt gmtinfo  $i -C | awk '{print $2}')"
		miny="$(gmt gmtinfo  $i -C | awk '{print $3}')"
		maxy="$(gmt gmtinfo  $i -C | awk '{print $4}')"
		#short_name = 

		echo "minx is $minx"
		echo "maxx is $maxx"
		echo "miny is $miny"
		echo "maxy is $maxy"

		echo "Creating Polygon for " $i
		wine ./lasboundary64.exe -i $i -o $(basename $i .xyz).shp -concavity $concavity_val

		echo "coverting $i to grd"
		gmt xyz2grd $i -R${minx}/${maxx}/${miny}/${maxy} -G$(basename $i .xyz).grd -I$initial_cellsize/$initial_cellsize
		
		echo "Converting $i to tif"
		gmt grdconvert $(basename $i .xyz).grd $(basename $i .xyz).tif=gd:GTiff
		
		echo "Filling in nodata values up to $nodata_fill cells from data"
		#gdal_fillnodata.py -md $nodata_fill -si $smooth_iterations $(basename $i .xyz).tif $(basename $i .xyz)_fill.tif
		#smooth iterations causing failure, removed parameter below
		gdal_fillnodata.py -md $nodata_fill $(basename $i .xyz).tif $(basename $i .xyz)_fill.tif
		
		echo "Resampling to target resolution"
		gdalwarp $(basename $i .xyz)_fill.tif -r bilinear -tr $final_cellsize $final_cellsize‬ $(basename $i .xyz)_fill_resamp.tif

		echo "Clipping to Survey Polygon"
		gdal_rasterize -i -burn nan -l $(basename $i .xyz) $(basename $i .xyz).shp $(basename $i .xyz)_fill_resamp.tif 

		echo "Clipping Coastline to ROI"
		#Get minx, maxx, miny, maxy from temporary file
		x_min="$(gmt grdinfo  $(basename $i .xyz)_fill_resamp.tif -C | awk '{print $2}')"
		x_max="$(gmt grdinfo  $(basename $i .xyz)_fill_resamp.tif -C | awk '{print $3}')"
		y_min="$(gmt grdinfo  $(basename $i .xyz)_fill_resamp.tif -C | awk '{print $4}')"
		y_max="$(gmt grdinfo  $(basename $i .xyz)_fill_resamp.tif -C | awk '{print $5}')"
		echo $x_min
		echo $x_max
		echo $y_min
		echo $y_max

		ogr2ogr -f "ESRI Shapefile" "coast_clip.shp" $coast_shp.shp -clipsrc $x_min $y_min $x_max $y_max

		echo "Clipping to Coastline"
		gdal_rasterize -burn nan -l "coast_clip" "coast_clip.shp" $(basename $i .xyz)_fill_resamp.tif

		echo "Converting to XYZ"
		gdal_translate -of xyz $(basename $i .xyz)_fill_resamp.tif $(basename $i .xyz)_fill_resamp.xyz
		
		echo "Removing Nodata values"
		grep -v nan $(basename $i .xyz)_fill_resamp.xyz | awk '{printf "%.8f %.8f %.2f\n", $1,$2,$3}' > interp/$(basename $i .xyz)_interp.xyz

		rm $(basename $i .xyz).grd
		rm $(basename $i .xyz).tif
		rm $(basename $i .xyz).tif.aux.xml
		rm $(basename $i .xyz)_fill.tif
		rm $(basename $i .xyz)_fill_resamp.tif
		rm $(basename $i .xyz)_fill_resamp.xyz

		mv $(basename $i .xyz).shp interp/shp/$(basename $i .xyz).shp
		mv $(basename $i .xyz).shx interp/shp/$(basename $i .xyz).shx
		mv $(basename $i .xyz).dbf interp/shp/$(basename $i .xyz).dbf
		#mv $(basename $i .xyz).prj interp/shp/$(basename $i .xyz).prj
		rm "coast_clip.shp"
		rm "coast_clip.dbf"
		rm "coast_clip.prj"
		rm "coast_clip.shx"
	
	done

echo "Moving Shps to subdirectory"


echo "Creating datalist"
cd interp
./create_datalist.sh usace_dredge_interp

else
	help

fi































