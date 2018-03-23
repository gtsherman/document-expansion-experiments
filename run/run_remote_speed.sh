#!/bin/bash

# Some initial stuff
echo "Running $1/$2"
TMPDIR="/home/gsherma2/tmp"
mkdir -p $TMPDIR
config=${1}.${2}.properties

# The main event
time parallel --bar --slf /home/gsherma2/doc-exp/res/nodes --sshdelay 0.5 --tmpdir $TMPDIR --workdir /hdfsd02/scratch/out --return expTerms:{1},query:{2} --cleanup "/home/gsherma2/doc-exp/run/java/runExpansion /home/gsherma2/doc-exp/config/$config {1} {2} > expTerms:{1},query:{2}" ::: 5 10 20 50 ::: $(python3 /home/gsherma2/doc-exp/run/python/get_queries_json.py /home/gsherma2/doc-exp/config/$config)

# Split the files up into unique parameter settings
awk '{ print >> $6 }' expTerms:*,query:* 
rm expTerms:*,query:* 

# Move the files to their proper place
out="/home/gsherma2/doc-exp/out/$1/$2/out/"
scored="$out/scored"
mkdir -p $scored
mv origW:* $out

# Score the output files
for result in $(ls $out | grep origW)
do
  trec_eval9 -q -m all_trec /home/gsherma2/doc-exp/res/qrels/qrels.$1 $out/$result > $scored/$result
done
