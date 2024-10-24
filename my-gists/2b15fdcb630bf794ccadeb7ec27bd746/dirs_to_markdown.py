#!/usr/bin/env python3

# Walks a directory tree, creating a Markdown representation of it.
#
# First command line argumaent is root directory.  Defaults to current directory.

import os
import sys

if len(sys.argv) > 1:
    path = sys.argv[1]
else:
    path = "."

indent = "\t"
item_prefix = "* "

def scan_directory(path, prefix=indent):
    """Print contents of a directory with specified prefix before each line.

    Files are printed first, followed by subdirectories and their contents with
    additional indentation.
    
    Ignores any files or directories with names starting with ".".
    """
    with os.scandir(path) as it:
        entries = [entry for entry in list(it) if not entry.name.startswith(".")]

        files = [entry for entry in entries if entry.is_file()]
        files.sort(key=lambda entry: entry.name)
        for file in files:
            print("{}{}`{}`".format(prefix, item_prefix, file.name))

        dirs = [entry for entry in entries if entry.is_dir()]
        dirs.sort(key=lambda entry: entry.name)
        for dir in dirs:
            print("{}{}`{}/`".format(prefix, item_prefix, dir.name))
            scan_directory(dir.path, prefix + indent)

print("{}`{}/`".format(item_prefix, path))
scan_directory(path)
