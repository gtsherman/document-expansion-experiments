import argparse

options = argparse.ArgumentParser()
options.add_argument('ttest_file', help='The output of ttest.py')
args = options.parse_args()

current_target = ''
current_data = []
with open(args.ttest_file) as f:
	for line in f:
		if len(line.strip()) == 0:
			continue
		elif 'p-value' in line:
			current_data.append(line.strip().split()[-1])
			print(','.join(current_data))
			current_data = []
			current_target = ''
		else:
			run, score = line.strip().split()
			run_parts = run.split('/')
			target = run_parts[0]
			expansion = run_parts[1]
			if target != current_target:
				current_target = target
				current_data.append(target)
			current_data.append(expansion)
			current_data.append(score)
