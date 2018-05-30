#!/bin/bash

# Some initial stuff
echo "Running $1/$2: $(date)"
TMPDIR="/home/gsherma2/tmp"
mkdir -p $TMPDIR
config=${1}.${2}.properties

# The main event
time parallel --bar --slf /home/gsherma2/doc-exp/res/nodes --sshdelay 0.5 --tmpdir $TMPDIR --workdir /hdfsd02/scratch/out --return expTerms:{1},query:{2} --cleanup "/home/gsherma2/doc-exp/run/java/runQueryDependExpanded /home/gsherma2/doc-exp/config/$config {1} {2} > expTerms:{1},query:{2}" ::: 5 10 20 50 ::: $(python3 /home/gsherma2/doc-exp/run/python/get_queries_json.py /home/gsherma2/doc-exp/config/$config)

# Split the files up into unique parameter settings
echo "Splitting files..."
for f in $(ls expTerms:*,query:*)
do
  awk '{ print >> $6 }' $f
  rm $f
done

# Move the files to their proper place
out="/home/gsherma2/doc-exp/out/$1/${2}.qd/out/"
scored="$out/scored"
mkdir -p $scored
echo "Moving files..."
mv origW:* $out

# Score the output files
echo "Scoring results..."
cd $out
parallel -j 11 --bar "trec_eval9 -q -m all_trec /home/gsherma2/doc-exp/res/qrels/qrels.$1 {} > scored/{}" ::: $(ls | grep origW)

echo "Done: $(date)"
