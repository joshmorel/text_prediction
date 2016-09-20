#!/usr/bin/env bash
#build vocab from directory, can optional build from file
TOKENSDIR="$(readlink -f ..)/data/Coursera-En/output/_0_tokens"
VOCAB="$(readlink -f ..)/data/Coursera-En/output/_1_vocab/coursera_vocab_all"
TASK1=task1_vocab.py

#vm: vocab minimum - must occur this many times to be written to vocab
python3 ${TASK1} ${TOKENSDIR} -td ' ' -vm 6 > ${VOCAB}
