import hashlib
import xml.etree.cElementTree as e
from datetime import datetime

def test_metadata(specification, file, ):
    metadata = e.Element('test-metadata') 
    e.SubElement(metadata, 'sourcecodelang').text = "C"
    e.SubElement(metadata, 'producer'      ).text = "WASP"
    e.subElement(metadata, 'specification' ).text = specification
    e.SubElement(metadata, 'programfile'   ).text = file
    e.SubElement(metadata, 'programhash'   ).text = \
            hashlib.sha256(open(file, 'r')).hexdigest()
    e.SubElement(metadata, 'entryfunction' ).text = "main"
    e.SubElement(metadata, 'architecture'  ).text = "32bit"
    e.SubElement(metadata, 'creationtime'  ).text = str(datetime.now())
    return e.tostring(metadata)

def binds_to_xml(binds):
    suite = e.Element('testsuite')
    for bind in binds:
        e.SubElement(suite, 'input').text = bind['value']
    return e.tostring(suite)

from zipfile import ZipFile

def map_write_suite_zip(suite, file_list):
    with ZipFile(suite, 'w') as zip_file:
        for file_name, data in file_list:
            zip_file.writestr(file_name, data)
        zip_file.close()
