#!/bin/bash

mkdir -p scored/
parallel --bar -j 7 "trec_eval9 -q -m all_trec ~/doc-exp/res/qrels/qrels.$1 {} > scored/{}" ::: $(ls | grep -v scored)
