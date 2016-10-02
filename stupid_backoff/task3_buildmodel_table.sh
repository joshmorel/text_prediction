#!/usr/bin/env bash
NGRAM="$(readlink -f ..)/data/Coursera-En/output/_2_ngram/coursera_ngram_40p_5n"
TASK3=task3_buildmodel_table.py
MODEL="$(readlink -f ..)/data/Coursera-En/output/_3_model/coursera_sb_model_40p_5n.txt"
#fl: frequency limit, ngram must occur this many times to be output
#xeos: exclude end-of-sentence tag from prediction
python3 ${TASK3} ${NGRAM} -td ' ' -n 5 -fl 2 -topn 3 -xeos > ${MODEL}
