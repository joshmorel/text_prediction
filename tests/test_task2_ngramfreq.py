

import os
import io
from contextlib import redirect_stdout
from stupid_backoff_mr import task2_ngramfreq

# "i am sam"
# "sam i am"
# "i like green eggs and ham"


def test_ngramfreq_lower_orders(make_ngramfreq_files):

    tokens_path = os.path.join(make_ngramfreq_files, '_0_tokens')
    vocab_path = os.path.join(make_ngramfreq_files, '_1_vocab')

    expected = {
        '  N': 15,
        'BOS': 3,
        'EOS': 3,
        'i': 3,
        'am': 2,
        'sam': 2,
        'UNK': 5,
        'BOS i': 2,
        'i am': 2,
        'am sam': 1,
        'sam EOS': 1,
        'BOS sam': 1,
        'sam i': 1,
        'am EOS': 1,
        'i UNK': 1,
        'UNK UNK': 4,
        'UNK EOS': 1,
        'BOS i am': 1,
        'i am sam': 1,
        'am sam EOS': 1,
        'BOS sam i': 1,
        'sam i am': 1,
        'i am EOS': 1,
        'BOS i UNK': 1,
        'i UNK UNK': 1,
        'UNK UNK UNK': 3,
        'UNK UNK EOS': 1
    }

    with io.StringIO() as buf, redirect_stdout(buf):
        # min word occurrence = 2, unknown word tag = 'UNK', beginning-of-sentence tag = 'BOS', end-of-sentence tag = 'EOS
        task2_ngramfreq.main([tokens_path, vocab_path, '-n', '3', '-td', ' '])
        actual_list = buf.getvalue().rstrip().split('\n')

    actual = {}
    for token in actual_list:
        key, val = token.split('\t')
        actual[key] = int(val)

    assert expected == actual
