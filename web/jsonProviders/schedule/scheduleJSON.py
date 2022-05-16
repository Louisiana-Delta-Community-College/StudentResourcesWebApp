#!/usr/bin/env python
# -*- coding: UTF-8 -*-

__author__ = 'jaredfields'

import cgi, cgitb
import os
import sys
from datetime import datetime, timedelta
# Debug mode:
cgitb.enable()

cacheDir = 'C:/inetpub/wwwroot/cache/schedule'
cacheTimeOutInSeconds = 60 * 60  # 1 hour

import sys
sys.path.insert(0, 'C:\\inetpub\\wwwroot\\includes\\python')
# sys.path.insert(0, 'c:\\oracle\\instantclient_12_2_x64')
# sys.path.append('c:/oracle/instantclient_12_2_x64/vc14')

useCachedFile = False

from markupsafe import escape
import json

import time

form = cgi.FieldStorage()

from banner_prod_con import *

def checkCache(term="", termType=""):
  for _, dirs, files in os.walk(cacheDir):
    for f in files:
      try:
          cachedTerm, cachedTermType = f.replace(".json", "").split('_')
      except:
          cachedTerm = f.replace(".txt", "").split('_')
          cachedTermType = ""
      if term == cachedTerm and termType == cachedTermType:
        return f, os.path.getmtime(os.path.join(cacheDir, f))
  return None, None

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

strCampSQL = ''
camp = ''
termty = ''
term = ''

if form.getvalue('termty'):
  termty = form.getvalue('termty')
else:
  termty = ''

if form.getvalue('camp'):
  camp = form.getvalue("camp")
  if (camp == '') or (camp.upper() == 'ALL'):
    strCampSQL = ''
  if camp.upper() == 'JA':
    strCampSQL = "and ssbsect.ssbsect_camp_code in ('JA')"
  if camp.upper() == 'JB':
    strCampSQL = "and ssbsect.ssbsect_camp_code in ('JB')"
  if camp.upper() == 'JC':
    strCampSQL = "and ssbsect.ssbsect_camp_code in ('JC')"
  if (camp.upper() == 'JD') or (camp.upper() == 'KA'):
    strCampSQL = "and ssbsect.ssbsect_camp_code in ('JD', 'KA')"
  if (camp.upper() == 'JE') or (camp.upper() == 'KB'):
    strCampSQL = "and ssbsect.ssbsect_camp_code in ('JE', 'KB')"
  if (camp.upper() == 'JF') or (camp.upper() == 'KC'):
    strCampSQL = "and ssbsect.ssbsect_camp_code in ('JF', 'KC')"
  if (camp.upper() == 'JG') or (camp.upper() == 'KD'):
    strCampSQL = "and ssbsect.ssbsect_camp_code in ('JG', 'KD')"
  if (camp.upper() == 'JH') or (camp.upper() == 'KE'):
    strCampSQL = "and ssbsect.ssbsect_camp_code in ('JH', 'KE')"
else:
  camp = ''

# derive the term if no term given, falling back to hard coded value if not found.
if form.getvalue('term'):
  term = form.getvalue('term')
