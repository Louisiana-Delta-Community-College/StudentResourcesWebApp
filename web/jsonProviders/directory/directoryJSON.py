#!/usr/bin/env python
# -*- coding: UTF-8 -*-

__author__ = 'jaredfields'

import sys
sys.path.append('C:\\inetpub\\wwwroot\\includes\\python')

import cgi
import asyncio
import os
import re
import string
from datetime import datetime
import json
try:
  from ...includes.python.banner_prod_con import *
except:
  from banner_prod_con import *

titleExtractor = re.compile(r'([0-9]+\s?-)(.+)')

withDebug = False

if withDebug:
  import cgitb; cgitb.enable()
  print()

def debug(msg):
  if withDebug:
    print(msg)
  
cacheDir = 'C:/inetpub/wwwroot/cache/directory'
cachedDirectoryPath = os.path.join(cacheDir, "cachedDirectory.json")
cacheTimeOutInSeconds = 60 * 60 * 2  # 2 hours

form = cgi.FieldStorage()

def useCached():
  if os.path.exists(cachedDirectoryPath):
    cachedFileModifiedTime = os.path.getmtime(cachedDirectoryPath)
    modTime = datetime.fromtimestamp(cachedFileModifiedTime)
    return (datetime.now() - modTime).total_seconds() <= cacheTimeOutInSeconds
  return False

