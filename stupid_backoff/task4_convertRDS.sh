#!/usr/bin/env bash
MODEL="$(readlink -f ..)/r/shiny/model.json"
TASK4=task4_convertRDS.R
RDS="$(readlink -f ..)/r/shiny/model.RDS"

Rscript ${TASK4} -j ${MODEL} -r ${RDS}
