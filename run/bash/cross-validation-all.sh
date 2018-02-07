#!/bin/bash
# $1 = metric
for collection in ap robust wt10g
do
  for expansionSource in self wiki
  do
    baseDir="$HOME/doc-exp/out/$collection/$expansionSource"
    outDir="$baseDir/out"
    scoredDir="$outDir/scored"
    rmOutDir="$baseDir/rm3/out"
    rmScoredDir="$rmOutDir/scored"

    numQueries=$(cut -f 1 -d ' ' "$outDir/$(ls $outDir | head -n 1)" | sort -u | wc -l)

    echo "$collection/$expansionSource"
    $HOME/cross-validation/run.py -d $scoredDir -k $numQueries -m $1 -r 1 -s | tail -n 1
    echo "$collection/$expansionSource/rm3"
    $HOME/cross-validation/run.py -d $rmScoredDir -k $numQueries -m $1 -r 1 -s | tail -n 1
  done
done
