mkdir -p digital_coast
mkdir -p digital_coast/LA_MS
mkdir -p digital_coast/TX
mkdir -p digital_coast/1_9
mkdir -p digital_coast/1_3
mkdir -p digital_coast/1_9/LA_MS
mkdir -p digital_coast/1_3/LA_MS
mkdir -p digital_coast/1_9/TX
mkdir -p digital_coast/1_3/TX


echo "copying LA/MS DEMs to digital coast dir"
cp *w093x75* digital_coast/LA_MS/
cp *w093x50* digital_coast/LA_MS/
cp *w093x25* digital_coast/LA_MS/
cp *w093x00* digital_coast/LA_MS/
cp *w092x75* digital_coast/LA_MS/
cp *w092x50* digital_coast/LA_MS/

cd digital_coast/LA_MS
rm -rf *.tif.inf
rm -rf *.tif.aux.xml
cd ..

echo $PWD
echo "seperating by resolution "
mv LA_MS/*ncei19* 1_9/LA_MS/ 
mv LA_MS/*ncei13* 1_3/LA_MS/

cd ..


echo "copying TX DEMs to digital coast dir"
cp *w094x00* digital_coast/TX/
cp *w094x25* digital_coast/TX/
cp *w094x50* digital_coast/TX/
cp *w094x75* digital_coast/TX/
cp *w095x00* digital_coast/TX/
cp *w095x25* digital_coast/TX/
cp *w095x50* digital_coast/TX/
cp *w095x75* digital_coast/TX/
cp *w096x00* digital_coast/TX/
cp *w096x25* digital_coast/TX/
cp *w096x50* digital_coast/TX/

cd digital_coast/TX
rm -rf *.tif.inf
rm -rf *.tif.aux.xml

cd ..

echo $PWD
echo "seperating by resolution "
mv TX/*ncei19* 1_9/TX/ 
mv TX/*ncei13* 1_3/TX/

