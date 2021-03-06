#!/usr/bin/python

import sys

def hint(dojo, kata, flags):
    print "sensei: hint #{dojo}:#{kata} #{flags}"
    sys.exit(0)

def test(dojo, kata):
    print "sensei: test #{dojo}:#{kata}"
    sys.exit(0)

def test_all(dojo):
    print "sensei: test all katas for #{dojo}"
    sys.exit(0)

def incorrect_command():
    print "sensei is upset"
    sys.exit(1)

#########################

{
    "hint", hint(sys.argv[2], sys.argv[3], sys.argv[4]),
    "test", test(sys.argv[2], sys.argv[3]),
    "test_all", test_all(sys.argv[2])
}.get(sys.argv[1], incorrect_command())
