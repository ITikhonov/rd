#!/usr/bin/python

import urllib.request
from json import loads
import os
import hashlib
import sys

HOME=os.environ['HOME']+'/'


rows, cols = [int(x) for x in os.popen('stty size', 'r').read().split()]

def dot():
	print('.',end='')
	sys.stdout.flush()

def reddit(r,score=-10):
	dot()
	req=urllib.request.Request('http://www.reddit.com/r/'+r+'/.json')
	opener=urllib.request.build_opener()
	req.add_header('User-Agent','something/0.1 by kefeer@brokestream.com')

	data=opener.open(req).read()

	data=data.decode('utf8')
	data=loads(data)

	seen=False

	for x in data['data']['children']:
		rid=x['data']['id']
		flag=HOME+'bin/rd-seen/'+r+'-'+rid
		if os.access(flag,os.F_OK): continue
		if x['data']['score']<score: continue


		if not seen: print('\r==',r)
		print('-',x['data']['title'][:cols-5]+'...')
		open(flag,'a').close()
		seen=True

	return seen


def blogger(r):
	dot()
	req=urllib.request.Request('http://'+r+'.blogspot.com/feeds/posts/default?alt=json')
	opener=urllib.request.build_opener()
	req.add_header('User-Agent','something/0.1 by kefeer@brokestream.com')

	data=opener.open(req).read()

	data=data.decode('utf8')
	data=loads(data)

	seen=False

	for x in data['feed']['entry']:
		rid=hashlib.md5(x['id']['$t'].encode('utf8')).hexdigest()
		flag=HOME+'bin/rd-seen/'+r+'-'+rid
		if os.access(flag,os.F_OK): continue

		if not seen: print('\r==',r)
		title=x['title']['$t']
		print('-',title[:cols-5]+'...')
		open(flag,'a').close()
		seen=True

	return seen


def is_seen(r,id):
	rid=hashlib.md5(id.encode('utf8')).hexdigest()
	flag=HOME+'bin/rd-seen/'+r+'-'+rid
	return os.access(flag,os.F_OK)

def seen(r,id):
	rid=hashlib.md5(id.encode('utf8')).hexdigest()
	flag=HOME+'bin/rd-seen/'+r+'-'+rid
	open(flag,'a').close()
	
def output(title):
	print('-',title[:cols-5]+'...')

def h2(r,u):
	dot()
	req=urllib.request.Request(u)
	opener=urllib.request.build_opener()
	req.add_header('User-Agent','something/0.1 by kefeer@brokestream.com')

	data=opener.open(req).read()
	data=data.decode('utf8')

	gotsome=False

	for x in data.split('<h2>'):
		x=x.split('</a>',1)[0]
		if 'rel="bookmark"' not in x: continue

		x=x.rsplit('">')[1]
		if is_seen(r,x): continue

		if not gotsome: print('\r==',r)
		output(x)
		seen(r,x)
		gotsome=True

	return gotsome

def main():
	if blogger('timothylottes'): return
	if h2('yosefk','http://yosefk.com/blog/'): return
	if reddit('Forth'): return
	if reddit('4Xgaming'): return

	reddit('worldnews',50)
	reddit('programming',10)
	reddit('art',50)
	print()

main()

