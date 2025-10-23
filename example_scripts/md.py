#!/usr/bin/python3

import markdown as md
import sys

text = sys.stdin.read()

html = md.markdown(text, extensions=["extra",
                                           "toc",
                                           "smarty",
                                           "legacy_attrs",
                                           "meta"])
sys.stdout.write(html)

