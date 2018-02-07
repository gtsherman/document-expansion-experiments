#!/bin/bash
echo "Running $1/$2"
TMPDIR="/home/gsherma2/tmp"
mkdir -p $TMPDIR
time parallel --bar --slf ~/doc-exp/res/nodes --sshdelay 0.5 --tmpdir $TMPDIR --workdir /hdfsd02/scratch/out --return origW:{1},fbDocs:{2},fbTerms:{3} --cleanup "/home/gsherma2/doc-exp/run/java/runExpansion /home/gsherma2/doc-exp/config/${1}.${2}.properties {1} {2} {3} > origW:{1},fbDocs:{2},fbTerms:{3}" ::: $(seq 0 0.1 1) ::: $(seq 5 5 25) ::: 5 10 20 50
mkdir -p ~/doc-exp/out/$1/$2/out/scored
mv origW:*,fbDocs:*,fbTerms:* ~/doc-exp/out/$1/$2/out

for result in $(ls ~/doc-exp/out/$1/$2/out | grep origW)
do
  trec_eval9 -q -m all_trec ~/doc-exp/res/qrels/qrels.$1 ~/doc-exp/out/$1/$2/out/$result > ~/doc-exp/out/$1/$2/out/scored/$result
done
