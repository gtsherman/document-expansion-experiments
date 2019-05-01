#!/bin/bash
# Run this from either ~/doc-exp/preexpanded/ or ~/doc-exp/preexpanded/wiki/ (wherever the collections directories are) to run a proper cross validation over ALL parameters, including vector size (which is currently broken up by directory because I'm a dummy).

for i in ap robust wt10g gov2; do
  echo $i
  cd $i/ql
  mkdir -p tmp/scored
  parallel -j 5 --bar "tar -xf {}/results.tar.gz -C tmp/ --transform \"s/^/v:{},/\";" ::: 10 100 200 300 50
  for j in 10 100 200 300 50; do
    for k in $(ls $j/scored); do
      cp $j/scored/$k tmp/scored/v:$j,$k
    done
  done

  cd tmp
  parallel -j 5 --bar "sed -i \"s/expW/v:{},expW/g\" v:{},*" ::: 10 100 200 300 50
  parallel -j 2 --bar "python ~/cross-validation/run.py -d scored -r 1 -k 10 -m {} --raw-dir . > ../cv.k:10,r:1,m:{}" ::: map ndcg_cut_20
  cd ..
  rm -r tmp
  cd ../../
done
