#!/usr/bin/python3
import yaml
import sys
import csv

# create root yaml
matches = []


# open file
filename = sys.argv[1]
with open(filename, newline='') as csvfile:
    csv_reader = csv.reader(csvfile, delimiter=',', quotechar='"')
    for row in csv_reader:
        matches.append({
            'trigger': row[0],
            'replace': row[1]
        })


# dump results into a file

espanso_root = {
    'parent': 'default',
    'matches': matches
}


new_filename = filename[:-4]+".yml"
dump = yaml.dump(espanso_root, encoding='utf-8', allow_unicode=True)

print(dump)

with open(new_filename,'wb') as new_file:
    new_file.write(dump)

print(F"Created {new_filename}")
