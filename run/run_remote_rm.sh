#!/bin/bash

# Some initial stuff
time1="$(date)"
echo "-----Running $1/$2 for $3-----"
TMPDIR="/home/gsherma2/tmp"
mkdir -p $TMPDIR
config=${1}.${2}.properties

# The main event
echo "Running in parallel..."
#time parallel --bar --slf /home/gsherma2/doc-exp/res/nodes --sshdelay 0.5 --tmpdir $TMPDIR --workdir /hdfsd02/scratch/out --return expTerms:{1},query:{2} --cleanup "/home/gsherma2/doc-exp/run/java/runRMExpansion /home/gsherma2/doc-exp/config/$config {1} {2} > expTerms:{1},query:{2}" ::: 5 10 20 50 ::: $(python3 /home/gsherma2/doc-exp/run/python/get_queries_json.py /home/gsherma2/doc-exp/config/$config)
#parallel --bar --slf /home/gsherma2/doc-exp/res/nodes --sshdelay 0.5 --tmpdir $TMPDIR --workdir /hdfsd02/scratch/out --return query:{1} --cleanup "/home/gsherma2/doc-exp/run/java/runRMExpansion /home/gsherma2/doc-exp/config/$config {1} $3 > query:{1}" ::: $(python3 /home/gsherma2/doc-exp/run/python/get_queries_json.py /home/gsherma2/doc-exp/config/$config)
parallel --bar --slf /home/gsherma2/doc-exp/res/nodes --sshdelay 0.5 --tmpdir $TMPDIR "/home/gsherma2/doc-exp/run/java/runRMExpansion /home/gsherma2/doc-exp/config/$config {1} $3 > /home/gsherma2/doc-exp/query:{1}" ::: $(python3 /home/gsherma2/doc-exp/run/python/get_queries_json.py /home/gsherma2/doc-exp/config/$config)

# Split the files up into unique parameter settings
echo "Splitting files..."
awk '{ print >> $6 }' query:* 
rm query:* 
parallel --bar -j 11 "cat *,fbOrigWeight:{1},fbDocs:{2},fbTerms:{3} > fbOrigWeight:{1},fbDocs:{2},fbTerms:{3}" ::: $(seq 0 0.1 1) ::: $(seq 10 10 50) ::: $(seq 10 10 50)
rm expW*

# Move the files to their proper place
echo "Moving files..."
out="/home/gsherma2/doc-exp/out/$1/$2/rm3/$3/out"
mkdir -p $out
mv fbOrigW* $out

# Score the output files
echo "Scoring runs..."
cd $out
#parallel -j 11 --bar "trec_eval9 -q -m all_trec /home/gsherma2/doc-exp/res/qrels/qrels.$1 {} > $scored/{}" ::: $(ls | grep fbOrig)
/home/gsherma2/doc-exp/run/bash/score.sh $1

# Cross validate
echo "Cross validating..."
python ~/cross-validation/run.py -d scored/ -r 1 -k 10 -m $3 --raw-dir . > ../cv.k:10,r:1,m:$3

# Compressing the output files
echo "Compressing raw results..."
tar -czf results.tar.gz *fbOrigWeight*
rm *fbOrigWeight*

echo "Began: $time1"
echo "Completed: $(date)"
