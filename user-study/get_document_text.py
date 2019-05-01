#!/usr/bin/python

import json
import re
import subprocess
import sys

from bs4 import BeautifulSoup


#indexes = {'ap': 'AP_88-89', 'wt10g': 'wt10g', 'robust': 'robust'}
indexes = {'FT': 'robust', 'FB': 'robust', 'WT': 'wt10g', 'AP': 'ap', 'FR': 'robust', 'LA': 'robust', 'GX': 'gov2'}

def collection_of(docno):
	docno_start = docno[:2]
	return indexes[docno_start]

def prepare_text(doctext, docno):
	text = doctext[doctext.find('<TEXT>')+len('<TEXT>'):doctext.find('</DOC>')]
	text = text.replace('<TEXT>', '').replace('</TEXT>', '')
	#text = re.sub(r'\n +', '<br><br>', text)
	if docno.startswith('FT'):
		text = ['<p>{}.</p>'.format(paragraph) for paragraph in re.split(r'\.\n', text)]
	elif docno.startswith('LA'):
		text = text.replace('<P>\n', '<p>').replace('</P>\n', '</p>')
	else:
		text = ['<p>{}</p>'.format(paragraph) for paragraph in re.split(r'\n +', text)]
	text = ''.join(text)
	text = text.replace('\n', '<br>')
	return text

def prepare_html(doctext):
	text = doctext[doctext.find('<BODY>')+len('<BODY>'):doctext.rfind('</BODY>')]
	return text

def clean_doctext(doctext, docno):
	collection = collection_of(docno)
	if collection == 'ap' or collection == 'robust':
		text = prepare_text(doctext, docno)
	elif collection == 'wt10g':
		text = prepare_html(doctext)
	else:  # collection is gov2 presumably
		doctext = doctext[doctext.find('</DOCHDR>')+len('</DOCHDR>'):doctext.find('</DOC>')]
		if bool(BeautifulSoup(doctext, 'html.parser').find()):  # is html
			text = prepare_html(doctext)
		else:
			text = prepare_text(doctext, docno)
	text = text.replace('\r', '')
	return text

docs = {}
for i in range(1, len(sys.argv)):
	index = sys.argv[i]
	with open(index) as f:
		for line in f:
			doc = line.split(',')[0]
			docid = int(subprocess.check_output(['dumpindex', '/data0/indexes2/{}'.format(index), 'di', 'docno', doc]))
			doctext = subprocess.check_output(['dumpindex', '/data0/indexes2/{}'.format(index), 'dt', str(docid)])
			doctext = clean_doctext(doctext, doc)
			if len(doctext.split()) <= 1000:
				docs[doc] = {}
				docs[doc]['text'] = doctext
				docs[doc]['index'] = index

print(json.dumps(docs, encoding='latin-1'))
