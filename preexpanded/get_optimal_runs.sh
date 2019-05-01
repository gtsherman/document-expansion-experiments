# Run from the ql directory. The problem is that RM3 runs were based on the wrong things. See the note in this directory for an explanation.
# $1 = optimal params file of format "query vector_size"
# $2 = output directory
# $3 = map or ndcg
while IFS=' ' read -r q v; do
  parallel -j 9 "egrep \"^$q\" ../rm3/$v/$3/{} | sed \"s/expW/v:$v,expW/g\" >> ../rm3/$2/{}" ::: $(ls ../rm3/$v/$3 | sort | grep fbOrig)
done < $1
cd ../rm3/$2
