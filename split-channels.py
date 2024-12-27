import iio
import sys
import numpy as np

if __name__ == "__main__":

    if len(sys.argv) != 3:
        print("Usage: python split-channels.py <image_filename>  <channel_filename>")
        sys.exit(1)

    image_filename = sys.argv[1]
    channel_filename = sys.argv[2]

    # Read the image
    image = iio.read(image_filename)

    iio.write(channel_filename % 0, image[:,:,0])
    iio.write(channel_filename % 1, image[:,:,1])
    iio.write(channel_filename % 2, image[:,:,2])

