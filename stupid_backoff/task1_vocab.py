# -*- coding: utf-8 -*-

# !/usr/bin/env python

# python3 task1_vocab.py /home/josh/repos_mine/text_prediction/data/sample/

import sys
import os
import argparse
from collections import Counter


def parse_args(args):
    parser = argparse.ArgumentParser(description='Make vocabulary from tokenized text')
    parser.add_argument('file_path', type=str,
                        help='The path to the file or directory of tokenized text to create a vocabulary from')
    parser.add_argument('-td', dest='token_delim', type=str,
                        default=' ', help='character to delimit _0_tokens by in output')
    parser.add_argument('-vm', dest='vocab_min', type=int, default=1,
                        help="If word does not occur at least this many times in _1_vocab do not write")
    return parser.parse_args(args)


def main(args):

    parser = parse_args(args)

    if os.path.isdir(parser.file_path):
        in_files = [os.path.join(parser.file_path, f) for f in os.listdir(parser.file_path)
                    if os.path.isfile(os.path.join(parser.file_path, f))]
    elif os.path.isfile(parser.file_path):
        in_files = [parser.file_path]
    else:
        raise FileNotFoundError('The file or directory does not exist')

    vocab = Counter()
    for file in in_files:
        with open(file, encoding='utf-8') as fin:
            for line in fin:
                tokens = line.rstrip().split(parser.token_delim)
                vocab.update(tokens)

    for word, count in vocab.items():
        if count >= parser.vocab_min:
            print(word)

if __name__ == "__main__":
    main(sys.argv[1:])
