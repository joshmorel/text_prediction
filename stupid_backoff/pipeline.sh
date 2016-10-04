#!/usr/bin/env bash
INFILE="$(readlink -f ..)/example/corpus.txt"
TASK0=task0_preprocess.py
TASK1=task1_vocab.py
TASK2=task2_ngramfreq.py
TASK3=task3_buildmodel.py
TOKENIZED="$(readlink -f ..)/example/tokenized.txt"
VOCAB="$(readlink -f ..)/r/textpred/inst/extdata/vocab.txt"
NGRAM="$(readlink -f ..)/example/ngrams.txt"
MODEL="$(readlink -f ..)/r/textpred/inst/extdata/model.txt"

N=2
#the minimum occurrences required for a word to be written to the vocabular
VOCAB_MIN=2

python3 ${TASK0} ${INFILE} > ${TOKENIZED}
python3 ${TASK1} ${TOKENIZED} -vm ${VOCAB_MIN} > ${VOCAB}
# to ensure sorts as expected
export LC_ALL=C
python3 ${TASK2} ${TOKENIZED} ${VOCAB} -n ${N} | sort > ${NGRAM}
#-xeos: don't predict end-of-sentence token
python3 ${TASK3} ${NGRAM} -n ${N} -xeos > ${MODEL}

#clean up unused files
rm ${TOKENIZED}
rm ${NGRAM}
