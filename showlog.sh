log1=$(git show --format=%h master)
log2=$(git show --format=%h $1)

echo git diff $log1..$log2

