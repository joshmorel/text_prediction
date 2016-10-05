#!/usr/bin/env bash
#example of pipeline: putting it all together
#note: except download/unzip of corpus files

#scripts
PARTITION="$(readlink -f ..)/partition/partition.py"
TASK0=task0_preprocess.py
TASK1=task1_vocab.py
TASK2=task2_ngramfreq.py
TASK3=task3_buildmodel.py

#files
INPUT_DIRECTORY="$(readlink -f ..)/example/"
INPUTS="${INPUT_DIRECTORY}*.txt"
FINAL_DIRECTORY="$(readlink -f ..)/r/textpred/inst/extdata/"
TEMPDIR="$(readlink -f ..)/example/temp"
MERGED="${INPUT_DIRECTORY}merged.txt"
TOKENS="${INPUT_DIRECTORY}tokens.txt"
VOCAB="${FINAL_DIRECTORY}vocab.txt"
NGRAM="${INPUT_DIRECTORY}ngram.txt"
MODEL="${FINAL_DIRECTORY}model.txt"

#other variables
PERCENT_FINAL=0.7
RANDOM_SEED=1111
N=2
#the minimum occurrences required for a word to be written to the vocabular
VOCAB_MIN=2


for f in ${INPUTS}
do
    echo "Partitioning $f file..."
    PARTED=("${f}1" "${f}2")
    python3 ${PARTITION} ${f} -r ${RANDOM_SEED} -p ${PERCENT_FINAL}
done

echo "Merging files..."
#in example only using 1st partition, if evaluating would use both
cat ${INPUT_DIRECTORY}*1 > ${MERGED}

echo "Pre-processing - cleansing, tokenizing..."
#mt: keep only sentences with at least 5 alpha-tokens
#td: token-delimiter
python3 ${TASK0} ${MERGED} -mt 5 -td ' ' > ${TOKENS}

echo "Building vocabulary..."
python3 ${TASK1} ${TOKENS} -vm ${VOCAB_MIN} > ${VOCAB}

#to ensure sorts as expected
echo "Building ngram frequencies..."
export LC_ALL=C
python3 ${TASK2} ${TOKENS} ${VOCAB} -n ${N} | sort > ${NGRAM}
#-xeos: don't predict end-of-sentence token

echo "Building final model..."
python3 ${TASK3} ${NGRAM} -n ${N} -xeos > ${MODEL}

echo "Cleaning temporary files..."
rm ${INPUT_DIRECTORY}*1
rm ${INPUT_DIRECTORY}*2
rm ${TOKENS}
rm ${MERGED}
rm ${NGRAM}

echo "Done!"
