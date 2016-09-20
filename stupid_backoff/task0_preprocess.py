import sys
import os
import argparse
from collections import OrderedDict
import re
from nltk.data import load


def parse_args(args):
    parser = argparse.ArgumentParser(
        description='Clease a text of unwanted punctuation and weird encodings, optionally profanity and tag to reduce vocabulary')
    parser.add_argument('file_path', type=str,
                        help='The path to the file to tokenize')
    parser.add_argument('-p', nargs='?', dest='no_profanity', type=bool,
                        const=True, default=False,
                        help='Get rid of lines with profanity from the final output')
    parser.add_argument('-mt', dest='min_tokens', type=int, default=1,
                        help="Minimum alphabetic _0_tokens required to keep sentence. e.g. if 3 'hello there !!!' would be discarded")
    parser.add_argument('-td', dest='token_delim', type=str,
                        default=' ', help='character to delimit _0_tokens by in output')
    return parser.parse_args(args)


EXTRA_ABBREVS = ['i.e','e.g','a.m','p.m']
sentence_tokenizer = load('tokenizers/punkt/english.pickle')
sentence_tokenizer._params.abbrev_types.update(EXTRA_ABBREVS)


CHAR_SUBSTITUTES = {
    '\x82': ',',  # High code comma
    '\x84': ',,',  # High code double comma
    '\x85': '...',  # Tripple dot
    '…': '...',
    '\x88': '^',  # High carat
    '\x91': "'",  # Forward single quote
    '\x92': "'",  # Reverse single quote
    '\x93': '"',  # Forward double quote
    '\x94': '"',  # Reverse double quote
    '“': '"',  # Replace all other quote like characters with double-quote
    '”': '"',
    '‘': "'",
    '’': "'",
    'é': "e",  # Common foreign character
    'ü': "u",  # Common foreign character
    '`': "'",  # back-tick seem to be used as apostrophe
    '\x95': ' ',
    '\x96': '-',  # High hyphen
    '\x97': ' -- ',  # Double hyphen with spaces for all dash-like _0_tokens
    '—': ' -- ',  # em-dash
    '–': ' -- ',  # en-dash
    '\x99': ' ',
    '\xa0': ' ',
    '\xa6': '|',  # Split vertical bar
    '\xab': '<<',  # Double less than
    '\xbb': '>>',  # Double greater than
    '\xbc': '1/4',  # one quarter
    '\xbd': '1/2',  # one half
    '\xbe': '3/4',  # three quarters
    '\xbf': '"',  # c-single quote
    '\xa8': '',  # modifier - under curve
    '\xb1': ''  # modifier - under line
}

CONTRACTION_EXPANSION = OrderedDict([
    ("won't","will not"),
    ("can't", "cannot"),
    ("n't", " not"),
    ("'ll", " will"),
    ("'re", " are"),
    ("'d", " would"),
    ("'ve", " have"),
    ("'m", " am"),
    ("'s", "")  # can be is or posessive, remove to reduce vocab
])

PROFANITY = re.compile("(?i)fuck|cocksuck|shit|piss|cunt|tits|bitch|faggot|nigger|asshole|nigga(?i)")


def substitute_strings(text, string_map):
    for key in string_map:
        text = text.replace(key, string_map[key])
    return text


def cleanse_token(token):
    # remove all non-alpha except hyphens inside alphas
    token = re.sub('[^a-z\-]', '', token)
    # remove any hyphens not between alphas
    token = re.sub('^-+|-+$', '', token)
    return token


def tokenize_sentence(sentence, min_tokens):
    # split on whitespace then cleanse token to meet specifications
    tokens = sentence.split()
    tokens = [cleanse_token(token) for token in tokens]
    # remove blank _0_tokens post-cleansing
    tokens = [token for token in tokens if token]
    if len(tokens) >= min_tokens:
        return tokens


def cleanse_profanity(line):
    for token in line:
        if re.search(PROFANITY, token):
            return None
    return line


def main(args):
    parser = parse_args(args)

    assert os.path.isfile(parser.file_path), 'The file path does not exist or is a directory'

    assert parser.token_delim == ' ' or not (parser.token_delim.isalnum() or parser.token_delim.isspace()),\
        'token must be non-alphanumeric, if whitespace then only single space'

    with open(parser.file_path, encoding='utf-8') as fin:
        for line in fin:
            line = line.strip()
            if line:
                line = substitute_strings(line, CHAR_SUBSTITUTES)
                sentences = sentence_tokenizer.tokenize(line)
                for sent in sentences:
                    sent = sent.lower()
                    sent = substitute_strings(sent, CONTRACTION_EXPANSION)
                    tok_sent = tokenize_sentence(sent, parser.min_tokens)
                    if tok_sent and parser.no_profanity:
                        tok_sent = cleanse_profanity(tok_sent)
                    if tok_sent:
                        print(parser.token_delim.join(tok_sent))

if __name__ == "__main__":
    main(sys.argv[1:])
