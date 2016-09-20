# example:
# 50% to file1 50% to file2
# python3 /home/josh/repos_mine/text_prediction/partition/partition.py examples.txt


import sys
import os
import argparse
import random
import logging


def parse_args(args):
    parser = argparse.ArgumentParser(description='Partition text by lines')
    parser.add_argument('file_path', type=str,
                        help='The path to the file to partition')
    parser.add_argument('-r', dest='random_state', type=int, default=1,
                        help="Pseudo-random number generator state used for random partitioning")
    parser.add_argument('-p', dest='pct_first', type=float, default=0.5,
                        help="Percentage of lines to write to first file")

    return parser.parse_args(args)


def main(args):

    parser = parse_args(args)

    assert os.path.isfile(parser.file_path), 'The file path does not exist or is a directory'

    file_base_name = os.path.basename(parser.file_path)
    file_dir_path = os.path.dirname(os.path.abspath(parser.file_path))
    partition_names = ['1', '2']
    out_files = []
    for part in partition_names:
        out_files.append(open(os.path.join(file_dir_path, file_base_name+part), mode='a+', encoding='utf-8',newline='\n'))
    random.seed(parser.random_state)
    with open(parser.file_path, encoding='utf-8') as fin:
        for line in fin:
            if random.random() <= parser.pct_first:
                out_files[0].write(line)
            else:
                out_files[1].write(line)
    for file in out_files:
        file.close()

if __name__ == "__main__":
    main(sys.argv[1:])

logging.debug('End of program')
