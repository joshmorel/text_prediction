#!/usr/bin/env bash
SCRIPT=/home/josh/repos_mine/text_prediction/partition/partition.py
INFILE=/home/josh/repos_mine/text_prediction/data/Coursera-En/orig/en_US.blogs.txt
PERCENT_FIRST=0.2

python3 ${SCRIPT} ${INFILE} -r 100 -p ${PERCENT_FIRST}
