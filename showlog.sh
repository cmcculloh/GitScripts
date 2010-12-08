log1=$(git rev-parse --short master)
log2=$(git rev-parse --short head)

echo git diff $log1..$log2

