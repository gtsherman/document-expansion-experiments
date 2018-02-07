#!/bin/bash

# Some initial stuff
echo "---Running $1/$2---"
TMPDIR="/home/gsherma2/tmp"
mkdir -p $TMPDIR
config=${1}.${2}.properties

# The main event
echo "Running in parallel..."
#time parallel --bar --slf /home/gsherma2/doc-exp/res/nodes --sshdelay 0.5 --tmpdir $TMPDIR --workdir /hdfsd02/scratch/out --return expTerms:{1},query:{2} --cleanup "/home/gsherma2/doc-exp/run/java/runRMExpansion /home/gsherma2/doc-exp/config/$config {1} {2} > expTerms:{1},query:{2}" ::: 5 10 20 50 ::: $(python3 /home/gsherma2/doc-exp/run/python/get_queries_json.py /home/gsherma2/doc-exp/config/$config)
parallel --bar --slf /home/gsherma2/doc-exp/res/nodes --sshdelay 0.5 --tmpdir $TMPDIR --workdir /hdfsd02/scratch/out --return query:{1} --cleanup "/home/gsherma2/doc-exp/run/java/runRMExpansion /home/gsherma2/doc-exp/config/$config {1} > query:{1}" ::: $(python3 /home/gsherma2/doc-exp/run/python/get_queries_json.py /home/gsherma2/doc-exp/config/$config)

# Split the files up into unique parameter settings
echo "Splitting files..."
awk '{ print >> $6 }' query:* 
rm query:* 
parallel --bar -j 11 "cat *,fbOrigWeight:{1},fbDocs:{2},fbTerms:{3} > fbOrigWeight:{1},fbDocs:{2},fbTerms:{3}" ::: $(seq 0 0.1 1) ::: $(seq 10 10 50) ::: $(seq 10 10 50)
rm origW:*

# Move the files to their proper place
echo "Moving files..."
out="/home/gsherma2/doc-exp/out/$1/$2/rm3/out"
scored="$out/scored"
mkdir -p $scored
mv fbOrigWeight:* $out

# Score the output files
echo "Scoring runs..."
for result in $(ls $out | grep origW)
do
  trec_eval9 -q -m all_trec /home/gsherma2/doc-exp/res/qrels/qrels.$1 $out/$result > $scored/$result
done

echo "Done"