else:
  # no term passed in so we need to know which term to retrieve
  try:
    # attempt to derive it given the current date, relative to 
    # the start and end dates of terms in banner
    strTermSQL = """
    SELECT 
      stvterm.stvterm_code term,
      stvterm.stvterm_desc term_desc
    FROM stvterm 
    JOIN (
      SELECT 
        max(stvterm.stvterm_fa_proc_yr) ma
      FROM stvterm 
      WHERE stvterm.stvterm_start_date < CURRENT_DATE
      AND CURRENT_DATE < stvterm.stvterm_end_date
    ) maxa on maxa.ma = stvterm.stvterm_fa_proc_yr
    WHERE stvterm.stvterm_start_date < CURRENT_DATE
    AND CURRENT_DATE < stvterm.stvterm_end_date
    and rownum <= 1
    and stvterm.stvterm_code not like '%05'
    """

    RS = Bcur.execute(strTermSQL)
    RSTermCurrent = RS.fetchone()
    if RSTermCurrent:
      term = RSTermCurrent[0]
      strTermDesc = RSTermCurrent[1]
      # persist derived term in case we need it later 
      # (connection to LDCC fails at a later time)
      with open(os.path.join(cacheDir, "lastDerivedTerm.json"), 'w') as ldt:
        ldt.write(json.dumps({"term": term}))
  except:
    # could not derive term from banner, so...
    try:
      # attempt retrieving last derived term first
      if os.path.exists(os.path.join(cacheDir, "lastDerivedTerm.json")):
        with open(os.path.join(cacheDir, "lastDerivedTerm.json"), 'r') as ldt:
          term = json.loads(ldt.read())["term"]
    except:
      # if that fails, check for default term in scheduleTermMenu.json file
      with open(os.path.join("C:/inetpub/wwwroot/jsonProviders/schedule", "scheduleTermMenu.json")) as termMenuJson:
        termMenuData = json.loads(termMenuJson.read())
        for entry in termMenuData:
          if entry["default"]:
            term = entry["Term"]
            break


cachedFileName, cachedFileModifiedTime = checkCache(term=term, termType=termty)
def setUseCachedFile():
  if cachedFileName is not None:
    modTime = datetime.fromtimestamp(cachedFileModifiedTime)
    return (datetime.now() - modTime).total_seconds() <= cacheTimeOutInSeconds
  else:
    return False

useCachedFile = setUseCachedFile()

if cachedFileName != "" and useCachedFile:
  # print(cachedFileName)
  pass
