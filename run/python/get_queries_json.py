#!/usr/bin/python3
#
# Note: Super super naive, will fail if not called perfectly. Should fix someday

import json
import sys


config_file = sys.argv[1]
with open(config_file) as f:
	for line in f:
		parts = [part.strip() for part in line.split('=')]
		if parts[0] == 'queries':
			queries_file = parts[1]

queries = []
with open(queries_file) as f:
	data = json.load(f)
	for query in data['queries']:
		queries.append(query['title'])

print(' '.join(queries))
