library VTEQICore4 version '8.0.000'

/*
@@Created: YH 2022-11-22  ->
Note - This library is a work in progress. THe final version for PY 2024is 2 version higher than QDM version  for 2023AU as of v7.
Issue tracker -  where AgeInYearsAt(date from start of InpatientEncounter.period) >= 18 ----->//curent problem with AgeInYearsAt required a modified approach - refer to https://github.com/cqframework/ecqm-content-qicore-2022/issues/6
*/

using QICore version '4.1.1'

//Copied from MADiE 1/13/2023
include CQMCommon version '1.0.000' called CQMCommon
include QICoreCommon version '1.2.000' called QICoreCommon
include FHIRHelpers version '4.1.000' called FHIRHelpers
include SupplementalDataElements version '3.0.000' called SDE
include TJCOverallQICore4 version '6.0.000' called TJC

valueset "Intensive Care Unit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.23'
valueset "Obstetrics": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.263' 
valueset "Obstetrics VTE": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.264'
valueset "Venous Thromboembolism": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.279' 

parameter "Measurement Period" Interval<DateTime>

context Patient

  
define "Initial Population":
"Encounter with Age Range and without VTE Diagnosis or Obstetrical Conditions"

define "Admission without VTE or Obstetrical Conditions":
  CQMCommon."Inpatient Encounter" InpatientEncounter
   where not (exists (CQMCommon.EncounterDiagnosis(InpatientEncounter)) EncDx
                 where (EncDx.code in "Obstetrics" 
                      or EncDx.code in "Venous Thromboembolism"
          							or EncDx.code in "Obstetrics VTE"
          			         )
                     )


define "Encounter with Age Range and without VTE Diagnosis or Obstetrical Conditions":
  ( CQMCommon."Inpatient Encounter" InpatientEncounter
     // where AgeInYearsAt(date from start of InpatientEncounter.period) >= 18 ----->//curent problem with AgeInYearsAt required a modified approach - refer to https://github.com/cqframework/ecqm-content-qicore-2022/issues/6
        where CalculateAgeInYearsAt(Patient.birthDate, date from start of "Measurement Period") >= 18
  )
    intersect "Admission without VTE or Obstetrical Conditions"


define function "FromDayOfStartOfHospitalizationToDayAfterAdmission"(Encounter Encounter ):
	Interval[TJC."TruncateTime" (start of CQMCommon."HospitalizationWithObservation"(Encounter)), TJC."TruncateTime" (start of Encounter.period + 2 days))

define function "StartOfFirstICU"(Encounter Encounter ):
	start of "FirstICULocationPeriod"(Encounter)

define function "FromDayOfStartOfHospitalizationToDayAfterFirstICU"(Encounter Encounter ):
	Interval[TJC."TruncateTime" (start of CQMCommon."HospitalizationWithObservation"(Encounter)), TJC."TruncateTime" (StartOfFirstICU(Encounter)+ 2 days))

define function "FirstICULocationPeriod"(Encounter Encounter ):
	"FirstInpatientIntensiveCareUnit"(Encounter).period

define function "FirstInpatientIntensiveCareUnit"(Encounter Encounter ):
	First((Encounter.location)HospitalLocation
			where CQMCommon.GetLocation(HospitalLocation.location).type in "Intensive Care Unit"
				and HospitalLocation.period during Encounter.period
			sort by start of period
	)