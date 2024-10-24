#!/usr/bin/env bash

# Taken from https://ilovesymposia.com/2013/04/11/automatically-resume-interrupted-downloads-in-osx-with-curl/ and https://ec.haxx.se/usingcurl/usingcurl-timeouts
export ec=18; while [ $ec -ne 0 ]; do /usr/bin/curl --speed-time 15 --speed-limit 1000 -O -C - "http://somedomain.com/path/to/some_huge_file.txt"; export ec=$?; done