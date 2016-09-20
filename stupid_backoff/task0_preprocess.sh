#!/usr/bin/env bash
INFILES="$(readlink -f ..)/data/Coursera-En/orig/*.txt"
OUTPATH="$(readlink -f ..)/data/Coursera-En/output/_0_tokens/"
FIRSTFILE="${OUTPATH}coursera_tokens_40p"
SECONDFILE="${OUTPATH}coursera_tokens_60p"
PART="$(readlink -f ..)/partition/partition.py"
PREPROCESS=task0_preprocess.py
PERCENT_FIRST=0.4

mkdir -p ${OUTPATH}
for f in ${INFILES}
do
    #partition outputs to 2 files same name as input with 1 and 2 suffix
    PARTED=("${f}1" "${f}2")
    python3 ${PART} ${f} -r 1 -p ${PERCENT_FIRST}
    echo "Processing $f file..."
    for part in "${PARTED[@]}"
    do
        OUTFILE="${OUTPATH}${part##*/}"
        #mt: keep only sentences with at least 5 alpha-tokens
        #td: token-delimiter
        python3 ${PREPROCESS} ${part} -mt 5 -td ' ' > ${OUTFILE}
        rm ${part}
    done
done

echo "Merging files..."
cat ${OUTPATH}*1 > ${FIRSTFILE}
cat ${OUTPATH}*2 > ${SECONDFILE}
rm ${OUTPATH}*1
rm ${OUTPATH}*2
