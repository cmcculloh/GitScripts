log1=$(git rev-parse --short master)
log2=$(git rev-parse --short $1)

echo git diff $log1..$log2

