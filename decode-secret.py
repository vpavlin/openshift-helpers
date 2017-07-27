#!/usr/bin/python

import anymarkup
import base64
import sys

data = anymarkup.parse_file(sys.argv[1])

print("Name: %s\n===========" % data["metadata"]["name"])

for key, value in data["data"].iteritems():
  try:
    decoded = base64.b64decode(value)
  except Exception as e:
    decoded = value
    pass
  print("%s = %s" % (key, decoded))