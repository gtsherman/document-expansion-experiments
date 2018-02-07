#!/bin/bash

for i in $(seq 2 9)
do
  ssh gc$i "rm /hdfsd02/scratch/out/*"
done
