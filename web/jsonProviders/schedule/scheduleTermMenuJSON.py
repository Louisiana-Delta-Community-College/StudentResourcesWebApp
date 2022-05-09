#!/usr/bin/env python
# -*- coding: UTF-8 -*-

__author__ = 'jaredfields'

import sys
sys.path.append('C:\\inetpub\\wwwroot\\includes\\python')

import cgi
import cgitb
cgitb.enable()

# print "Content Type: application/json" # print the headers
print("content-type: application/json")
print()  # blank line to make the browser recognize the header(s)
from markupsafe import escape
import json
import time

'''
|   To see the time it took this page to return the requested JSON, look in the 'response' for this page's request in
|   the "network" tab of the web browser.
|
|   It will look something like:
|       jQuery1110017845577730254913_1449699347570([{"SA": "10", "T": "2 ... }])
|       2.8081469535827637
|
|   If the browser does text wrapping for this data, it will be at the very bottom.
|
|   This can be turned off by setting 'printTime' to False
'''
printTime = False
if printTime:
    timeStart = time.time()

form = cgi.FieldStorage()

def main():


    termList = [
    #   {"id": 0, "Term": "202030", "Desc": "Maymester 2020", "TermTy": "J10"},
    #   {"id": 1, "Term": "202110", "Desc": "Fall 2020", "TermTy": ""},
    #   {"id": 0, "Term": "202120", "Desc": "Winter 2020", "TermTy": "JWN"},
    #   {"id": 1, "Term": "202120", "Desc": "Spring 2021", "TermTy": ""},
    #   {"id": 3, "Term": "202130", "Desc": "Summer 2021", "TermTy": ""},
    #   {"id": 2, "Term": "202130", "Desc": "Maymester 2021", "TermTy": "JP3"},
      {"id": 4, "Term": "202210", "Desc": "Fall 2021", "TermTy": ""},
      {"id": 5, "Term": "202220", "Desc": "Winter 2021", "TermTy": "JWN"},
      {"id": 6, "Term": "202220", "Desc": "Spring 2022", "TermTy": ""},
      {"id": 6, "Term": "202230", "Desc": "Summer 2022", "TermTy": ""},
      {"id": 6, "Term": "202310", "Desc": "Fall 2022", "TermTy": ""},
      ]


    JSONString = json.dumps(termList)

    try:
        callback = form.getvalue('callback')
        print((callback+'('+JSONString+')'))
    except:
        print(JSONString)


    if printTime:
        timeEnd = time.time()
        print(str(timeEnd - timeStart))


if __name__ == "__main__":
    # import cProfile
    # cProfile.run('main()')
    main()