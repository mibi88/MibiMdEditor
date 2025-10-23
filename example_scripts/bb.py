#!/usr/bin/python3

import bbcode
import sys

parser = bbcode.Parser()
html = parser.format(sys.stdin.read())
sys.stdout.write(html)
