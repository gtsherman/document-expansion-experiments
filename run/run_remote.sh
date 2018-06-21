#!/bin/bash

# Some initial stuff
time1="$(date)"
echo "-----Running $1/$2: $(date)-----"
TMPDIR="/home/gsherma2/tmp"
mkdir -p $TMPDIR
config=${1}.${2}.properties

# The main event
parallel --bar --slf /home/gsherma2/doc-exp/res/nodes --sshdelay 0.5 --tmpdir $TMPDIR --workdir /hdfsd02/scratch/out --return expTerms:{1},query:{2} --cleanup "/home/gsherma2/doc-exp/run/java/runExpansion /home/gsherma2/doc-exp/config/$config {1} {2} > expTerms:{1},query:{2}" ::: 5 10 20 50 ::: $(python3 /home/gsherma2/doc-exp/run/python/get_queries_json.py /home/gsherma2/doc-exp/config/$config)

# Split the files up into unique parameter settings
echo "Splitting files..."
awk '{ print >> $6 }' expTerms:*,query:* 
rm expTerms:*,query:* 

# Move the files to their proper place
out="/home/gsherma2/doc-exp/out/$1/${2}/out/"
echo "Moving files..."
mv *origW:* $out

# Score the output files
echo "Scoring results..."
cd $out
/home/gsherma2/doc-exp/run/bash/score.sh $1

# Get optimal params
/home/gsherma2/cross-validation/run.py -d scored -r 1 -k 10 -m map --raw-dir . > ../cv.k:10,r:1,m:map
cut -d ' ' -f 1,6 ../cv.k\:10\,r\:1\,m\:map | sort -u > ../optimal_perq.map
/home/gsherma2/cross-validation/run.py -d scored -r 1 -k 10 -m ndcg_cut_20 --raw-dir . > ../cv.k:10,r:1,m:ndcg
cut -d ' ' -f 1,6 ../cv.k\:10\,r\:1\,m\:ndcg | sort -u > ../optimal_perq.ndcg

# Compress the output files
tar -czf results.tar.gz *origW*
rm *origW*

echo "Began: $time1"
echo "Done: $(date)"
