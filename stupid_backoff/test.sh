#!/usr/bin/env bash
INFILES="$(readlink -f ..)/data/examples/*.txt"
OUTPATH="$(readlink -f ..)/data/examples/output2/"
FIRSTFILE="${OUTPATH}tokens_40p"
SECONDFILE="${OUTPATH}tokens_60p"
PART="$(readlink -f ..)/partition/partition.py"
PREPROCESS=task0_preprocess.py
PERCENT_FIRST=0.4

mkdir -p ${OUTPATH}
for f in ${INFILES}
do
    #partition outputs to 2 files same name as input with 1 and 2 suffix
    PARTED=("${f}1" "${f}2")
    python3 ${PART} ${f} -r 1 -p ${PERCENT_FIRST}
    echo "Processing $f files..."
    for part in "${PARTED[@]}"
    do
        OUTFILE="${OUTPATH}${part##*/}"
        # mt: keep only sentences with at least 5 alpha-tokens
        # td: token-delimiter
        python3 ${PREPROCESS} ${part} -mt 5 -td ' ' > ${OUTFILE}
        rm ${part}
    done
done

cat ${OUTPATH}*1 > ${FIRSTFILE}
cat ${OUTPATH}*2 > ${SECONDFILE}
rm ${OUTPATH}*1
rm ${OUTPATH}*2
