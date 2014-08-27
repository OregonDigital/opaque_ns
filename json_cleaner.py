import json
import sys

filename = sys.argv[1]
json_object = json.loads(open(filename).read())
print json.dumps(json_object, indent=2, sort_keys=True)
