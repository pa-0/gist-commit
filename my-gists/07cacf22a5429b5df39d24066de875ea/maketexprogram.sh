#!/bin/bash

# This script downloads the source to Donald Knuth's "TeX: The Program"
# and builds a PDF.
#
# Requires curl and a TeX distribution.

curl http://tug.org/texlive/devsrc/Build/source/texk/web2c/tex.web -o tex.web
weave tex.web
tex tex.tex
dvipdfm tex.dvi
