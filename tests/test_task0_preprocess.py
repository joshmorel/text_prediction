import os
import io
from contextlib import redirect_stdout
from stupid_backoff_mr import task0_preprocess


# input_lines = [
#      "The movie was so-so. But I am the best!",
#      "when is the fishing game- where i can't be",
#      "100dollars for that",
#      "www.google.com",
#      "'they`re going ",
#      "Wall Street—the rampant greed (courtesy Bush '41) and holier-than-thou Democrats.",
#      "I love the university more than $. Said the 7-foot Leonard."
# ]


def test_preprocess(make_preprocess_files):

    expected = [
        'the movie was so-so',
        'but i am the best',  # "The movie was so-so. But I am the best!"
        'when is the fishing game where i cannot be',  # "when is the fishing game- where i can't be"
        'dollars for that',  # "100dollars for that",
        'wwwgooglecom',  # "www.google.com",
        'they are going',  # "'they`re going ",
        'wall street the rampant greed courtesy bush and holier-than-thou democrats',
        # "Wall Street—the rampant greed (courtesy Bush '41) and holier-than-thou Democrats.",
        'i love the university more than',
        'said the foot leonard'  # "I love the university more than $. Said the 7-foot Leonard."
    ]

    in_path = os.path.join(make_preprocess_files, 'in')

    with io.StringIO() as buf, redirect_stdout(buf):
        task0_preprocess.main([in_path, '-td', ' '])
        actual = buf.getvalue().rstrip().split('\n')

    assert expected == actual


def test_preprocess_min_tokens(make_preprocess_files):

    expected = [
        'the movie was so-so',
        'but i am the best',  # "The movie was so-so. But I am the best!"
        'when is the fishing game where i cannot be',  # "when is the fishing game- where i can't be"
        # 'dollars for that',  # "100dollars for that",
        # 'wwwgooglecom',  # "www.google.com",
        # 'they are going',  # "'they`re going ",
        'wall street the rampant greed courtesy bush and holier-than-thou democrats',
        # "Wall Street—the rampant greed (courtesy Bush '41) and holier-than-thou Democrats.",
        'i love the university more than',
        'said the foot leonard'  # "I love the university more than $. Said the 7-foot Leonard."
    ]

    in_path = os.path.join(make_preprocess_files, 'in')

    with io.StringIO() as buf, redirect_stdout(buf):
        task0_preprocess.main([in_path, '-mt', '4', '-td', ' '])
        actual = buf.getvalue().rstrip().split('\n')

    assert expected == actual
