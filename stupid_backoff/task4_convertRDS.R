#!/usr/bin/env Rscript
suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(textpred))

option_list = list(
  make_option(c("-j", "--json"), action="store", default=NA, type='character',
              help="path to json model"),
  make_option(c("-r", "--rds"), action="store", default=NA, type='character',
              help="path to RDS output"),
  make_option(c("-d", "--ngram_delim"), action="store", default=" ", type='character',
              help="ngram delimiter")
)

opt = parse_args(OptionParser(option_list=option_list))

#maxorder actually doesn't matter for creating and saving model in RDS format
textpred_model <- TextPredictor(model = opt$j, maxorder = 2, ngram_delim = opt$ngram_delim)
saveRDS(textpred_model$model, opt$r)
