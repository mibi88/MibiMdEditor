#!/usr/bin/python3

import bbcode
import sys

if len(sys.argv) > 1:
    parser = bbcode.Parser ()
    html = parser.format (sys.argv[1])
    sys.stdout.write (html)
else:
    sys.stderr.write ("More arguments needed!\n")
