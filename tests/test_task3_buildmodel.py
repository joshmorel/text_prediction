import os
import io
import json

from contextlib import redirect_stdout
from stupid_backoff_mr import task3_buildmodel
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
    # ngram denom   numer   backoff_penalty
    expected = [
        ["EOS", "3", "15", "1.60E-01"],
        ["i", "3", "15", "1.60E-01"],
        ["am", "2", "15", "1.60E-01"],
        ["sam", "2", "15", "1.60E-01"],
        ["UNK", "5", "15", "1.60E-01"],
        ["BOS i", "2", "3", "1.00E+00"], # actually is 3-gram (BOS)
        ["i am", "2", "3", "4.00E-01"],
        ["am sam", "1", "2", "4.00E-01"],
        ["sam EOS", "1", "2", "4.00E-01"],
        ["BOS sam", "1", "3", "1.00E+00"],
        ["sam i", "1", "2", "4.00E-01"],
        ["am EOS", "1", "2", "4.00E-01"],
        ["i UNK", "1", "3", "4.00E-01"],
        ["UNK UNK", "4", "5", "4.00E-01"],
        ["UNK EOS", "1", "5", "4.00E-01"],
        ["BOS i am", "1", "2", "1.00E+00"],
        ["i am sam", "1", "2", "1.00E+00"],
        ["am sam EOS", "1", "1", "1.00E+00"],
        ["BOS sam i", "1", "1", "1.00E+00"],
        ["sam i am", "1", "1", "1.00E+00"],
        ["i am EOS", "1", "2", "1.00E+00"],
        ["BOS i UNK", "1", "2", "1.00E+00"],
        ["i UNK UNK", "1", "1", "1.00E+00"],
        ["UNK UNK UNK", "3", "4", "1.00E+00"],
        ["UNK UNK EOS", "1", "4", "1.00E+00"],
    ]

    ngramfreq_path = os.path.join(make_buildmodel_files, '_2_ngram')

    with io.StringIO() as buf, redirect_stdout(buf):
        # min word occurrence = 2, unknown word tag = 'UNK', beginning-of-sentence tag = 'BOS', end-of-sentence tag = 'EOS
        task3_buildmodel.main([ngramfreq_path, '-n', '3', '-td', ' ', '-all_values'])
        actual_list = buf.getvalue().rstrip().split('\n')

    expected = sorted(expected, key=lambda x: x[0])
    actual = []
    for result in actual_list:
        actual.append(result.split('\t'))
    actual = sorted(actual, key=lambda x: x[0])

    assert expected == actual


def test_buildmodel_freq_lim(make_buildmodel_files):
    # ngram denom   numer   backoff_penalty
    expected = [
        ["EOS", "3", "15", "1.60E-01"],
        ["i", "3", "15", "1.60E-01"],
        ["UNK", "5", "15", "1.60E-01"],
        ["UNK UNK", "4", "5", "4.00E-01"],
        ["UNK UNK UNK", "3", "4", "1.00E+00"],
    ]

    ngramfreq_path = os.path.join(make_buildmodel_files, '_2_ngram')

    with io.StringIO() as buf, redirect_stdout(buf):
        # min word occurrence = 2, unknown word tag = 'UNK', beginning-of-sentence tag = 'BOS', end-of-sentence tag = 'EOS
        task3_buildmodel.main([ngramfreq_path, '-n', '3', '-td', ' ', '-fl', '3', '-all_values'])
        actual_list = buf.getvalue().rstrip().split('\n')

    expected = sorted(expected, key=lambda x: x[0])
    actual = []
    for result in actual_list:
        actual.append(result.split('\t'))
    actual = sorted(actual, key=lambda x: x[0])

    assert expected == actual


def test_buildmodel_score_only(make_buildmodel_files):
    # ngram denom   numer   backoff_penalty
    expected = [
        ["EOS", "3.2000E-02"],
        ["i", "3.2000E-02"],
        ["am", "2.1333E-02"],
        ["sam", "2.1333E-02"],
        ["UNK", "5.3333E-02"],
        ["BOS i", "6.6667E-01"], # actually is 3-gram (BOS)
        ["i am", "2.6667E-01"],
        ["am sam", "2.0000E-01"],
        ["sam EOS", "2.0000E-01"],
        ["BOS sam", "3.3333E-01"],
        ["sam i", "2.0000E-01"],
        ["am EOS", "2.0000E-01"],
        ["i UNK", "1.3333E-01"],
        ["UNK UNK", "3.2000E-01"],
        ["UNK EOS", "8.0000E-02"],
        ["BOS i am", "5.0000E-01"],
        ["i am sam", "5.0000E-01"],
        ["am sam EOS", "1.0000E+00"],
        ["BOS sam i", "1.0000E+00"],
        ["sam i am", "1.0000E+00"],
        ["i am EOS", "5.0000E-01"],
        ["BOS i UNK", "5.0000E-01"],
        ["i UNK UNK", "1.0000E+00"],
        ["UNK UNK UNK", "7.5000E-01"],
        ["UNK UNK EOS", "2.5000E-01"],
    ]

    ngramfreq_path = os.path.join(make_buildmodel_files, '_2_ngram')

    with io.StringIO() as buf, redirect_stdout(buf):
        # min word occurrence = 2, unknown word tag = 'UNK', beginning-of-sentence tag = 'BOS', end-of-sentence tag = 'EOS
        task3_buildmodel.main([ngramfreq_path, '-n', '3', '-td', ' '])
        actual_list = buf.getvalue().rstrip().split('\n')

    expected = sorted(expected, key=lambda x: x[0])
    actual = []
    for result in actual_list:
        actual.append(result.split('\t'))
    actual = sorted(actual, key=lambda x: x[0])

    assert expected == actual

