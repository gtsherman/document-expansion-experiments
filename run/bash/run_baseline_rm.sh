#!/bin/bash

parallel --bar --slf /home/gsherma2/doc-exp/res/nodes --sshdelay 0.5 --workdir /hdfsd02/scratch/out --return fbOrigWeight:{3},fbDocs:{1},fbTerms:{2} --cleanup "/home/mefron/bin/IndriRunQuery /home/gsherma2/doc-exp/res/topics/topics.${1}.title /home/gsherma2/doc-exp/res/stoplist.indri.params -index=/data0/indexes2/$1 -fbDocs={1} -fbTerms={2} -fbOrigWeight={3} -trecFormat > fbOrigWeight:{3},fbDocs:{1},fbTerms:{2}" ::: $(seq 10 10 50) ::: $(seq 10 10 50) ::: $(seq 0 0.1 1)
