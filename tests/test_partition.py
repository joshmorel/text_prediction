import os


def test_vocab(make_file_for_part):
    in_path_1 = os.path.join(make_file_for_part, 'file1')
    in_path_2 = os.path.join(make_file_for_part, 'file2')
    expected_pct_in_file1 = .2

    lines1 = 0
    lines2 = 0

    with open(in_path_1, encoding='utf-8') as fin:
        for _ in fin:
            lines1 += 1

    with open(in_path_2, encoding='utf-8') as fin:
        for _ in fin:
            lines2 += 1

    actual_pct_in_file1 = lines1 / (lines1 + lines2)

    assert abs(expected_pct_in_file1-actual_pct_in_file1) < 0.03
