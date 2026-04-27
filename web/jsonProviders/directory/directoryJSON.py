#!/usr/bin/env python
# -*- coding: UTF-8 -*-

__author__ = 'jaredfields'

import sys
sys.path.append('C:\\inetpub\\wwwroot\\includes\\python')

import cgi
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
fetchCurrent = False

if withDebug:
  import cgitb; cgitb.enable()
  print()

def debug(msg):
  if withDebug:
    print(msg)

cacheDir = 'C:/inetpub/wwwroot/cache/directory'
cachedFileName = "directory.json"
cachedDirectoryPath = os.path.join(cacheDir, cachedFileName)
cacheTimeOutInSeconds = 60 * 60 * 2  # 2 hours

useCached = False

form = cgi.FieldStorage()

# if we cannot connect to the database, raise that issue to the calling page. {"success": false, "message": "Error connecting to the database."}
if type(Bcon) is dict:
  JSONString = json.dumps(Bcon)

  print("content-type: application/json")
  print('')

  try:
    callback = form.getvalue('callback')
    print((callback+'('+JSONString+')'))
  except:
    print(JSONString)
  
  sys.exit(1)

if form.getvalue("fetchCurrent"):
  fetchCurrent = True

def process_job_title(job_title_data):
  """Process job title with proper error handling"""
  if job_title_data is None:
    return ""  # Or some default value
  
  match = titleExtractor.match(job_title_data)
  if match:
    # Match found, extract group 2
    return match.group(2).replace(" WF ", " WORK FORCE ").replace(" SERV ", " SERVICES ")
  else:
    # No match found, use original or apply some default handling
    return job_title_data  # Or job_title_data.split("-")[-1]

def useCached():
    if os.path.exists(cachedDirectoryPath):
        cachedFileModifiedTime = os.path.getmtime(cachedDirectoryPath)
        modTime = datetime.fromtimestamp(cachedFileModifiedTime)
        return (datetime.now() - modTime).total_seconds() <= cacheTimeOutInSeconds
    return False

useCached = useCached()
if fetchCurrent: useCached = False


