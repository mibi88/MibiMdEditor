#!/usr/bin/python3

from markdown import *
import sys

if len(sys.argv) > 1:
    html = markdown(sys.argv[1],
                    extensions=["extra",
                                "toc",
                                "smarty",
                                "legacy_attrs",
                                "meta"])
    sys.stdout.write (html)
else:
    sys.stdout.write ("More arguments needed!\n")
