#!/usr/bin/env python2
# -*- coding: utf-8 -*-
from urllib import urlencode
from urllib2 import urlopen
from sys import argv
import re
import os

username='5644202'
password='21362Un2!'
storeid='/home/cagprado/.uspnetid'

def login():
    params = {
            'auth_user':username,
            'auth_pass':password,
            'redirurl':'',
            'accept':'ok',
            }

    # Try to open a generic URL
    testurl = urlopen('http://www.google.com/').geturl()
    if(len(re.findall('semfio.usp.br',testurl)) == 0):
        print 'We are already connected'
        return

    # Login if we are not connected
    fd = open(storeid,"w")
    req = urlopen(testurl, data = urlencode(params))
    fd.write(testurl + '\n')
    fd.write(re.findall('<INPUT NAME="logout_id" TYPE="hidden" VALUE="([a-f0-9]{16})">', req.read())[0])
    fd.close()

def logout():
    try:
        fd = open(storeid,"r")
    except IOError:
        print("Cannot find file '" + storeid + "', aborting logout...")
        return

    url = fd.readline()
    id = fd.readline()
    fd.close()
    os.remove(storeid)

    params = {
            'logout_id':id,
            'logout':'Logout',
            }
    req = urlopen(url, data = urlencode(params))

if len(argv) != 2:
    print("Wrong number of arguments... put 'login' or 'logout'.")
elif argv[1] == 'login':
    login()
elif argv[1] == 'logout':
    logout()
else:
    print("Unrecognized argument '" + argv[1] + "'... put 'login' or 'logout'.")
