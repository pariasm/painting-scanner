#!/bin/bash

# inputs
IM_PATH=$1
FIRST=$2
LAST=$3
CROP_WIDTH=$4
CROP_HEIGHT=$5
OUT_DIR=$6

# images size
WW=$(identify -format %W $(printf $IM_PATH $FIRST))
HH=$(identify -format %H $(printf $IM_PATH $FIRST))

echo $WW
echo $HH

mkdir -p $OUT_DIR

echo "crop images to remove background for better alignment"
crop_path=$OUT_DIR/crop-$(basename $IM_PATH)
for i in $(seq $FIRST $LAST); do 
	echo crop $CROP_WIDTH $CROP_HEIGHT $((WW - CROP_WIDTH)) $((HH - CROP_HEIGHT)) \
		$(printf $IM_PATH $i) $(printf $crop_path $i)
done | parallel


echo "compute homographies using ICA"
ICA="/home/pariasm/Work/optical_flow/algos/mInverseCompositional_1.00/inverse_compositional_algorithm"
transform_path=$OUT_DIR/hom-$(basename $crop_path .jpg).mat
for i in $(seq $((FIRST+1)) $LAST); do 
	$ICA $(printf $crop_path $FIRST) $(printf $crop_path $i) \
		-f $(printf $transform_path $i) \
		-t 8 -s 2 -o 1 -r 0
done

echo "re-center homographies (in-place)"
for i in $(seq $((FIRST+1)) $LAST); do 
	echo python3 ./recenter-transforms.py \
		$(printf $transform_path $i) $CROP_WIDTH $CROP_HEIGHT \
		$(printf $transform_path $i) 
done | parallel

echo "warp images"
warped_path=$OUT_DIR/w-$(basename $IM_PATH)
for i in $(seq $((FIRST+1)) $LAST); do
	echo homwarp $(printf $transform_path $i) $WW $HH \
		$(printf $IM_PATH $i) $(printf $warped_path $i)
done | parallel
cp $(printf $IM_PATH $FIRST) $(printf $warped_path $FIRST)

echo "split channels to run veco"
ch_path="$OUT_DIR/ch%%d-$(basename $warped_path)"
for i in $(seq $FIRST $LAST); do
	echo python3 split-channels.py $(printf $warped_path $i) $(printf $ch_path $i)
done | parallel

echo "run veco for each channel"
for c in 0 1 2; do
	ch_path="$OUT_DIR/ch$c-$(basename $warped_path)"
	files=""
	for j in $(seq $FIRST $LAST); do
		files+="$(printf $ch_path $j) "
	done

	for i in min q20 std; do
		veco $i $files -o $OUT_DIR/$i-ch$c.jpg
	done

	rm $files
done

echo "join per-channel vecos"
for i in min q20 std; do
	python3 join-channels.py $OUT_DIR/$i-ch{0,1,2}.jpg $OUT_DIR/$i.jpg
	rm $OUT_DIR/$i-ch{0,1,2}.jpg
done

echo "clean intermediate files"
for i in $(seq $FIRST $LAST); do
	rm $(printf $crop_path $i)
	rm $(printf $transform_path $i)
	rm $(printf $warped_path $i)
done | parallel

echo "done"

exit


# dilate zeros (to be used with veco -g nonzero
# in a first version I used these to apply veco to the aligned crops - but
# they're not necessary when working with the full images
zeros_path="$OUT_DIR/zero-$(basename $crop_path .jpg).png"
for i in $(seq $((FIRST+1)) $LAST); do
	echo "python3 find-zeros.py $(printf $crop_path $i) $(printf $zeros_path $i) &&"\
		  "morsi disk9 dilation $(printf $zeros_path $i) $(printf $zeros_path $i) &&"\
	     "python3 apply-mask.py $(printf $crop_path $i) $(printf $zeros_path $i)"
done | parallel




