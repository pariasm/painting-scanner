import iio
import sys
import numpy as np

if __name__ == "__main__":

	if len(sys.argv) != 5:
		print("Usage: python join-channels.py <channel0> <channel1> <channel2> <output>")
		sys.exit(1)

	ch0_filename = sys.argv[1]
	ch1_filename = sys.argv[2]
	ch2_filename = sys.argv[3]
	out_filename = sys.argv[4]

	# Read the image
	iio.write(out_filename, np.stack((iio.read(ch0_filename),
	                                  iio.read(ch1_filename),
	                                  iio.read(ch2_filename)), axis=2))

