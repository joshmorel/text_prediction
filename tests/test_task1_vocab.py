import os
import io
import logging
from contextlib import redirect_stdout
from stupid_backoff_mr import task1_vocab


# #file 2 1 \
#     'the movie was so-so',
#     'but i am the best',
# file 2
#     'they are going',
#     'i love the university more than',
# ]


def test_make_vocab_from_dir(make_vocab_files):

    expected = {
        'the',
        'movie',
        'was',
        'so-so',
        'but',
        'i',
        'am',
        'best',
        'they',
        'going',
        'are',
        'love',
        'university',
        'more',
        'than'
    }

    with io.StringIO() as buf, redirect_stdout(buf):
        task1_vocab.main([make_vocab_files, '-td', ' '])
        actual = {word for word in buf.getvalue().rstrip().split('\n')}

    assert expected == actual


def test_make_vocab_min2(make_vocab_files):

    expected = {
        'the', #: 3,
        'i' #: 2,
    }

    with io.StringIO() as buf, redirect_stdout(buf):
        task1_vocab.main([make_vocab_files, '-td', ' ', '-vm', '2'])
        actual = {word for word in buf.getvalue().rstrip().split('\n')}

    assert expected == actual


def test_make_vocab_from_file(make_vocab_files):

    expected = {
        'the',
        'movie',
        'was',
        'so-so',
        'but',
        'i',
        'am',
        'best'
    }
    in_path = os.path.join(make_vocab_files, 'in1')

    with io.StringIO() as buf, redirect_stdout(buf):
        task1_vocab.main([in_path, '-td', ' '])
        actual = {word for word in buf.getvalue().rstrip().split('\n')}


    assert expected == actual
