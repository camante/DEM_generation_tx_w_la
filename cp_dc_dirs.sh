mkdir -p digital_coast
mkdir -p digital_coast/LA_MS
mkdir -p digital_coast/TX

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
