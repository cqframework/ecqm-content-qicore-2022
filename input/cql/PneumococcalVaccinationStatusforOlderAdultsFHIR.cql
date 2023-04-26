library PneumococcalVaccinationStatusforOlderAdultsFHIR version '0.0.000'

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include CQMCommon version '1.0.000' called CQMCommon
include SupplementalDataElements version '3.1.000' called SDE
include QICoreCommon version '1.2.000' called QICoreCommon
include Hospice version '6.1.000' called Hospice
include Status version '1.1.000' called Status

codesystem "CPT": 'http://www.ama-assn.org/go/cpt'

valueset "Adult Pneumococcal Vaccine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1161'
valueset "Adult Pneumococcal Vaccine Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1162'
valueset "Annual Wellness Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1240'
valueset "Care Services in Long Term Residential Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1014'
valueset "Discharge Services Nursing Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1013'
valueset "Discharged to Health Care Facility for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.207'
valueset "Discharged to Home for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.209'
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016'
valueset "Hospice Care Ambulatory": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1108.15'
valueset "Nursing Facility Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1012'
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089'
valueset "Preventive Care Services Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080'

code "Office or other outpatient visit for the evaluation and management of an established patient, that may not require the presence of a physician or other qualified health care professional. Usually, the presenting problem(s) are minimal.": '99211' from "CPT" display 'Office or other outpatient visit for the evaluation and management of an established patient, that may not require the presence of a physician or other qualified health care professional. Usually, the presenting problem(s) are minimal.'

parameter "Measurement Period" Interval<DateTime>
default Interval[@2023-01-01T00:00:00.000Z, @2024-01-01T00:00:00.000Z)

context Patient

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice Services"

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

define "Numerator":
  "Has Adult Pneumococcal Vaccine Administered"

define "Initial Population":
  AgeInYearsAt(date from start of "Measurement Period") >= 66
    and exists ( "Qualifying Encounters" )

define "Qualifying Encounters":
  ( ["Encounter": "Office Visit"]
    union ["Encounter": "Annual Wellness Visit"]
    union ["Encounter": "Preventive Care Services Established Office Visit, 18 and Up"]
    union ["Encounter": "Preventive Care Services Initial Office Visit, 18 and Up"]
    union ["Encounter": "Home Healthcare Services"]
    union ["Encounter": "Care Services in Long Term Residential Facility"]
    union ["Encounter": "Nursing Facility Visit"]
    union ["Encounter": "Discharge Services Nursing Facility"]
    union ["Encounter": "Online Assessments"]
    union ["Encounter": "Telephone Visits"]
        // union ["Encounter": "Office or other outpatient visit for the evaluation and management of an established patient, that may not require the presence of a physician or other qualified health care professional. Usually, the presenting problem(s) are minimal."]
  ) ValidEncounters
    where QICoreCommon."ToInterval" ( ValidEncounters.period ) during day of "Measurement Period"

define "Has Adult Pneumococcal Vaccine Administered":
  exists ( ( ( Status."Completed Immunization" ( [Immunization: "Adult Pneumococcal Vaccine"] ) ) AdultPneumococcalVaccination
        where AgeInYearsAt(date from start of QICoreCommon."ToInterval"(AdultPneumococcalVaccination.occurrence)) >= 60
          and QICoreCommon."ToInterval" ( AdultPneumococcalVaccination.occurrence ) starts on or before end of "Measurement Period"
    )
      union ( ( Status."Completed Procedure" ( [Procedure: "Adult Pneumococcal Vaccine Administered"] ) ) PneumococcalProcedure
          where AgeInYearsAt(date from start of QICoreCommon."ToInterval"(PneumococcalProcedure.performed)) >= 60
            and QICoreCommon."ToInterval" ( PneumococcalProcedure.performed ) starts on or before end of "Measurement Period"
      )
  )