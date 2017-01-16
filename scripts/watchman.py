#!/usr/bin/python

import sys, json, urllib

KATAS_URL = "https://raw.githubusercontent.com/kataslog/katas/master/"

def fetch_dojo_list():
    dojo_url = "%s%s" % (KATAS_URL, "dojo.json")
    return json.loads(urllib.urlopen(dojo_url).read())

def update():
    print "py: update katas"
    sys.exit(0)

def fetch_dojo(dojo):
    print "py: fetching dojo #{dojo}"
    sys.exit(0)

def update_dojo(dojo):
    print "py: updating dojo #{dojo}"
    sys.exit(0)

def incorrect_command():
    print "py: watchman cannot understand request"
    print "    available requests: update, fetch_dojo, update_dojo"
    sys.exit(1)

##############################################

{
    "update", update(sys.argv[1]),
    "fetch_dojo", fetch_dojo(sys.argv[1]),
    "update_dojo", update_dojo(sys.argv[1])
}.get(sys.argv[0], incorrect_command())
