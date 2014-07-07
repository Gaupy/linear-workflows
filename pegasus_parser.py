from xml.dom import minidom
import sys
xmldoc = minidom.parse(sys.argv[1])
joblist = xmldoc.getElementsByTagName('job') 
edgelist = xmldoc.getElementsByTagName('child') 

def getChildrenByTitle(node):
    for child in node.childNodes:
        if child.localName=='parent':
            yield child

for j in joblist :
	s = j.attributes['id'].value +' [' + j.attributes['runtime'].value + ']'
	print s
for c in edgelist :
	parentlist=getChildrenByTitle(c);
	for p in parentlist :
		s = c.attributes['ref'].value + ' ' + p.attributes['ref'].value
    	print s
