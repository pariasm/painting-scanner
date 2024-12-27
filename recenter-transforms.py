import sys
import numpy as np

def main():
	# Ensure proper usage
	if len(sys.argv) != 5:
		print("Usage: python recenter-transform.py <transform_file> <x0> <y0> <output_file>")
		sys.exit(1)

	# Parse command-line arguments
	transform_file = sys.argv[1]
	x0 = float(sys.argv[2])
	y0 = float(sys.argv[3])
	output_file = sys.argv[4]

	# Read the homography matrix from the file
	with open(transform_file, 'r') as f:
		transform_params = list(map(float, f.read().split()))

	if len(transform_params) != 9:
		raise ValueError("Transform file must contain exactly 9 numbers.")

	H = np.array(transform_params).reshape(3, 3)
	A = H[0:2,0:2]
	b = H[0:2,2:3]
	c = H[2:3,0:2]
	d = H[2:3,2:3]

	q0 = np.array([[x0],[y0]])
	rA = A + q0 @ c
	rb = b + q0 - rA @ q0
	rd = 1 - c @ q0
	rH = np.concatenate((np.concatenate((rA, rb), axis=1),
	                     np.concatenate(( c, rd), axis=1)), axis=0)

	# Write the adjusted homography to the output file
	with open(output_file, 'w') as f:
		f.write(" ".join(map(str, rH.flatten())) + "\n")

if __name__ == "__main__":
	main()
