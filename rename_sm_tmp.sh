touch replace_files_sm.csv

for i in *.shp
do
echo 
echo
input_tile=$(basename "$i" _sm.shp)
echo "Working on" $input_tile

#input_tile=ncei19_n29X50_w094X75_2021v1
year=2021
existing_tiles=all_dc_tiles.csv


echo "Input tile is" $input_tile
input_tile_base=${input_tile%_*}
echo "Input tile base is" $input_tile_base





echo "Searching for" $input_tile_base "in" $existing_tiles
search_result=$(grep -iF "$input_tile_base" $existing_tiles)

echo "Search result is" $search_result
if [ -z "${search_result}" ]; 
then
	echo "No previous version found"

else
	echo "Previous version found"
	#add to csv
	echo $input_tile >> replace_files_sm.csv

	version=$(echo "$search_result" | sed -e 's/\(^.*v\)\(.*\)\(.tif.*$\)/\2/')
	echo "Version is" $version

	update_version=$(($version + 1))
	echo "Renaming File to Next Version Number, v"$update_version

	input_tile_base=${input_tile%_*}
	echo "Base is" $input_tile_base

	new_extension=${year}"v"${update_version}
	echo "New extension is" $new_extension

	echo "Renaming shp to new version name" $input_tile_base"_"$new_extension"_sm.shp"
	mv $input_tile"_sm.shp" $input_tile_base"_"$new_extension"_sm.shp"
	mv $input_tile"_sm.dbf" $input_tile_base"_"$new_extension"_sm.dbf"
	mv $input_tile"_sm.shx" $input_tile_base"_"$new_extension"_sm.shx"
	mv $input_tile"_sm.prj" $input_tile_base"_"$new_extension"_sm.prj"
fi
done