else:
    strTermTySQL = ''
    

    if (termty.upper() == 'W') or (termty.upper() == 'JWN'):
      strTermTySQL = "AND SSBSECT.SSBSECT_PTRM_CODE = 'JWN' "
    elif termty.upper() == 'JDE':
      strTermTySQL = "AND SSBSECT.SSBSECT_PTRM_CODE = 'JDE' "
    elif termty.upper() == 'J03':
      strTermTySQL = "AND SSBSECT.SSBSECT_PTRM_CODE = 'J03' "
    elif termty.upper() == 'J10':
      strTermTySQL = "AND SSBSECT.SSBSECT_PTRM_CODE = 'J10' "
    elif len(termty) > 0 and len(termty) <= 3 and ((str(termty)[0]).upper() in ['J']):
      strTermTySQL = f"AND SSBSECT.SSBSECT_PTRM_CODE = '{termty.upper()}' "
    else:
      strTermTySQL = "AND SSBSECT.SSBSECT_PTRM_CODE <> 'JWN' "

    # ''' if no term code specified, find the latest '''
    # if term == '':
    #   strSQL = """ select max(sfrstcr.sfrstcr_term_code) from sfrstcr
    #           JOIN sorrtrm
    #           ON sorrtrm.sorrtrm_term_code = sfrstcr.sfrstcr_term_code
    #           AND sysdate                 >= sorrtrm.sorrtrm_start_date """
    #   RS = Bcur.execute(strSQL)
    #   if RS:
    #     for i in RS:
    #       term = str(i[0])
    #       break

    # Bcur.execute("begin g$_vpdi_security.g$_vpdi_set_multiuse_context('OVERRIDEALL'); end;")

    strSQL = '''SELECT * FROM (SELECT STVTERM.STVTERM_DESC,
            SSBSECT.SSBSECT_CRN,
            SSBSECT.SSBSECT_SUBJ_CODE,
            SSBSECT.SSBSECT_CRSE_NUMB,
            SCBCRSE.SCBCRSE_CREDIT_HR_LOW,
            NVL(SSRMEET.SSRMEET_SUN_DAY
            || SSRMEET.SSRMEET_MON_DAY
            || SSRMEET.SSRMEET_TUE_DAY
            || SSRMEET.SSRMEET_WED_DAY
            || SSRMEET.SSRMEET_THU_DAY
            || SSRMEET.SSRMEET_FRI_DAY
            || SSRMEET.SSRMEET_SAT_DAY, 'TBA') AS DAYS,
            CASE
            WHEN SSRMEET.SSRMEET_BEGIN_TIME IS NOT NULL
            THEN
              CASE
              WHEN SUBSTR(SSRMEET.SSRMEET_BEGIN_TIME, 1, 2) > 12
              THEN LPAD((SUBSTR(SSRMEET.SSRMEET_BEGIN_TIME, 1, 2) - 12), 2, '0')
                || ':'
                || SUBSTR(SSRMEET.SSRMEET_BEGIN_TIME, -2, 2)
                || ' PM'
              WHEN SUBSTR(SSRMEET.SSRMEET_BEGIN_TIME, 1, 2) = 12
              THEN LPAD((SUBSTR(SSRMEET.SSRMEET_BEGIN_TIME, 1, 2)), 2, '0')
                || ':'
                || SUBSTR(SSRMEET.SSRMEET_BEGIN_TIME, -2, 2)
                || ' PM'
              ELSE LPAD(SUBSTR(SSRMEET.SSRMEET_BEGIN_TIME, 1, 2), 2, '0')
                || ':'
                || LPAD(SUBSTR(SSRMEET.SSRMEET_BEGIN_TIME, -2, 2), 2, '0')
                || ' AM'
              END
            END AS BEGTIME,
            CASE
            WHEN SSRMEET.SSRMEET_END_TIME IS NOT NULL
            THEN
              CASE
              WHEN SUBSTR(SSRMEET.SSRMEET_END_TIME, 1, 2) > 12
              THEN LPAD((SUBSTR(SSRMEET.SSRMEET_END_TIME, 1, 2) - 12), 2, '0')
                || ':'
                || SUBSTR(SSRMEET.SSRMEET_END_TIME, -2, 2)
                || ' PM'
              WHEN SUBSTR(SSRMEET.SSRMEET_END_TIME, 1, 2) = 12
              THEN LPAD((SUBSTR(SSRMEET.SSRMEET_END_TIME, 1, 2)), 2, '0')
                || ':'
                || SUBSTR(SSRMEET.SSRMEET_END_TIME, -2, 2)
                || ' PM'
              ELSE LPAD(SUBSTR(SSRMEET.SSRMEET_END_TIME, 1, 2), 2, '0')
                || ':'
                || LPAD(SUBSTR(SSRMEET.SSRMEET_END_TIME, -2, 2), 2, '0')
                || ' AM'
              END
            END                       AS ENDTIME,
            SSRMEET.SSRMEET_ROOM_CODE AS ROOM,
            CASE
            WHEN DerAssignSpriden.INST IS NULL
            THEN 'TBA'
            ELSE DerAssignSpriden.INST
            END AS TeacherName,
            SSBSECT.SSBSECT_SEATS_AVAIL,
            SSBSECT.SSBSECT_INSM_CODE,
            CASE
            WHEN SSBSECT.SSBSECT_PTRM_CODE = 'JDE'
            THEN 'LDCC DUAL ENROLLMENT'
            WHEN SSBSECT.SSBSECT_SEQ_NUMB LIKE 'L%'
            THEN 'Newly Added Late Start'
            WHEN SSBSECT.SSBSECT_INSM_CODE = 'WEBOL'
            THEN 'LCTCS ONLINE'
            WHEN SSBSECT.SSBSECT_INSM_CODE = 'WEB'
            THEN
              CASE
              WHEN SSRMEET.SSRMEET_ROOM_CODE = 'JAONLINE'
              THEN 'LDCC MONROE'
              WHEN ssrmeet.ssrmeet_room_code = 'JHONLINE'
              THEN 'LDCC RUSTON'
              WHEN ssrmeet.ssrmeet_room_code = 'JDONLINE'
              THEN 'LDCC BASTROP'
              WHEN SSRMEET.SSRMEET_ROOM_CODE = 'JCONLINE'
              THEN 'LDCC TALLULAH'
              WHEN SSRMEET.SSRMEET_ROOM_CODE = 'JGONLINE'
              THEN 'LDCC WINNSBORO'
              WHEN SSRMEET.SSRMEET_ROOM_CODE = 'JEONLINE'
              THEN 'LDCC WEST MONROE'
              WHEN SSRMEET.SSRMEET_ROOM_CODE = 'JBONLINE'
              THEN 'LDCC LAKE PROVIDENCE'
              WHEN SSRMEET.SSRMEET_ROOM_CODE = 'JFONLINE'
              THEN 'LDCC FARMERVILLE'
              ELSE 'LDCC ONLINE'
              END
            WHEN STVCAMP.STVCAMP_DESC = 'NELTC Delta Ouachita'
            OR STVCAMP.STVCAMP_DESC   = 'LDCC West Monroe'
            THEN 'LDCC WEST MONROE'
            WHEN STVCAMP.STVCAMP_DESC = 'NELTC Northeast'
            OR STVCAMP.STVCAMP_DESC   = 'LDCC Winnsboro'
            THEN 'LDCC WINNSBORO'
            WHEN STVCAMP.STVCAMP_DESC = 'NELTC North Central'
            OR STVCAMP.STVCAMP_DESC   = 'LDCC Farmerville'
            THEN 'LDCC FARMERVILLE'
            WHEN STVCAMP.STVCAMP_DESC = 'NELTC Ruston'
            THEN 'LDCC RUSTON'
            WHEN STVCAMP.STVCAMP_DESC = 'NELTC Bastrop Airport - Ext'
            OR STVCAMP.STVCAMP_DESC   = 'LDCC Bastrop'
            OR STVCAMP.STVCAMP_DESC   = 'NELTC Bastrop'
            THEN 'LDCC BASTROP'
            WHEN SSBSECT.SSBSECT_PTRM_CODE = 'JWF'
            THEN 'LDCC WORKFORCE'
            ELSE Upper(STVCAMP.STVCAMP_DESC)
            END AS STVCAMP_DESC,
            CASE WHEN ssbsect.ssbsect_crse_TITLE is not null then ssbsect.ssbsect_crse_TITLE else scbcrse.scbcrse_title end,
            to_char(SSBSECT.SSBSECT_PTRM_START_DATE, 'MM-DD-YYYY'),
            to_char(SSBSECT.SSBSECT_PTRM_END_DATE, 'MM-DD-YYYY'),
            SSBSECT.SSBSECT_TERM_CODE,
            SSBSECT.SSBSECT_ENRL,
            Fees.Detl_Code,
            Fees.Amount,
            fees.ftyp_code,
            ((fees.sum_flat)+(fees.sum_cred*SCBCRSE.SCBCRSE_CREDIT_HR_LOW)) additional_fees,
            fees.sum_flat,
            fees.sum_cred,
            TO_CHAR(SUBSTR(d.narrative, 0)) AS narrative,
            CASE
            WHEN ssbsect.ssbsect_ptrm_code = 'JDE'
            THEN STVCAMP.STVCAMP_DESC
            ELSE SSBSECT.SSBSECT_PTRM_CODE
            END SSBSECT_PTRM_CODE,
            stvbldg.stvbldg_desc building,
            SSBSECT.SSBSECT_ENRL + SSBSECT.SSBSECT_SEATS_AVAIL as max_seats
          FROM SCBCRSE
          INNER JOIN SSBSECT
          ON SCBCRSE.SCBCRSE_SUBJ_CODE  = SSBSECT.SSBSECT_SUBJ_CODE
          AND SCBCRSE.SCBCRSE_CRSE_NUMB = SSBSECT.SSBSECT_CRSE_NUMB
          AND SSBSECT.SSBSECT_VPDI_CODE = SCBCRSE.SCBCRSE_VPDI_CODE
          LEFT JOIN
            (SELECT listagg(inst, ' | ') within GROUP (
            ORDER BY rank) INST,
              SIRASGN_CRN,
              SIRASGN_TERM_CODE,
              SIRASGN_VPDI_CODE
            FROM
              (SELECT SPRIDEN.SPRIDEN_LAST_NAME
              ||', '
              || SUBSTR(SPRIDEN.SPRIDEN_FIRST_NAME,0,1) AS INST,
              SIRASGN.SIRASGN_CRN,
              SIRASGN.SIRASGN_TERM_CODE,
              SIRASGN.SIRASGN_VPDI_CODE,
              ROW_NUMBER() OVER (ORDER BY SIRASGN.SIRASGN_PRIMARY_IND) AS rank
              FROM SPRIDEN
              INNER JOIN SIRASGN
              ON SPRIDEN.SPRIDEN_PIDM           = SIRASGN.SIRASGN_PIDM
              WHERE SPRIDEN.SPRIDEN_CHANGE_IND IS NULL
              ORDER BY 5
              )
            GROUP BY SIRASGN_CRN,
              SIRASGN_TERM_CODE,
              SIRASGN_VPDI_CODE) DerAssignSpriden ON SSBSECT.SSBSECT_CRN = DerAssignSpriden.SIRASGN_CRN
          AND SSBSECT.SSBSECT_TERM_CODE               = DerAssignSpriden.SIRASGN_TERM_CODE
          AND SCBCRSE.SCBCRSE_VPDI_CODE               = DerAssignSpriden.SIRASGN_VPDI_CODE
          INNER JOIN STVTERM
          ON SSBSECT.SSBSECT_TERM_CODE = STVTERM.STVTERM_CODE
          LEFT JOIN STVCAMP
          ON SSBSECT.SSBSECT_CAMP_CODE  = STVCAMP.STVCAMP_CODE
          AND SSBSECT.SSBSECT_VPDI_CODE = STVCAMP.STVCAMP_VPDI_CODE
          LEFT JOIN SSRMEET
          ON SSBSECT.SSBSECT_TERM_CODE  = SSRMEET.SSRMEET_TERM_CODE
          AND SSBSECT.SSBSECT_CRN       = SSRMEET.SSRMEET_CRN
          AND SSRMEET.SSRMEET_VPDI_CODE = SSBSECT.SSBSECT_VPDI_CODE
          left join stvbldg on stvbldg.stvbldg_code = ssrmeet.ssrmeet_bldg_code
          LEFT JOIN
            (SELECT Crn,
            Term,
            Vpdi,
            Listagg(Detl, ', ') Within GROUP (
            ORDER BY Detl) Detl_Code,
            Listagg(Amount, ', ') Within GROUP (
            ORDER BY Detl) Amount,
            Listagg(Ftyp, ', ') Within GROUP (
            ORDER BY Detl) ftyp_code,
            sum(flat) sum_flat,
            sum(cred) sum_cred
            FROM
            (SELECT Ssrfees.Ssrfees_Crn Crn,
              Ssrfees.Ssrfees_Term_Code Term,
              Ssrfees.Ssrfees_Vpdi_Code Vpdi,
              Ssrfees.Ssrfees_Detl_Code Detl,
              Ssrfees.Ssrfees_Amount Amount,
              Ssrfees.Ssrfees_Ftyp_Code Ftyp,
              CASE
              WHEN ssrfees.ssrfees_ftyp_code = 'FLAT' THEN ssrfees.ssrfees_amount
              ELSE 0
              END flat,
              CASE
              WHEN ssrfees.ssrfees_ftyp_code = 'CRED' THEN ssrfees.ssrfees_amount
              ELSE 0
              end cred
            FROM Ssrfees
            )
            GROUP BY crn,
            Term,
            vpdi
            ) fees
          ON fees.crn   = ssbsect.ssbsect_crn
          AND fees.term = ssbsect.ssbsect_term_code
          AND fees.vpdi = ssbsect.ssbsect_vpdi_code
          LEFT JOIN
            (  SELECT DISTINCT scbdesc.scbdesc_subj_code subj_code,
            scbdesc.scbdesc_crse_numb crse_numb,
            max(TO_CHAR(scbdesc.scbdesc_text_narrative)) keep (dense_rank last order by scbdesc.scbdesc_term_code_eff) narrative
            FROM scbdesc
            group by scbdesc.scbdesc_subj_code, scbdesc.scbdesc_crse_numb
            ) d ON d.subj_code            = ssbsect.ssbsect_subj_code
          AND d.crse_numb                 = ssbsect.ssbsect_crse_numb
          WHERE SSBSECT.SSBSECT_TERM_CODE = '{term}'
          {strTermTySQL}
          AND SCBCRSE.SCBCRSE_VPDI_CODE   = 'DELTA'
          AND (SSBSECT.SSBSECT_SUBJ_CODE || ' ' || SSBSECT.SSBSECT_CRSE_NUMB <> 'ORNT 000')
          AND SSBSECT.SSBSECT_SSTS_CODE  <> 'C'
          /* AND SSBSECT_PTRM_CODE NOT LIKE '%DE' */
          {strCampSQL}
          AND SCBCRSE.SCBCRSE_EFF_TERM =
            (SELECT MAX(SCBCRSE_EFF_TERM)
            FROM SCBCRSE DSCBCRSE
            WHERE DSCBCRSE.SCBCRSE_SUBJ_CODE = SCBCRSE.SCBCRSE_SUBJ_CODE
            AND DSCBCRSE.SCBCRSE_CRSE_NUMB   = SCBCRSE.SCBCRSE_CRSE_NUMB
            AND DSCBCRSE.SCBCRSE_VPDI_CODE   = SCBCRSE.SCBCRSE_VPDI_CODE
            )
          )
          ORDER BY
            CASE UPPER(STVCAMP_DESC)
            WHEN 'NEWLY ADDED LATE START'
            THEN 1
            WHEN 'LDCC MONROE'
            THEN 2
            WHEN 'LDCC TALLULAH'
            THEN 3
            WHEN 'LDCC LAKE PROVIDENCE'
            THEN 4
            WHEN 'LDCC WEST MONROE'
            THEN 5
            WHEN 'LDCC WEST MONROE'
            THEN 5
            WHEN 'LDCC FARMERVILLE'
            THEN 6
            WHEN 'LDCC FARMERVILLE'
            THEN 6
            WHEN 'LDCC BASTROP'
            THEN 7
            WHEN 'NELTC BASTROP'
            THEN 7
            WHEN 'LDCC WINNSBORO'
            THEN 8
            WHEN 'LDCC WINNSBORO'
            THEN 8
            WHEN 'LDCC RUSTON'
            THEN 9
            WHEN 'LDCC ONLINE'
            THEN 10
            WHEN 'LCTCS ONLINE'
            THEN 11
            when 'LDCC DUAL ENROLLMENT'
            THEN 12
            ELSE 1
            END,
            SSBSECT_SUBJ_CODE,
            SSBSECT_CRSE_NUMB,
            ssbsect_ptrm_code'''.format(**globals())

    RS = Bcur.execute(strSQL)

