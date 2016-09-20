#!/usr/bin/env bash
TOKENS="$(readlink -f ..)/data/Coursera-En/output/_0_tokens/coursera_tokens_40p"
VOCAB="$(readlink -f ..)/data/Coursera-En/output/_1_vocab/coursera_vocab_all"
NGRAM="$(readlink -f ..)/data/Coursera-En/output/_2_ngram/coursera_ngram_40p_5n"
TASK2=task2_ngramfreq.py

#ensure sorting as expected
export LC_ALL=C
#n: maximum order - 5-gram
python3 ${TASK2} ${TOKENS} ${VOCAB} -td ' ' -n 5 | sort > ${NGRAM}
