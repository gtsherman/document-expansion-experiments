import sys

with open(sys.argv[1]) as f:
	for line in f:
		query, params = line.strip().split()
		origW = params.split(',')[0]
		origW_val = origW.split(':')[-1]
		expW = 1.0 - float(origW_val)
		print(query, 'expW:{},{}'.format(str(expW), params))
