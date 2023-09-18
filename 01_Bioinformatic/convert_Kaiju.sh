#!/bin/sh
# 1 parameter is an input file with sample names (must be prefix on file)
# 2 parameter is output directory
mapfile -t FILES < $1
for file in "${FILES[@]}"
  do
  echo "$file"
  awk '{if ($1 == "C") print $0}' "$file"_kaiju.txt > tmp1
  awk 'BEGIN { FS = "," } {print $4"1"}' tmp1 > tmp2
  awk '$0 ~ /Archaea|Bacteria/' tmp2 > tmp3
  awk 'BEGIN { FS = ";" } {print $1","$2","$3","$4","$5","$6","$8}' tmp3 > tmp4
  sort -u tmp4 > ./$2/"$file"_microbe.txt
  awk '$0 ~ /Virus/' tmp2 > tmp3
  awk 'BEGIN { FS = ";" } {print $1","$2","$3","$4","$5","$6","$8}' tmp3 > tmp4
  sort -u tmp4 > ./$2/"$file"_virus.txt
  rm tmp*
done