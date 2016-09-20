import sys
import os
import argparse
import heapq
import json
from collections import Counter, OrderedDict


def parse_args(args):
    parser = argparse.ArgumentParser(description='Build stupid back-off _3_model from n-gram frequencies')
    parser.add_argument('ngramfreq_path', type=str,
                        help='The path to the ngram frequency')
    parser.add_argument('-n', dest='maxorder', type=int, default=2,
                        help="The maximum order for which to generate n-grams")
    parser.add_argument('-td', dest='token_delim', type=str,
                        default=' ', help='character to delimit _0_tokens by in output')
    parser.add_argument('-b', dest='bos_token', type=str, default='BOS',
                        help="The beginning of sentence token")
    parser.add_argument('-boparam', dest='backoff_param', type=float, default=0.4,
                        help="The backoff penalty parameter, defaults to 0.4")
    parser.add_argument('-fl', dest='freq_limit', type=int, default=1,
                        help="Frequency required for n-gram to be written to _3_model")
    parser.add_argument('-all_values', nargs='?', dest='write_all_values', type=bool,
                        const=True, default=False,
                        help='Emit denom, numer & back-off penalty instead of just score')

    return parser.parse_args(args)


def heappush_capacity(heap, capacity, new_value):
    if len(heap) < capacity or capacity == -1:
        heapq.heappush(heap, new_value)
    else:
        heapq.heappushpop(heap, new_value)



def main(args):
    parser = parse_args(args)
    assert os.path.exists(parser.ngramfreq_path), 'The input file does not exist'
    assert parser.maxorder >= 2, 'Highest order must be at least 2'

    order_denom = {}

    with open(parser.ngramfreq_path, encoding='utf-8') as fin:
        # assume word count is first line
        word_count_line = fin.readline()
        # used as denominator for unigrams
        order_denom[1] = int(word_count_line.rstrip().split('\t')[1])
        for line in fin:
            ngram, count = line.split('\t')
            count = int(count)
            order = ngram.count(parser.token_delim) + 1
            # anything with beginning-of-sentence token actually represents highest order n-gram
            # just not written as not necessary
            if parser.bos_token in ngram:
                backoff_penalty = 1
            else:
                backoff_penalty = parser.backoff_param ** (parser.maxorder - order)

            # beginning-of-sentence only ngram used to calculated numerator only
            if count >= parser.freq_limit and ngram != parser.bos_token:
                if parser.write_all_values:
                    print("{}\t{}\t{}\t{:.2E}".format(ngram, count, order_denom[order],backoff_penalty))
                else:
                    score = count/order_denom[order]*backoff_penalty
                    print("{}\t{:.4E}".format(ngram, score))
            # current count used as denominator for subsequent higher-order ngram
            order_denom[order+1] = count

if __name__ == "__main__":
    main(sys.argv[1:])

