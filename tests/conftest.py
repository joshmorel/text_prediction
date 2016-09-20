import os
import io
import shutil
from contextlib import redirect_stdout
import pytest
from partition import partition
from stupid_backoff_mr import task1_vocab, task2_ngramfreq
from subprocess import call

@pytest.fixture(scope='function')
def make_file_for_part(request):
    tests_folder_path = os.path.join(os.path.dirname(__file__), 'files_for_partition')
    os.mkdir(tests_folder_path)
    in_path = os.path.join(tests_folder_path, 'file')
    with open(in_path , mode='w', encoding='utf-8') as fout:
        for i in range(1000):
            fout.write("i\n")

    # writes file1, file2 to same directory
    partition.main(([in_path, '-p', '.2']))

    def teardown():
        shutil.rmtree(tests_folder_path, ignore_errors=True)

    request.addfinalizer(teardown)
    return tests_folder_path


@pytest.fixture(scope='function')
def make_preprocess_files(request):
    tests_folder_path = os.path.join(os.path.dirname(__file__), 'make_preprocess_files')
    os.mkdir(tests_folder_path)
    in_path = os.path.join(tests_folder_path, 'in')

    input_lines = [
        "The movie was so-so. But I am the best!",
        "when is the fishing game- where i can't be",
        "100dollars for that",
        "www.google.com",
        "'they`re going ",
        "Wall Street—the rampant greed (courtesy Bush '41) and holier-than-thou Democrats.",
        "I love the university more than $. Said the 7-foot Leonard."
    ]

    with open(in_path, mode='w', encoding='utf-8') as fout:
        for line in input_lines:
            fout.write(line+'\n')

    def teardown():
        shutil.rmtree(tests_folder_path, ignore_errors=True)

    request.addfinalizer(teardown)
    return tests_folder_path


@pytest.fixture(scope='function')
def make_vocab_files(request):
    vocab_folder_path = os.path.join(os.path.dirname(__file__), 'vocab_files')
    os.mkdir(vocab_folder_path)
    in_path_1 = os.path.join(vocab_folder_path, 'in1')
    in_path_2 = os.path.join(vocab_folder_path, 'in2')

    with open(in_path_1, mode='w', encoding='utf-8') as fout:
        fout.write('the movie was so-so\n')
        fout.write('but i am the best\n')

    with open(in_path_2, mode='w', encoding='utf-8') as fout:
        fout.write('they are going\n')
        fout.write('i love the university more than\n')

    def teardown():
        shutil.rmtree(vocab_folder_path, ignore_errors=True)

    request.addfinalizer(teardown)
    return vocab_folder_path


@pytest.fixture(scope='function')
def make_ngramfreq_files(request):
    ngramfreq_path = os.path.join(os.path.dirname(__file__), 'ngramfreq_files')
    os.mkdir(ngramfreq_path)
    tokens_path = os.path.join(ngramfreq_path, '_0_tokens')
    with open(tokens_path, mode='w', encoding='utf-8') as fout:
        fout.write("i am sam\n")
        fout.write("sam i am\n")
        fout.write("i like green eggs and ham\n")

    vocab_path = os.path.join(ngramfreq_path, '_1_vocab')

    with open(vocab_path, mode='w', encoding='utf-8') as fout:
        with redirect_stdout(fout):
            task1_vocab.main([tokens_path, '-td', ' ', '-vm', '2'])

    def teardown():
        shutil.rmtree(ngramfreq_path, ignore_errors=True)
    request.addfinalizer(teardown)
    return ngramfreq_path


@pytest.fixture(scope='module')
def make_buildmodel_files(request):
    buildmodel_path = os.path.join(os.path.dirname(__file__), 'buildmodel_files')
    os.mkdir(buildmodel_path)
    tokens_path = os.path.join(buildmodel_path, '_0_tokens')
    with open(tokens_path, mode='w', encoding='utf-8') as fout:
        fout.write("i am sam\n")
        fout.write("sam i am\n")
        fout.write("i like green eggs and ham\n")

    vocab_path = os.path.join(buildmodel_path, '_1_vocab')

    with open(vocab_path, mode='w', encoding='utf-8') as fout:
        with redirect_stdout(fout):
            task1_vocab.main([tokens_path, '-td', ' ', '-vm', '2'])

    with io.StringIO() as buf, redirect_stdout(buf):
        task2_ngramfreq.main([tokens_path, vocab_path, '-n', '3', '-td', ' '])
        ngramfreq = buf.getvalue().rstrip().split('\n')

    ngramfreq.sort()
    ngramfreq_path = os.path.join(buildmodel_path, '_2_ngram')

    with open(ngramfreq_path, mode='w', encoding='utf-8') as fout:
        for ngram in ngramfreq:
            fout.write(ngram+'\n')

    def teardown():
        shutil.rmtree(buildmodel_path, ignore_errors=True)
    request.addfinalizer(teardown)
    return buildmodel_path

