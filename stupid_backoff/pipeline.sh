#!/usr/bin/env bash
INFILE="$(readlink -f ..)/data/examples/examples.txt"
TASK0=task0_preprocess.py
TASK1=task1_vocab.py
TASK2=task2_ngramfreq.py
TASK3=task3_buildmodel.py
TASK4=task4_convertRDS.R
TOKENIZED="$(readlink -f ..)/data/examples/tokenized"
VOCAB="$(readlink -f ..)/data/examples/_1_vocab"
NGRAM="$(readlink -f ..)/data/examples/_2_ngram"
MODEL="$(readlink -f ..)/data/examples/_3_model.txt"

N=3

python3 ${TASK0} ${INFILE} > ${TOKENIZED}
python3 ${TASK1} ${INFILE} > ${VOCAB}
# to ensure sorts as expected
export LC_ALL=C
python3 ${TASK2} ${TOKENIZED} ${VOCAB} -n ${N} | sort > ${NGRAM}
python3 ${TASK3} ${NGRAM} -n ${N} > ${MODEL}
