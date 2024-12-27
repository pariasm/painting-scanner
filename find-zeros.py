import iio
import sys

if __name__ == "__main__":

	if len(sys.argv) != 2:
		print("Usage: python find-zeros.py <image_filename> <out_filename>")
		sys.exit(1)

	image_filename = sys.argv[1]

	# Read the image
	image = iio.read(image_filename)

	iio.write(out_filename,
              (image[:,:,0] + image[:,:,1] + image[:,:,2]) < 10)

