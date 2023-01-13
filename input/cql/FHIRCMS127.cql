library PneumococcalVaccinationStatusforOlderAdultsFHIR version '0.0.001'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include QICoreCommon version '1.2.000' called QICoreCommon
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include HospiceQICore4 version '3.0.000' called Hospice
include StatusFHIR version '1.0.0' called Status

codesystem "SNOMEDCT": 'http://snomed.info/sct' 
codesystem "CPT": 'http://www.ama-assn.org/go/cpt' 

valueset "Annual Wellness Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1240' 
valueset "Care Services in Long-Term Residential Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1014' 
valueset "Discharge Services - Nursing Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.11.1065' 
valueset "Discharged to Health Care Facility for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.207' 
valueset "Discharged to Home for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.209' 
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Nursing Facility Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1012' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Adult Pneumococcal Vaccine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1161' 
valueset "Adult Pneumococcal Vaccine Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1162' 
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025' 
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 

code "Office or other outpatient visit for the evaluation and management of an established patient, that may not require the presence of a physician or other qualified health care professional. Usually, the presenting problem(s) are minimal.": '99211' from "CPT" display 'Office or other outpatient visit for the evaluation and management of an established patient, that may not require the presence of a physician or other qualified health care professional. Usually, the presenting problem(s) are minimal.'


parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

define "Initial Population":
  AgeInYearsAt(date from start of "Measurement Period")>= 66
        and exists "Qualifying Encounters"

define "Qualifying Encounters":
  Status."Finished Encounter"(( [Encounter: "Office Visit"]
        union [Encounter: "Annual Wellness Visit"]
        union [Encounter: "Preventive Care Services - Established Office Visit, 18 and Up"]
        union [Encounter: "Preventive Care Services-Initial Office Visit, 18 and Up"]
        union [Encounter: "Home Healthcare Services"]
        union [Encounter: "Care Services in Long-Term Residential Facility"]
        union [Encounter: "Nursing Facility Visit"]
        union [Encounter: "Discharge Services - Nursing Facility"]
        union [Encounter: "Online Assessments"]
        union [Encounter: "Telephone Visits"]
        union [Encounter: "Office or other outpatient visit for the evaluation and management of an established patient, that may not require the presence of a physician or other qualified health care professional. Usually, the presenting problem(s) are minimal."] )) ValidEncounters
        where ValidEncounters.period during day of "Measurement Period"

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice Services"

define "Numerator":
  "Has Adult Pneumococcal Vaccine Administered"

define "Has Adult Pneumococcal Vaccine Administered":
  exists ( ( ( Status."Completed Immunnization"([Immunization: "Adult Pneumococcal Vaccine"])        
                union Status."Completed Procedure"(( [Procedure: "Adult Pneumococcal Vaccine Administered"]) PneumococcalProcedure
              return Immunization { occurrence: PPSV23Procedure.performed }
        ) ) PneumococcalVaccination
          where AgeInYearsAt(date from start of QICoreCommon."ToInterval"(PneumococcalVaccination.occurrence))>= 60 ) VaccinationAfter60
          where QICoreCommon."ToInterval" ( VaccinationAfter60.occurrence ) starts on or before 
          end of "Measurement Period"
      )

