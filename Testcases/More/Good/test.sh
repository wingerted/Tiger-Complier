#!/bin/sh

for file in *.tig; do
    ./a.out $file > 1.txt;
done