def get_fresh_data():
  strSQL = f'''SELECT DISTINCT
    firstname,
    lastname,
    phonenumber,
    jobtitle,
    department,
    emailaddress,
    campus,
    office
FROM (
    SELECT
        -- Use preferred first name if present; otherwise fall back to SPRIDEN_FIRST_NAME
        COALESCE(b.SPBPERS_PREF_FIRST_NAME,
                 CASE
                     WHEN aka.pidm IS NOT NULL THEN aka.firstname
                     ELSE spriden.spriden_first_name
                 END
        ) AS firstname,

        CASE
            WHEN aka.pidm IS NOT NULL THEN aka.lastname
            ELSE spriden.spriden_last_name
        END AS lastname,

        CASE
            WHEN phone.num IS NULL THEN
                CASE UPPER(camp.campus)
                    WHEN 'MONROE' THEN '3183459000'
                    WHEN 'WEST MONROE' THEN '3183976100'
                    WHEN 'RUSTON' THEN '3182514145'
                    WHEN 'BASTROP' THEN '3182830836'
                    WHEN 'BASTROP AIRPORT' THEN '3183683179'
                    WHEN 'FARMERVILLE' THEN '3185590864'
                    WHEN 'LAKE PROVIDENCE' THEN '3185744820'
                    WHEN 'TALLULAH' THEN '3183625010'
                    WHEN 'WINNSBORO' THEN '3184352163'
                    WHEN 'STATE OFFICE BUILDING' THEN '3183625010'
                    ELSE NULL
                END
            ELSE REPLACE(phone.num, '-', '')
        END AS phonenumber,

        pop.nbrjobs_desc AS jobtitle,
        title.ftvorgn_title AS department,

        CASE
            WHEN work_eml.work_email IS NOT NULL THEN work_eml.work_email
            ELSE
                CASE TO_CHAR(pop.ecls_code)
                    WHEN '50' THEN gobtpac.gobtpac_external_user || '@my.ladelta.edu'
                    WHEN '51' THEN gobtpac.gobtpac_external_user || '@my.ladelta.edu'
                    ELSE gobtpac.gobtpac_external_user || '@ladelta.edu'
                END
        END AS emailaddress,

        camp.campus,
        phone.office
    FROM spriden

    -- New join to SPBPERS for preferred first name
    LEFT JOIN SPBPERS b
      ON b.SPBPERS_PIDM = spriden.SPRIDEN_PIDM

    JOIN (
        SELECT
            nbrjobs.nbrjobs_pidm AS pidm,
            MAX(nbrjobs.nbrjobs_jbln_code) KEEP (DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date) AS jbln_code,
            MAX(nbrjobs.nbrjobs_effective_date) KEEP (DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date) AS eff_date,
            MAX(nbrjobs.nbrjobs_desc) KEEP (DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date) AS nbrjobs_desc,
            MAX(nbrbjob.nbrbjob_contract_type) KEEP (DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date) AS ctype,
            MAX(nbrjobs.nbrjobs_orgn_code_ts) KEEP (DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date) AS orgn_code,
            MAX(nbrjobs.nbrjobs_ecls_code) KEEP (DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date) AS ecls_code,
            MAX(nbrjobs.nbrjobs_status) KEEP (DENSE_RANK LAST ORDER BY nbrjobs.nbrjobs_effective_date) AS empl_status
        FROM nbrjobs
        JOIN nbrbjob
          ON nbrbjob.nbrbjob_pidm = nbrjobs.nbrjobs_pidm
         AND nbrbjob.nbrbjob_posn = nbrjobs.nbrjobs_posn
         AND nbrbjob.nbrbjob_suff = nbrjobs.nbrjobs_suff
         AND nbrjobs.nbrjobs_status <> 'T'
         AND nbrbjob.nbrbjob_contract_type = 'P'
        GROUP BY nbrjobs.nbrjobs_pidm
    ) pop ON pop.pidm = spriden.spriden_pidm

    JOIN (
        SELECT pebempl.pebempl_pidm AS pidm,
               pebempl.pebempl_ecls_code AS ecls_code
        FROM pebempl
        WHERE pebempl.pebempl_empl_status <> 'T'
    ) emp_status ON emp_status.pidm = pop.pidm

    LEFT JOIN (
        SELECT DISTINCT
            spriden.spriden_pidm AS pidm,
            spriden.spriden_last_name AS lastname,
            spriden.spriden_first_name AS firstname
        FROM spriden
        WHERE spriden.spriden_ntyp_code = 'AKA'
    ) aka ON aka.pidm = spriden.spriden_pidm

    LEFT JOIN (
        SELECT goremal.goremal_pidm AS pidm,
               goremal.goremal_email_address AS work_email
        FROM goremal
        JOIN (
            SELECT goremal_pidm AS pidm,
                   MAX(goremal_activity_date) AS md
            FROM goremal
            WHERE goremal_emal_code = 'BUS'
            GROUP BY goremal_pidm
        ) maxd ON maxd.pidm = goremal.goremal_pidm
             AND maxd.md = goremal.goremal_activity_date
             AND goremal.goremal_status_ind = 'A'
             AND goremal.goremal_emal_code = 'BUS'
    ) work_eml ON work_eml.pidm = spriden.spriden_pidm

    LEFT JOIN gobtpac
      ON gobtpac.gobtpac_pidm = spriden.spriden_pidm

    LEFT JOIN (
        SELECT ftvorgn_orgn_code AS orgn_code,
               ftvorgn_title
        FROM ftvorgn
        JOIN (
            SELECT ftvorgn_orgn_code AS code,
                   MAX(ftvorgn_eff_date) AS md
            FROM ftvorgn
            GROUP BY ftvorgn_orgn_code
        ) maxfd ON maxfd.code = ftvorgn.ftvorgn_orgn_code
             AND maxfd.md = ftvorgn.ftvorgn_eff_date
        WHERE ftvorgn_status_ind = 'A'
    ) title ON title.orgn_code = pop.orgn_code

    LEFT JOIN (
        SELECT stvcamp_code AS camp_code,
               INITCAP(TRIM(REPLACE(LOWER(stvcamp_desc), 'campus', ''))) AS campus
        FROM stvcamp
    ) camp ON camp.camp_code = pop.jbln_code

    LEFT JOIN (
        SELECT pidm,
               CASE
                   WHEN business_number IS NOT NULL THEN business_number
                   WHEN campus_number  IS NOT NULL THEN campus_number
                   ELSE NULL
               END AS num,
               CASE
                   WHEN business_number IS NOT NULL THEN 'business'
                   WHEN campus_number  IS NOT NULL THEN 'campus'
                   ELSE NULL
               END AS which_number,
               CASE
                   WHEN business_office IS NOT NULL THEN business_office
                   WHEN campus_office   IS NOT NULL THEN campus_office
                   ELSE NULL
               END AS office,
               CASE
                   WHEN business_tele_code IS NOT NULL THEN business_tele_code
                   WHEN campus_tele_code   IS NOT NULL THEN campus_tele_code
                   ELSE NULL
               END AS sprtele_tele_code
        FROM (
            SELECT sprtele.sprtele_pidm AS pidm,
                   MAX(CASE WHEN sprtele_tele_code = 'BU' THEN sprtele_phone_area||sprtele_phone_number END) AS business_number,
                   MAX(CASE WHEN sprtele_tele_code = 'CA' THEN sprtele_phone_area||sprtele_phone_number END) AS campus_number,
                   MAX(CASE WHEN sprtele_tele_code = 'BU' AND sprtele_comment IS NOT NULL THEN sprtele_comment END) AS business_office,
                   MAX(CASE WHEN sprtele_tele_code = 'CA' AND sprtele_comment IS NOT NULL THEN sprtele_comment END) AS campus_office,
                   MAX(CASE WHEN sprtele_tele_code = 'BU' THEN sprtele_tele_code END) AS business_tele_code,
                   MAX(CASE WHEN sprtele_tele_code = 'CA' THEN sprtele_tele_code END) AS campus_tele_code
            FROM sprtele
            JOIN (
                SELECT sprtele_pidm AS pidm,
                       sprtele_tele_code AS code,
                       MAX(sprtele_seqno) AS max_seq
                FROM sprtele
                GROUP BY sprtele_pidm, sprtele_tele_code
            ) latest_tele ON latest_tele.pidm = sprtele.sprtele_pidm
                        AND latest_tele.max_seq = sprtele.sprtele_seqno
                        AND latest_tele.code    = sprtele.sprtele_tele_code
            WHERE sprtele.sprtele_tele_code IN ('CA','BU')
              AND sprtele.sprtele_status_ind IS NULL
            GROUP BY sprtele.sprtele_pidm
        )
    ) phone ON phone.pidm = spriden.spriden_pidm

    WHERE spriden.spriden_change_ind IS NULL
      AND (CASE
             WHEN TRIM(BOTH ' ' FROM TRIM(BOTH '-' FROM SUBSTR(pop.nbrjobs_desc,8))) = 'STUDENT'
             THEN 'STUDENT WORKER'
             ELSE TRIM(BOTH ' ' FROM TRIM(BOTH '-' FROM SUBSTR(pop.nbrjobs_desc,8)))
           END) <> 'STUDENT WORKER'
      AND emp_status.ecls_code NOT IN ('CO','AC')
)
ORDER BY lastname, firstname'''

  RS = Bcur.execute(strSQL)


  directoryList = []

  try:
    if RS:
      for i in RS:
        FirstName = i[0]
        LastName = i[1]
        PhoneNumber = i[2]
        if PhoneNumber == None:
          PhoneNumber = ''
        else:
          PhoneNumber = str('(' + PhoneNumber[0:3] +') ' + PhoneNumber[3:6] + '-' + PhoneNumber[6:])
        # JobTitle = i[3].split("-")[-1]
        JobTitle = i[3]
        if JobTitle == None:
          JobTitle = JobTitle
        else:
          JobTitle = process_job_title(JobTitle)
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
        directoryList.append({
          "FirstName": FirstName,
          "LastName": LastName,
          "PhoneNumber": PhoneNumber,
          "JobTitle": JobTitle,
          "Department": Department,
          "EmailAddress": EmailAddress,
          "Campus": Campus,
          "Office": Office
        })

      return json.dumps(
        directoryList,
        # sort_keys=True,
        # indent=4
        )
  except Exception as e:
    print(e)
    raise


def main():
  if useCached:
    debug("Cached data still valid. Returning cached data.")
    JSONString = open(os.path.join(cacheDir, cachedFileName), "r").read()
  else:
    debug("Cached data expired.")
    try:
      debug("Attempting to retrieve fresh data.")
      JSONString = get_fresh_data()
      # cache the data
      with open(os.path.join(cacheDir, cachedFileName), "w") as cf:
        cf.write(JSONString)
    except:
      debug("Retrieving fresh data failed.")
      try:
        debug("Attempting to return cached data.")
        JSONString = open(os.path.join(cacheDir, cachedFileName), "r").read()
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
  main()