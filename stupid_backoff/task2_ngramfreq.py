import sys
import os
import argparse
from collections import deque, Counter
import logging
import sys
logging.basicConfig(level=logging.INFO, format=' %(asctime)s - %(levelname)s- %(message)s')
logging.debug('START of program')



def parse_args(args):
    parser = argparse.ArgumentParser(description='Make stupid backoff n-grams _3_model from frequency tokenized text')
    parser.add_argument('token_path', type=str,
                        help='The path to the file of _0_tokens')
    parser.add_argument('vocab_path', type=str,
                        help='The path to read in vocabulary for pruning')
    parser.add_argument('-td', dest='token_delim', type=str,
                        default=' ', help='character to delimit _0_tokens by in output')
    parser.add_argument('-n', dest='maxorder', type=int, default=2,
                        help="The maximum order for which to generate n-grams")
    parser.add_argument('-u', dest='unk_token', type=str, default='UNK',
                        help="The unknown token")
    parser.add_argument('-b', dest='bos_token', type=str, default='BOS',
                        help="The beginning of sentence token")
    parser.add_argument('-e', dest='eos_token', type=str, default='EOS',
                        help="The end of sentence token")

    return parser.parse_args(args)


def main(args):
    parser = parse_args(args)
    assert os.path.isfile(parser.token_path), 'The token path does not exist or is a directory'
    assert os.path.isfile(parser.vocab_path), 'The _1_vocab path does not exist or is a directory'
    assert parser.maxorder >= 2, 'Highest order must be at least 2'

    num_tokens = 0

    # Vocab is set _0_tokens meeting minimum threshold as determined in task 1
    vocab = {parser.bos_token, parser.eos_token}
    with open(parser.vocab_path, encoding='utf-8') as fin:
        for line in fin:
            vocab.add(line.strip())

    ngrams = Counter()
    with open(parser.token_path, encoding='utf-8') as fin:
        for line in fin:
            tokens = [parser.bos_token] + line.rstrip().split(parser.token_delim) + [parser.eos_token]
            num_tokens += len(tokens) - 1  # do not count BOS in N=num_tokens
            for i, tok in enumerate(tokens):
                if tok not in vocab:
                    tokens[i] = 'UNK'
                for j in range(1, parser.maxorder + 1):
                    ngram = ' '.join(tokens[(i + 1 - j):(i + 1)])
                    if ngram:
                        ngrams.update([ngram])

    print('  N\t{}'.format(num_tokens))
    for ngram, count in ngrams.items():
        print('{}\t{}'.format(ngram,count))

if __name__ == "__main__":
    main(sys.argv[1:])
