# strout & stderr

## print stdout & stderr to file
cmd &> file
## pipe stdout & stderr
cmd &| less


# profile

## profile cmd
time cmd
## profile pipe
time cmd | cmd2 | cmd3 | …

# parallel
## -k - save order
## -X - emulate xargs
## the {} is replaced with each line read from standard input
cat file | parallel -k echo {} append_string
ls | parallel -X mv {} destdir

