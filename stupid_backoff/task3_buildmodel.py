import sys
import os
import argparse
import heapq
import json
from collections import namedtuple
import logging
logging.basicConfig(level=logging.INFO, format=' %(asctime)s - %(levelname)s- %(message)s')
logging.debug('START of program')


HistoryWords = namedtuple("HistoryWords",
                          "history,words")


def heappush_capacity(heap, capacity, new_value):
    if capacity is None or len(heap) < capacity:
        heapq.heappush(heap, new_value)
    else:
        heapq.heappushpop(heap, new_value)


def format_history_words_to_print(history_words, ending=","):
    # to get json formatting as desired
    formatted_words = json.dumps({word: score for (score, word) in history_words.words})
    return '"{}": {}{}'.format(history_words.history, formatted_words, ending)


def parse_args(args):
    parser = argparse.ArgumentParser(description='Build stupid back-off _3_model from n-gram frequencies')
    parser.add_argument('ngramfreq_path', type=str,
                        help='The path to the ngram frequency')
    parser.add_argument('-n', dest='maxorder', type=int, default=2,
                        help="The maximum order for which to generate n-grams")
    parser.add_argument('-td', dest='token_delim', type=str,
                        default=' ', help='character to delimit _0_tokens by in output')
    parser.add_argument('-u', dest='unk_token', type=str, default='UNK',
                        help="The unknown word token")
    parser.add_argument('-b', dest='bos_token', type=str, default='BOS',
                        help="The beginning of sentence token")
    parser.add_argument('-e', dest='eos_token', type=str, default='EOS',
                        help="The end of sentence token")
    parser.add_argument('-boparam', dest='backoff_param', type=float, default=0.4,
                        help="The backoff penalty parameter, defaults to 0.4")
    parser.add_argument('-fl', dest='freq_limit', type=int, default=1,
                        help="Frequency required for n-gram to be written to model")
    parser.add_argument('-topn', dest='topn', type=int, default=None,
                        help="Top n words to write for each history to output")
    parser.add_argument('-xeos', nargs='?', dest='exclude_eos', type=bool,
                        const=True, default=False, help="Exclude end-of-sentence tag from prediction")
    return parser.parse_args(args)


def main(args):
    parser = parse_args(args)
    assert os.path.exists(parser.ngramfreq_path), 'The input file does not exist'
    assert parser.maxorder >= 2, 'Highest order must be at least 2'

    order_denom = {}
    order_history = {}
    # tokens to exclude from prediction
    if parser.exclude_eos:
        excluded_tokens = {parser.unk_token, parser.bos_token, parser.eos_token}
    else:
        excluded_tokens = {parser.unk_token, parser.bos_token}

    # opening of model json object
    print("{")
    with open(parser.ngramfreq_path, encoding='utf-8') as fin:
        # assume word count is first line
        word_count_line = fin.readline()
        # used as denominator for unigrams
        order_denom[1] = int(word_count_line.rstrip().split('\t')[1])
        for line in fin:
            ngram, count = line.split('\t')
            ngram_tokens = ngram.split(parser.token_delim)
            order = len(ngram_tokens)
            logging.debug('Current order is {}'.format(order))
            if order == 1:
                history = parser.token_delim
                word = ngram_tokens[0]
            else:
                history = parser.token_delim.join(ngram_tokens[:-1])
                word = ngram_tokens[-1]
            count = int(count)
            # anything with beginning-of-sentence token actually represents highest order n-gram
            # just not written in ngramfreq (task2) as redundant information
            if parser.bos_token in ngram:
                backoff_penalty = 1
            else:
                backoff_penalty = parser.backoff_param ** (parser.maxorder - order)
            score = count / order_denom[order] * backoff_penalty

            if order in order_history:
                # if new history at same order, then all words for that history have been seen and can emit
                if history == order_history[order].history:
                    # do not want to predict:
                    #  unknown token
                    #  beginning-of-sentence token
                    #  any token not meeting frequency-limit parameter
                    if word not in excluded_tokens and count >= parser.freq_limit:
                        heappush_capacity(order_history[order].words, parser.topn, (score, word))
                else:
                    if order_history[order].words:
                        print(format_history_words_to_print(order_history[order]))
                    if word not in excluded_tokens and count >= parser.freq_limit:
                        order_history[order] = HistoryWords(history=history, words=[(score, word)])
                    # if criteria for predicting word not met, still want to initialize empty history
                    else:
                        order_history[order] = HistoryWords(history=history, words=[])
            else:
                # if order not yet seen at all, do not want to emit anything, but do want to initialize
                if word not in excluded_tokens and count >= parser.freq_limit:
                    order_history[order] = HistoryWords(history=history, words=[(score, word)])
                else:
                    order_history[order] = HistoryWords(history=history, words=[])
            # Store count for use as higher-order denominator
            order_denom[order+1] = count
    # print final for each at order from max to 2nd print history not yet printed
    for order in range(parser.maxorder, 1, -1):
        if order_history[order].words:
            print(format_history_words_to_print(order_history[order]))
    # finally print unigram with no last comma to conform to json
    print(format_history_words_to_print(order_history[1], ending=""))
    print("}")
if __name__ == "__main__":
    main(sys.argv[1:])

logging.debug('END of program')