def main():

  if useCachedFile:
    # conditions met to use the cached data, so return that

    # print("returning cached data")

    JSONString = open(os.path.join(cacheDir, cachedFileName), "r").read()
  else:
    # conditions are NOT met to return cached data, so attempt to get fresh data

    # print("getting fresh data")

    scheduleList = []

    if RS:
      for i in RS:
        TermDesc = i[0]
        if TermDesc == None: TermDesc = ""
        CRN = i[1]
        if CRN == None: CRN = ""
        SubjectCode = i[2]
        if SubjectCode == None: SubjectCode = ""
        CourseNumber = i[3]
        if CourseNumber == None: CourseNumber = ""
        CreditHours = i[4]
        if CreditHours == None: CreditHours = ""
        Days = i[5]
        if Days == None: Days = ""
        TimeBegin = i[6]
        if TimeBegin == None: TimeBegin = ""
        TimeEnd = i[7]
        if TimeEnd == None: TimeEnd = ""
        Room = i[8]
        if Room == None: Room = ""
        TeacherName = i[9]
        if TeacherName == None: TeacherName = ""
        SeatsAvailable = i[10]
        if SeatsAvailable == None: SeatsAvailable = ""
        INSMCode = i[11]
        if INSMCode == None: INSMCode = ""
        Campus = i[12]
        if Campus == None: Campus = ""
        CourseTitle = i[13]
        if CourseTitle == None: CourseTitle = ""
        PTRMDateStart = str(i[14]).replace('00:00:00', '')
        if PTRMDateStart == None: PTRMDateStart = ""
        PTRMDateEnd = str(i[15]).replace('00:00:00', '')
        if PTRMDateEnd == None: PTRMDateEnd = ""
        Term = i[16]
        if Term == None: Term = ""
        Enrolled = i[17]
        if Enrolled == None: Enrolled = ""
        DetailCode = i[18]
        if DetailCode == None: DetailCode = ""
        Amount = i[19]
        if Amount == None: Amount = ""
        FTYPCode = i[20]
        if FTYPCode == None: FTYPCode = ""
        AdditionalFees = i[21]
        if AdditionalFees == None:
          AdditionalFees = ""
        else:
          AdditionalFees = "{:.2f}".format(float(AdditionalFees))
        FeesFlat = i[22]
        if FeesFlat == None:
          FeesFlat = ""
        else:
          FeesFlat = "{:.2f}".format(float(FeesFlat))
        FeesCred = i[23]
        if FeesCred == None:
          FeesCred = ""
        else:
          FeesCred = "{:.2f}".format(float(FeesCred))
        Narrative = i[24]
        if Narrative == None: Narrative = ""
        PTRM = i[25]
        if PTRM == None: PTRM = ""
        Building = i[26]
        if Building == None: Building = ""
        Building = Building.replace("Louisiana Purchase Bldg-Monroe", "Main Building - Monroe").replace("VOID", "").strip()
        MaxSeats = i[27]
        if MaxSeats == None: MaxSeats = ""

        scheduleList.append(
          {
          "TD": TermDesc,
          "CRN": CRN,
          "SC": SubjectCode,
          "CN": CourseNumber,
          "CH": str(int(CreditHours)),
          "D": Days,
          "TB": TimeBegin,
          "TE": TimeEnd,
          "R": Room,
          "TN": TeacherName,
          "SA": str(SeatsAvailable),
          "INSMC": INSMCode,
          "C": Campus,
          "CT": CourseTitle,
          "PTRMDS": PTRMDateStart,
          "PTRMDE": PTRMDateEnd,
          "T": Term,
          "E": str(Enrolled),
          "DC": DetailCode,
          "A": Amount,
          "FTYPC": FTYPCode,
          "AF": str(AdditionalFees),
          "FF": str(FeesFlat),
          "FC": str(FeesCred),
          "N": Narrative,
          "PTRM": PTRM,
          "B": str(Building),
          "MS": str(MaxSeats)
          }
        )

      JSONString = json.dumps(
        scheduleList,
        # sort_keys=True,
        # indent=4
        )

      # cache the data
      with open(os.path.join(cacheDir, f"{term}_{termty}.json"), "w") as cf:
        cf.write(JSONString)
    else:
      # couldn't get fresh data from banner, so try to return cached data
      JSONString = open(os.path.join(cacheDir, cachedFileName), "r").read()
    

  # import gzip
  # print('Content-type: application/octet-stream\n')
  # print('Content-encoding: gzip\n\n\')
  print("content-type: application/json")
  print('')

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
