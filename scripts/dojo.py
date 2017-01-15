#!/usr/bin/python
import sys, json, urllib

def fetch_dojo_list():
    dojo_url = "https://raw.githubusercontent.com/kataslog/katas/master/dojo.json"
    return json.loads(urllib.urlopen(dojo_url).read())

def show_dojo_names():
    dojo_list = fetch_dojo_list()
    for (name, description) in map(lambda dojo: (dojo["name"], dojo["description"]), dojo_list):
        print "%s - %s" % (name, description)

def get_dojo_from_list_by_name(dojo_list, name):
    return filter(lambda dojo: dojo["name"] == name, dojo_list)

def get_dojo_url_by_name(name):
    dojo_list = fetch_dojo_list()
    required_dojo = get_dojo_url_by_name(dojo_list, name)
    if any(required_dojo):
        fetch_dojo(required_dojo[0]["url"])
        return true
    else:
        print "Dojo with name %s is not found" % name
        return false

def fetch_dojo(url):
    # fetching dojo by url
    return 0

if len(sys.argv) == 1:
    show_dojo_names()
    sys.exit(0)
else:
    is_success = get_dojo_url_by_name(sys.argv[1])
    sys.exit(0 if is_success else 1)
