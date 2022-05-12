__author__ = 'jaredfields'

import sys
sys.path.append('C:/inetpub/wwwroot/includes/python')

import cgi
import cgitb
# cgitb.enable()

print() # blank line to make the browser recognize the header(s)

import os
import json

from banner_prod_con import *

form = cgi.FieldStorage()

pathSyllabi = 'C:/inetpub/wwwroot/documents/academics/masterSyllabi/'

strSQL = '''SELECT SCBCRSE_SUBJ_CODE,
              SCBCRSE_CRSE_NUMB,
              SCBCRSE_TITLE,
              SCBCRSE_CREDIT_HR_LOW
            FROM SCBCRSE A
            WHERE SCBCRSE_VPDI_CODE = 'DELTA'
            AND SCBCRSE_CSTA_CODE   = 'A'
            AND SCBCRSE_EFF_TERM    =
              (SELECT MAX(SCBCRSE_EFF_TERM)
              FROM SCBCRSE B
              WHERE A.SCBCRSE_SUBJ_CODE = B.SCBCRSE_SUBJ_CODE
              AND A.SCBCRSE_CRSE_NUMB   = B.SCBCRSE_CRSE_NUMB
              AND A.SCBCRSE_VPDI_CODE   = B.SCBCRSE_VPDI_CODE
              )
            ORDER BY SCBCRSE_SUBJ_CODE,
              SCBCRSE_CRSE_NUMB'''

RS = Bcur.execute(strSQL)

if RS:
    listSyllabi = []
    for i in RS:
        subj_code = i[0]
        crse_numb = i[1]
        crse_title = i[2]
        cred_hr = i[3]
        file_name = str(subj_code)+str(crse_numb)+'.pdf'
        if os.path.exists(pathSyllabi+file_name):
            listSyllabi.append({"S": subj_code,
                                "C": str(crse_numb),
                                "D": crse_title,
                                "H": cred_hr,
                                "L": "http://web01.ladelta.edu/documents/academics/masterSyllabi/"+str(file_name)})

try:
    callback = form.getvalue('callback')
    print((callback+'('+json.dumps(listSyllabi, sort_keys=True, indent=2)+')'))
except:
    print((json.dumps(listSyllabi, sort_keys=True, indent=2)))