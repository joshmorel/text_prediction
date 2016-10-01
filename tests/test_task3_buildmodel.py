import os
import io
import json

from contextlib import redirect_stdout
from stupid_backoff import task3_buildmodel
#
# expected = {
#     '  N': 15,
#     'BOS': 3,
#     'EOS': 3,
#     'i': 3,
#     'am': 2,
#     'sam': 2,
#     'UNK': 5,
#     'BOS i': 2,
#     'i am': 2,
#     'am sam': 1,
#     'sam EOS': 1,
#     'BOS sam': 1,
#     'sam i': 1,
#     'am EOS': 1,
#     'i UNK': 1,
#     'UNK UNK': 4,
#     'UNK EOS': 1,
#     'BOS i am': 1,
#     'i am sam': 1,
#     'am sam EOS': 1,
#     'BOS sam i': 1,
#     'sam i am': 1,
#     'i am EOS': 1,
#     'BOS i UNK': 1,
#     'i UNK UNK': 1,
#     'UNK UNK UNK': 3,
#     'UNK UNK EOS': 1
# }


def test_buildmodel(make_buildmodel_files):
    # top 3 only per history
    expected = {
        " ": { # n-gram delim as history for unigram
            "EOS": 0.03200000000000001,  # do not write unknown token
            "i": 0.03200000000000001,
            # if count equal, alphabetically lower is prioritized
            "sam": 0.021333333333333336
        },
        "BOS": {
            "i": 0.6666666666666666,
            "sam": 0.3333333333333333
        },
        "i": {
            "am": 0.26666666666666666
        },
        "am": {
            "sam": 0.2,
            "EOS": 0.2
        },
        "sam": {
            "i": 0.2,
            "EOS": 0.2
        },
        "UNK": {
            "EOS": 0.08000000000000002
        },
        "BOS i": {
            "am": 0.5
        },
        "i am": {
            "sam": 0.5,
            "EOS": 0.5
        },
        "am sam": {
            "EOS": 1.0
        },
        "BOS sam": {
            "i": 1.0
        },
        "sam i": {
            "am": 1.0
            },
        "UNK UNK": {
            "EOS": 2.5000E-01,
        }
    }

    ngramfreq_path = os.path.join(make_buildmodel_files, '_2_ngram')

    with io.StringIO() as buf, redirect_stdout(buf):
        task3_buildmodel.main([ngramfreq_path, '-n', '3', '-td', ' ', '-topn', '3'])
        actual = json.loads(buf.getvalue().rstrip())

    assert expected == actual


def test_buildmodel_freqlimit(make_buildmodel_files):
    # top 3 only per history
    # exclude end-of-sentence tag from prediction
    expected = {
        " ": { # n-gram delim as history for unigram
            "i": 0.03200000000000001,
            "sam": 0.021333333333333336,
            "am": 0.021333333333333336

        },
        "BOS": {
            "i": 0.6666666666666666
        },
        "i": {
            "am": 0.26666666666666666
        }
    }

    ngramfreq_path = os.path.join(make_buildmodel_files, '_2_ngram')

    with io.StringIO() as buf, redirect_stdout(buf):
        task3_buildmodel.main([ngramfreq_path, '-n', '3', '-td', ' ', '-fl', '2', '-topn', '3', '-xeos'])
        actual = json.loads(buf.getvalue().rstrip())

    assert expected == actual