async def get_fresh_data():
  strSQL = '''
SELECT DISTINCT
  firstname,
  lastname,
  phonenumber,
  jobtitle,
  department,
  emailaddress,
  campus,
  office
FROM
  (
    SELECT
      CASE
        WHEN aka.pidm IS NOT NULL THEN
          aka.firstname
        ELSE
          spriden.spriden_first_name
      END                    firstname,
      CASE
        WHEN aka.pidm IS NOT NULL THEN
          aka.lastname
        ELSE
          spriden.spriden_last_name
      END                    lastname,
      CASE
        WHEN phone.num IS NULL THEN
            CASE
              WHEN upper(camp.campus) = 'MONROE'                      THEN
                '3183459000'
              WHEN upper(camp.campus) = 'WEST MONROE'                 THEN
                '3183976100'
              WHEN upper(camp.campus) = 'RUSTON'                      THEN
                '3182514145'
              WHEN upper(camp.campus) = 'BASTROP'                     THEN
                '3182830836'
              WHEN upper(camp.campus) = 'BASTROP AIRPORT'             THEN
                '3183683179'
              WHEN upper(camp.campus) = 'FARMERVILLE'                 THEN
                '3185590864'
              WHEN upper(camp.campus) = 'LAKE PROVIDENCE'             THEN
                '3185744820'
              WHEN upper(camp.campus) = 'TALLULAH'                    THEN
                '3183625010'
              WHEN upper(camp.campus) = 'WINNSBORO'                   THEN
                '3184352163'
              WHEN upper(camp.campus) = 'STATE OFFICE BUILDING'       THEN
                '3183625010'
              ELSE
                NULL
            END
        ELSE
          replace(phone.num, '-', '')
      END                    phonenumber,
      pop.nbrjobs_desc       jobtitle,
      title.ftvorgn_title    department,
      CASE
        WHEN work_eml.work_email IS NOT NULL THEN
          work_eml.work_email
        ELSE
          CASE
              WHEN to_char(pop.ecls_code) = '50'       THEN
                gobtpac.gobtpac_external_user || '@my.ladelta.edu'
              WHEN to_char(pop.ecls_code) = '51'       THEN
                gobtpac.gobtpac_external_user || '@my.ladelta.edu'
              ELSE
                gobtpac.gobtpac_external_user || '@ladelta.edu'
          END
      END                    emailaddress,
      camp.campus,
      phone.office
    FROM
          spriden
      JOIN (
        SELECT
          nbrjobs.nbrjobs_pidm                                                                                         pidm,
          MAX(nbrjobs.nbrjobs_jbln_code) KEEP(DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date)         jbln_code,
          MAX(nbrjobs.nbrjobs_effective_date) KEEP(DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date)    eff_date,
          MAX(nbrjobs.nbrjobs_desc) KEEP(DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date)              nbrjobs_desc,
          MAX(nbrbjob.nbrbjob_contract_type) KEEP(DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date)     ctype,
          MAX(nbrjobs.nbrjobs_orgn_code_ts) KEEP(DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date)      orgn_code,
          MAX(nbrjobs.nbrjobs_ecls_code) KEEP(DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date)         ecls_code,
          MAX(nbrjobs.nbrjobs_status) KEEP(DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date)            empl_status
        FROM
              nbrjobs
          JOIN nbrbjob ON nbrbjob.nbrbjob_pidm = nbrjobs.nbrjobs_pidm
                          AND nbrbjob.nbrbjob_posn = nbrjobs.nbrjobs_posn
                          AND nbrbjob.nbrbjob_suff = nbrjobs.nbrjobs_suff
                          AND nbrjobs.nbrjobs_status <> 'T'
                          AND nbrbjob.nbrbjob_contract_type = 'P'
        GROUP BY
          nbrjobs.nbrjobs_pidm
      )  pop ON pop.pidm = spriden.spriden_pidm
      JOIN (
        SELECT
          pebempl.pebempl_pidm         pidm,
          pebempl.pebempl_ecls_code    ecls_code
        FROM
          pebempl
        WHERE
          pebempl.pebempl_empl_status <> 'T'
      )  emp_status ON emp_status.pidm = pop.pidm
      LEFT JOIN (
        SELECT DISTINCT
          spriden.spriden_pidm          pidm,
          spriden.spriden_last_name     lastname,
          spriden.spriden_first_name    firstname
        FROM
          spriden
        WHERE
          spriden.spriden_ntyp_code = 'AKA'
      )  aka ON aka.pidm = spriden.spriden_pidm
      LEFT JOIN (
        SELECT
          goremal.goremal_pidm             pidm,
          goremal.goremal_email_address    work_email
        FROM
              goremal
          JOIN (
            SELECT
              goremal.goremal_pidm                     pidm,
              MAX(goremal.goremal_activity_date)       md
            FROM
              goremal
            WHERE
              goremal.goremal_emal_code = 'BUS'
            GROUP BY
              goremal.goremal_pidm
          ) maxd ON maxd.pidm = goremal.goremal_pidm
                    AND maxd.md = goremal.goremal_activity_date
                    AND goremal.goremal_status_ind = 'A'
                    AND goremal.goremal_emal_code = 'BUS'
      )  work_eml ON work_eml.pidm = spriden.spriden_pidm
      LEFT JOIN gobtpac ON gobtpac.gobtpac_pidm = spriden.spriden_pidm
      LEFT JOIN (
        SELECT
          ftvorgn.ftvorgn_orgn_code orgn_code,
          ftvorgn.ftvorgn_title
        FROM
              ftvorgn
          JOIN (
            SELECT
              ftvorgn.ftvorgn_orgn_code           code,
              MAX(ftvorgn.ftvorgn_eff_date)       md
            FROM
              ftvorgn
            GROUP BY
              ftvorgn.ftvorgn_orgn_code
          ) maxfd ON maxfd.code = ftvorgn.ftvorgn_orgn_code
                    AND maxfd.md = ftvorgn.ftvorgn_eff_date
        WHERE
          ftvorgn.ftvorgn_status_ind = 'A'
      )  title ON title.orgn_code = pop.orgn_code

    /* CAMPUS */
      LEFT JOIN (
        SELECT
          stvcamp.stvcamp_code                                                                   camp_code,
          ( initcap(TRIM(replace(lower(stvcamp.stvcamp_desc), 'campus', ''))) )                    campus
        FROM
          stvcamp
      )  camp ON camp.camp_code = pop.jbln_code

    /* PHONE NUMBER */
      LEFT JOIN (
        SELECT DISTINCT
          pidm,
          CASE
            WHEN campus_number IS NOT NULL THEN
              campus_number
            WHEN business_number IS NOT NULL THEN
              business_number
            ELSE
              NULL
          END  AS num,
          CASE
            WHEN campus_number IS NOT NULL THEN
              'campus'
            WHEN business_number IS NOT NULL THEN
              'business'
            ELSE
              NULL
          END  AS which_number,
          office,
          sprtele_tele_code
        FROM
          (
            SELECT
              sprtele.sprtele_pidm       pidm,
              MAX(
                CASE
                  WHEN sprtele.sprtele_tele_code = 'CA' THEN
                    sprtele.sprtele_phone_area || sprtele.sprtele_phone_number
                  ELSE
                    NULL
                END
              )                          campus_number,
              MAX(
                CASE
                  WHEN sprtele.sprtele_tele_code = 'BU' THEN
                    sprtele.sprtele_phone_area || sprtele.sprtele_phone_number
                  ELSE
                    NULL
                END
              )                          business_number,
              sprtele.sprtele_comment    office,
              sprtele.sprtele_tele_code
            FROM
                  sprtele
              JOIN (
                SELECT
                  sprtele.sprtele_pidm             pidm,
                  sprtele.sprtele_tele_code        code,
                  MAX(sprtele.sprtele_seqno)       max_seq
                FROM
                  sprtele
                GROUP BY
                  sprtele.sprtele_pidm,
                  sprtele.sprtele_tele_code
              ) latest_tele ON latest_tele.pidm = sprtele.sprtele_pidm
                              AND latest_tele.max_seq = sprtele.sprtele_seqno
                              AND latest_tele.code = sprtele.sprtele_tele_code
            WHERE
              sprtele.sprtele_tele_code IN ( 'CA', 'BU' )
              AND sprtele.sprtele_status_ind IS NULL
            GROUP BY
              sprtele.sprtele_pidm,
              sprtele.sprtele_comment,
              sprtele.sprtele_tele_code
          )
      )  phone ON phone.pidm = spriden.spriden_pidm
    WHERE
      spriden.spriden_change_ind IS NULL
      AND CASE
            WHEN TRIM(BOTH ' ' FROM(TRIM(BOTH '-' FROM(substr(pop.nbrjobs_desc, 8))))) = 'STUDENT' THEN
              'STUDENT WORKER'
            ELSE
              TRIM(BOTH ' ' FROM(TRIM(BOTH '-' FROM(substr(pop.nbrjobs_desc, 8)))))
          END <> 'STUDENT WORKER'
      AND emp_status.ecls_code NOT IN ( 'CO', 'AC' )
  )
ORDER BY
  lastname,
  firstname'''.format(**locals())

  RS = Bcur.execute(strSQL)

  employeeList = []

  if RS:
    from string import capwords
    for i in RS:
      FirstName = i[0]
      LastName = i[1]
      PhoneNumber = i[2]
      if PhoneNumber == None:
          PhoneNumber = ''
      else:
          PhoneNumber = str('(' + PhoneNumber[0:3] +') ' + PhoneNumber[3:6] + '-' + PhoneNumber[6:])
      # JobTitle = i[3].split("-")[-1]
      JobTitle = titleExtractor.match(i[3]).group(2).replace(" WF ", " WORK FORCE ").replace(" SERV ", " SERVICES ")
      if JobTitle.upper() == "STUDENT":
        JobTitle = "STUDENT WORKER"
      Department = i[4]
      if Department == None:
          Department = ''
      EmailAddress = i[5]
      Campus = i[6]
      Office = i[7]
      if Office == None:
          Office = ''
      employeeList.append(
        {
          "FirstName": FirstName,
          "LastName": LastName,
          "PhoneNumber": PhoneNumber,
          "JobTitle": JobTitle,
          "Department": Department,
          "EmailAddress": EmailAddress,
          "Campus": Campus,
          "Office": Office
        }
      )
    
    # cache fresh data
    with open(cachedDirectoryPath, 'w') as cachedFile:
      cachedFile.write(json.dumps(employeeList))

    # build JSON string to return
    return json.dumps(
      employeeList,
      # sort_keys=True,
      # indent=4
      )

async def main():
  if useCached():
    debug("Cached data still valid. Returning cached data.")
    JSONString = open(cachedDirectoryPath, "r").read()
  else:
    debug("Cached data expired.")
    try:
      debug("Attempting to retrieve fresh data.")
      JSONString = await asyncio.wait_for(get_fresh_data(), timeout=3)
    except:
      debug("Retrieving fresh data failed.")
      try:
        debug("Attempting to return cached data.")
        JSONString = open(cachedDirectoryPath, "r").read()
      except:
        debug("No cached data found. Returning error.")
        JSONString = """{"success": false, message: "Could not connect to database."}"""

  # print('Content-type: application/octet-stream\n')
  # print('Content-encoding: gzip\n\n\')
  print("content-type: application/json")
  print()

  try:
    callback = form.getvalue('callback')
    print((callback+'('+JSONString+')'))
  except:
    print(JSONString)

if __name__ == "__main__":
  # loop = asyncio.get_event_loop()
  asyncio.run(main())