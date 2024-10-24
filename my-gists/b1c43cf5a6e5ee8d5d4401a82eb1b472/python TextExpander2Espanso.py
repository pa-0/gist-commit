import argparse
import glob
import plistlib
import re

from os import path, mkdir

import yaml

'''
Convert TextExpander snippets to espanso snippets
Does not handle all TextExpander features. 
Tested on TextExpander 5, no idea if this works on newer TextExpander versions
Requires pyyaml library: https://pypi.org/project/PyYAML/

Usage: `python TextExpander2Espanso.py -b [text expander settings/backup file]`
'''

# https://github.com/yaml/pyyaml/issues/127#issuecomment-525800484
class MyDumper(yaml.SafeDumper):
    # HACK: insert blank lines between top-level objects
    # inspired by https://stackoverflow.com/a/44284819/3786245
    # modified for neatly formatting espanso
    def write_line_break(self, data=None):
        super().write_line_break(data)

        if len(self.indents) == 2:
            super().write_line_break()


def grab_all_plist(directory):
    files = glob.glob(path.join(directory, 'group_*.xml'))
    return files


def convert_plist_to_yml(file):
	matches = []
	with open(file, 'rb') as fp:
		pl = plistlib.load(fp, fmt=plistlib.FMT_XML)
		group_name = pl['name']
		for snippet in pl['snippetPlists']:
			trigger = snippet['abbreviation']
			replace_snippet = snippet['plainText']
			# handle cursor placement
			if '%|' in replace_snippet:
				replace_snippet = replace_snippet.replace('%|', '$|$')

			# handle date/time-stamps
			if re.search('%[HiMSpzZYyVvnAadej]', replace_snippet) is not None:
				matches.append({
					'trigger': trigger,
					'replace': '{{myvar}}',
					"vars": [{
		                "name": "myvar",
		                "type": "date",
		                "params": {
		                    "format": replace_snippet
		                }
			        }]
				})
			elif re.search('%1[HIMSm]', replace_snippet) is not None:
				datestring_fmt_map = {
					'%1H': '%k',
					'%1I': '%l',
					'%1M': '%_M',
					'%1S': '%_S',
					'%1m': '%_m'
				}
				for (te_fmt, es_fmt) in datestring_fmt_map:
					replace_snippet.replace(te_fmt, es_fmt)
				matches.append({
					'trigger': trigger,
					'replace': '{{myvar}}',
					"vars": [{
		                "name": "myvar",
		                "type": "date",
		                "params": {
		                    "format": replace_snippet
		                }
			        }]
				})
			# add plain snippet to matches
			else:
				matches.append({
					'trigger': trigger,
					'replace': replace_snippet
				})
	return (group_name, {'matches': matches})


def write_yaml(snippets, group_name, dir_name):
	yaml_name = f'{dir_name}/group_{group_name}.yml'
	with open(yaml_name, 'w') as output:
		output.write(yaml.dump(snippets, Dumper=MyDumper, sort_keys=False))
	return yaml_name


def make_results_folder(name):
    try:
        mkdir(name)
    except FileExistsError:
        pass
    return name


if __name__ == "__main__":
	parser = argparse.ArgumentParser(
		description='Convert a TextExpander backup to Espanso'
	)
	parser.add_argument('--backup', '-b', help='path to TE backup')
	args = vars(parser.parse_args())

	fname = args['backup']

	# make output folder
	output_dir_name = path.basename(fname).split('.')[0]
	make_results_folder(output_dir_name)

	# grab all the TE groups
	group_plists = grab_all_plist(args['backup'])

	# write a yaml file for each group
	for plist in group_plists:
		group_name, matches = convert_plist_to_yml(plist)
		yaml_name = write_yaml(matches, group_name, output_dir_name)
		print(f'written {yaml_name}')

	print('done')
	print('Copy & paste the above files to:')
	print('~/Library/Application Support/espanso/match')
	print('\n⚠️ This script does not handle all TextExpander syntax,\n\
  review output before importing to espanso\n')
