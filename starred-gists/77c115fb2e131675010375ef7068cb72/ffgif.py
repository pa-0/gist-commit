#!/usr/bin/env python2.7

import subprocess as subp
import tempfile
import os,os.path
import sys

def ffgif(input, output, fps=None, start=None, end=None, resize=None,ffmpeg_args=[]):

	pipeyuvArgList = ['ffmpeg', '-loglevel', 'error', '-ss', start, '-i', input]
	palArgList = ['ffmpeg', '-loglevel', 'error', '-i', '-', '-c:v', 'png']
	gifArgList = ['ffmpeg', '-hide_banner', '-ss', start, '-i', input, '-i', '-', '-c:v', 'gif']

	if fps is not None:
		fps='fps='+fps
	else:
		fps=''
	if resize is not None:
		resize='scale='+resize
	else:
		resize=''
	vfilter =  ','.join((fps, resize)).strip(',')

	if start is not None:
		pipeyuvArgList.extend(['-ss', start])
		gifArgList.extend(['-ss', start])
	if end is not None:
		pipeyuvArgList.extend(['-to', end, '-copyts'])
		gifArgList.extend(['-to', end, '-copyts'])
	if vfilter:
		pipeyuvArgList.extend(['-vf', vfilter, '-sws_flags', 'lanczos'])
		gifArgList.extend(['-lavfi', '{0},paletteuse'.format(vfilter), '-sws_flags', 'lanczos'])
	else:
		gifArgList.extend(['-lavfi', 'paletteuse'])
	if len(ffmpeg_args):
		gifArgList.extend(ffmpeg_args)

	pipeyuvArgList.extend(['-f', 'yuv4mpegpipe', '-'])
	palArgList.extend(['-vf', 'palettegen', '-f', 'image2pipe', '-'])
	gifArgList.extend(['-f', 'gif', output])

	# print pipeyuvArgList
	# print palArgList
	# print gifArgList

	proc1 = subp.Popen(pipeyuvArgList, stdout=subp.PIPE)
	proc2 = subp.Popen(palArgList, stdin=proc1.stdout, stdout=subp.PIPE)
	proc3 = subp.Popen(gifArgList, stdin=proc2.stdout, stdout=sys.stdout)
	proc3.wait()

if __name__ == '__main__':

	import argparse
	import re

	def checkTimeFormat(i):
		ptn1 = re.compile(r'^([1-9][0-9]*|(((0?[0-9]|[1-9][0-9]):)?(0?[0-9]|[1-5][0-9]):)?(0?[0-9]|[1-5][0-9])(\.[0-9]{1,3})?)$')
		ptn2 = re.compile(r'^(\d+)(\.\d{1,3})?$')
		if ptn1.match(i) is None and ptn2.match(i) is None:
			parser.error('invalid time format: {}'.format(i))
		return i
	def checkScale(i):
		ptn = re.compile(r'^([1-9][0-9]*:-?[1-9][0-9]*|-[1-9][0-9]*:[1-9][0-9]*)$')
		if ptn.match(i) is None:
			parser.error('invalid scale format: {}'.format(i))
		return i

	parser = argparse.ArgumentParser(description='Converting video clip to GIF image.')
	parser.add_argument('-i', '--input', help='The input media file name', dest='input', metavar='FILE', required=True)
	parser.add_argument('-o', '--output', help='The output gif file name', dest='output', metavar='FILE', required=True)
	parser.add_argument('-s', '--start', help='Set the starting point: [[HH:]MM:]SS[.ms]', dest='start', metavar='HH:MM:SS.ms', type=checkTimeFormat)
	parser.add_argument('-e', '--end', help='Set the ending point: [[HH:]MM:]SS[.ms]', dest='end', metavar='HH:MM:SS.ms', type=checkTimeFormat)
	parser.add_argument('-f', '--fps', help='Set the FPS of GIF, using floating-point number or fraction', dest='fps', metavar='FLOAT|FRACTION')
	parser.add_argument('-r', '--resize', help='Scale size', dest='resize', metavar='W:H', type=checkScale)
	parser.add_argument('ARGS', help='Specifying additional arguments passing to ffmpeg', nargs='*')

	args = parser.parse_args()

	# print args
	# raise SystemExit

	ffgif(input=args.input, output=args.output, fps=args.fps,
			start=args.start, end=args.end, resize=args.resize, ffmpeg_args=args.ARGS)
