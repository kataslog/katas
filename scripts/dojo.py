#!/usr/bin/python

import sys, json

def list_dojo():
    print "dojo: list of available dojo"
    sys.exit(0)

def list_katas():
    print "dojo: liast of katas"
    sys.exit(0)

def open_dojo():
    print "dojo: it is the dojo you search"
    sys.exit(0)

def open_kata():
    print "dojo: use it wisely"
    sys.exit(0)

def incorrect_command():
    print "dojo: seems like it's not your dojo"
    sys.exit(1)

##########################

{
    "list_dojo" : list_dojo(),
    "list_katas" : list_katas(),
    "open" : open_kata()
}.get(sys.argv[1], incorrect_command())
