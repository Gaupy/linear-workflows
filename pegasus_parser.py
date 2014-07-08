from xml.dom import minidom
import sys
xmldoc = minidom.parse(sys.argv[1])
joblist = xmldoc.getElementsByTagName('job') 
edgelist = xmldoc.getElementsByTagName('child') 

for j in joblist :
	s = j.attributes['id'].value +' [' + j.attributes['runtime'].value + ']'
	print s
for c in edgelist :
	for p in c.childNodes :
		if p.localName=='parent' :
			s = c.attributes['ref'].value + ' ' + p.attributes['ref'].value
			print s
