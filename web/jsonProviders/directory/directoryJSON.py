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
    SELECT
      CASE
        WHEN aka.pidm IS NOT NULL
        THEN aka.FirstName
        ELSE spriden.SPRIDEN_FIRST_NAME
      END FirstName,
      CASE
        WHEN aka.pidm IS NOT NULL
        THEN aka.LastName
        ELSE spriden.SPRIDEN_LAST_NAME
      END LastName,
      CASE
        WHEN phone.num IS NULL
        THEN
          case
            WHEN UPPER(CAMP.CAMPUS) = 'MONROE'
            then '3183459000'
            WHEN UPPER(CAMP.CAMPUS) = 'WEST MONROE'
            then '3183976100'
            WHEN UPPER(CAMP.CAMPUS) = 'RUSTON'
            then '3182514145'
            WHEN UPPER(CAMP.CAMPUS) = 'BASTROP'
            then '3182830836'
            WHEN UPPER(CAMP.CAMPUS) = 'BASTROP AIRPORT'
            then '3183683179'
            WHEN UPPER(CAMP.CAMPUS) = 'FARMERVILLE'
            then '3185590864'
            WHEN UPPER(CAMP.CAMPUS) = 'LAKE PROVIDENCE'
            then '3185744820'
            WHEN UPPER(CAMP.CAMPUS) = 'TALLULAH'
            THEN '3183625010'
            WHEN UPPER(CAMP.CAMPUS) = 'WINNSBORO'
            then '3184352163'
            WHEN UPPER(CAMP.CAMPUS) = 'STATE OFFICE BUILDING'
            then '3183625010'
            else null
          end
        ELSE replace(phone.num, '-', '')
      END PhoneNumber,
      pop.nbrjobs_desc JobTitle,
      title.ftvorgn_title Department,
      case
        when work_eml.work_email is not null then work_eml.work_email 
        else
          case
            WHEN TO_CHAR(pop.ECLS_CODE) = '50' THEN gobtpac.GOBTPAC_EXTERNAL_USER
              ||'@my.ladelta.edu'
            WHEN TO_CHAR(pop.ECLS_CODE) = '51' THEN gobtpac.GOBTPAC_EXTERNAL_USER
              ||'@my.ladelta.edu'
            ELSE gobtpac.GOBTPAC_EXTERNAL_USER||'@ladelta.edu'
          end
      end emailaddress,
      CAMP.CAMPUS,
      phone.office
    FROM spriden
    JOIN
      (SELECT nbrjobs.nbrjobs_pidm pidm,
        MAX(nbrjobs.nbrjobs_jbln_code) keep (dense_rank last
      ORDER BY nbrjobs.nbrjobs_effective_date) jbln_code,
        MAX(nbrjobs.nbrjobs_effective_date) keep (dense_rank last
      ORDER BY nbrjobs.nbrjobs_effective_date) eff_date,
        MAX(nbrjobs.nbrjobs_desc) keep (dense_rank last
      ORDER BY nbrjobs.nbrjobs_effective_date) nbrjobs_desc,
        MAX(nbrbjob.nbrbjob_contract_type) keep (dense_rank last
      ORDER BY nbrjobs.nbrjobs_effective_date) ctype,
        MAX(nbrjobs.nbrjobs_orgn_code_ts) keep (dense_rank last
      ORDER BY nbrjobs.nbrjobs_effective_date) orgn_code,
        MAX(nbrjobs.nbrjobs_ecls_code) keep (dense_rank last
      ORDER BY nbrjobs.nbrjobs_effective_date) ecls_code,
        MAX(nbrjobs.nbrjobs_status) keep (dense_rank last
      ORDER BY nbrjobs.nbrjobs_effective_date) empl_status
      FROM nbrjobs
      JOIN nbrbjob
      ON nbrbjob.nbrbjob_pidm           = nbrjobs.nbrjobs_pidm
      AND nbrbjob.nbrbjob_posn          = nbrjobs.nbrjobs_posn
      AND nbrbjob.nbrbjob_suff          = nbrjobs.nbrjobs_suff
      AND nbrjobs.nbrjobs_status       <> 'T'
      AND nbrbjob.nbrbjob_contract_type = 'P'
      GROUP BY nbrjobs.nbrjobs_pidm
      ) pop ON pop.pidm = spriden.spriden_pidm
    JOIN
      (SELECT pebempl.pebempl_pidm pidm,
        pebempl.pebempl_ecls_code ecls_code
      FROM pebempl
      WHERE pebempl.pebempl_empl_status <> 'T'
      ) emp_status
    ON emp_status.pidm = pop.pidm
    LEFT JOIN
      (SELECT DISTINCT spriden.spriden_pidm pidm,
        spriden.spriden_last_name LastName,
        spriden.spriden_first_name FirstName
      FROM spriden
      WHERE spriden.spriden_ntyp_code = 'AKA'
      ) aka
    ON aka.pidm = spriden.spriden_pidm
    LEFT JOIN (SELECT goremal.goremal_pidm pidm,
                      goremal.goremal_email_address work_email
              FROM goremal
              join (select goremal.goremal_pidm pidm, max(goremal.goremal_activity_date) md from goremal where goremal.goremal_emal_code = 'BUS' group by goremal.goremal_pidm) maxd on maxd.pidm = goremal.goremal_pidm and maxd.md = goremal.goremal_activity_date
              AND goremal.goremal_status_ind = 'A'
              AND goremal.goremal_emal_code = 'BUS') work_eml ON work_eml.pidm = spriden.spriden_pidm
    left join gobtpac on gobtpac.gobtpac_pidm = spriden.spriden_pidm
    LEFT JOIN
      (SELECT ftvorgn.ftvorgn_orgn_code orgn_code,
        ftvorgn.ftvorgn_title
      FROM ftvorgn
      JOIN
        (SELECT ftvorgn.ftvorgn_orgn_code code,
          MAX(ftvorgn.ftvorgn_eff_date) md
        FROM ftvorgn
        GROUP BY ftvorgn.ftvorgn_orgn_code
        ) maxfd
      ON maxfd.code                    = ftvorgn.ftvorgn_orgn_code
      AND maxfd.md                     = ftvorgn.ftvorgn_eff_date
      WHERE ftvorgn.ftvorgn_status_ind = 'A'
      ) title ON title.orgn_code       = pop.orgn_code

    /* CAMPUS */
    left join (
      select
        STVCAMP.STVCAMP_CODE CAMP_CODE,
        (INITCAP(TRIM(replace(LOWER(STVCAMP.STVCAMP_DESC), 'campus', '')))) CAMPUS
      from STVCAMP
    ) CAMP
    on camp.camp_code = pop.jbln_code

    /* PHONE NUMBER */
    left join (select distinct
      pidm,
      case
        WHEN campus_number IS NOT NULL THEN campus_number
        WHEN business_number IS NOT NULL THEN business_number
        ELSE NULL
      END AS num,
      case
        WHEN campus_number IS NOT NULL THEN 'campus'
        WHEN business_number IS NOT NULL THEN 'business'
        else null
      end as WHICH_NUMBER,
      OFFICE,
      SPRTELE_TELE_CODE
      from (
        SELECT 
          sprtele.sprtele_pidm pidm,
          max(case
            when SPRTELE.SPRTELE_TELE_CODE = 'CA' then SPRTELE.SPRTELE_PHONE_AREA||SPRTELE.SPRTELE_PHONE_NUMBER
            else null
          END) campus_number,
          max(case
            WHEN sprtele.sprtele_tele_code = 'BU' THEN sprtele.sprtele_phone_area||sprtele.sprtele_phone_number
            else null
          END) business_number,
          SPRTELE.SPRTELE_COMMENT OFFICE,
          sprtele.sprtele_tele_code
          FROM sprtele
          JOIN (
            SELECT 
              sprtele.sprtele_pidm pidm,
              sprtele.sprtele_tele_code code,
              max(sprtele.sprtele_seqno) max_seq
            from sprtele
            group by 
              sprtele.sprtele_pidm,
              sprtele.sprtele_tele_code
          ) LATEST_TELE 
          on LATEST_TELE.PIDM = SPRTELE.SPRTELE_PIDM 
          and LATEST_TELE.MAX_SEQ = SPRTELE.SPRTELE_SEQNO 
          and LATEST_TELE.CODE = SPRTELE.SPRTELE_TELE_CODE
          WHERE sprtele.sprtele_tele_code IN ('CA', 'BU')
          and SPRTELE.SPRTELE_STATUS_IND is null
          group by 
            SPRTELE.SPRTELE_PIDM,
            SPRTELE.SPRTELE_COMMENT,
            SPRTELE.SPRTELE_TELE_CODE
      )
    ) phone ON phone.pidm = spriden.spriden_pidm

    WHERE spriden.spriden_change_ind  IS NULL
    AND
      CASE
        WHEN trim(BOTH ' '
        FROM (trim(BOTH '-'
        FROM (SUBSTR(pop.nbrjobs_desc, 8))))) = 'STUDENT'
        THEN 'STUDENT WORKER'
        ELSE trim(BOTH ' '
        FROM (trim(BOTH '-'
        FROM (SUBSTR(pop.nbrjobs_desc, 8)))))
      END                        <> 'STUDENT WORKER'
    AND emp_status.ECLS_CODE NOT IN ('CO', 'AC')
    order by spriden.spriden_last_name,
      spriden.spriden_first_name'''.format(**locals())

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