import iio
import sys
import numpy as np

if __name__ == "__main__":

	if len(sys.argv) != 3:
		print("Usage: python apply-mask.py <image_filename>")
		sys.exit(1)

	image_filename = sys.argv[1]
	mask_filename = sys.argv[2]

	# Read the image
	image = iio.read(image_filename)
	mask = iio.read(mask_filename)

	iio.write('masked-' + image_filename, image * (1 - mask))

