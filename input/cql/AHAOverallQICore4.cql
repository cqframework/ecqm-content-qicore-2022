library AHAOverallQICore4 version '1.0.000'

using QICore version '4.1.1'

include FHIRHelpers version '4.0.012' called FHIRHelpers
include QICoreCommon version '1.0.000' called Common

codesystem "SNOMEDCT": 'http://snomed.info/sct' 

valueset "Care Services in Long Term Residential Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1014' 
valueset "Ejection Fraction": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1134' 
valueset "Heart Failure": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.376'
valueset "Heart Transplant": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1178.33' 
valueset "Heart Transplant Related Diagnoses": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1178.56' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Left Ventricular Assist Device Placement": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1178.61' 
valueset "Left Ventricular Assist Device Related Diagnoses": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1178.58' 
valueset "Moderate or Severe": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1092' 
valueset "Moderate or Severe LVSD": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1090' 
valueset "Nursing Facility Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1012' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Outpatient Consultation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1008' 
valueset "Patient Provider Interaction": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1012' 

code "Left ventricular systolic dysfunction (disorder)": '134401001' from "SNOMEDCT" display 'Left ventricular systolic dysfunction (disorder)'

parameter "Measurement Period" default Interval[@2022-01-01, @2022-12-31]

context Patient

define "Qualifying Encounter During Measurement Period":
  ( ["Encounter": "Care Services in Long Term Residential Facility"]
                    union ["Encounter": "Home Healthcare Services"]
                    union ["Encounter": "Nursing Facility Visit"]
                    union ["Encounter": "Office Visit"]
                    union ["Encounter": "Outpatient Consultation"]
                    union ["Encounter": "Patient Provider Interaction"] ) ValidEncounter
                    where ValidEncounter.period during "Measurement Period"
                      and ValidEncounter.isFinished()

define "Heart Failure Outpatient Encounter":
  ( ["Encounter": "Care Services in Long Term Residential Facility"]
      union ["Encounter": "Home Healthcare Services"]
      union ["Encounter": "Nursing Facility Visit"]
      union ["Encounter": "Office Visit"]
      union ["Encounter": "Outpatient Consultation"] ) QualifyingEncounter
    with ["Condition": "Heart Failure"] HeartFailure
      such that HeartFailure.toPrevalenceInterval() overlaps QualifyingEncounter.period  
        and HeartFailure.isConfirmedActiveDiagnosis()
    where QualifyingEncounter.period during "Measurement Period"
      and QualifyingEncounter.isFinished()

define "Moderate or Severe LVSD Observations":
  ["Observation": "Ejection Fraction"] EjectionFraction
    where EjectionFraction.value <= 40 '%'
      and EjectionFraction.status in {'final', 'amended', 'corrected'}

define "Moderate or Severe LVSD Conditions":
  ( ["Condition": "Moderate or Severe LVSD"]
      union ( ["Condition": "Left ventricular systolic dysfunction (disorder)"] LeftVentricular
                where LeftVentricular.severity in "Moderate or Severe"
              )
    ) LVSD
    where LVSD.isConfirmedActiveDiagnosis() 

// define "Moderate or Severe LVSD Findings":
//   ( ["Observation": "Ejection Fraction"] EjectionFraction
//       where EjectionFraction.value <= 40 '%'
//         and EjectionFraction.status in {'final', 'amended', 'corrected'}
//     )
//   union ( 
//     ( ["Condition": "Moderate or Severe LVSD"]
//         union ( ["Condition": "Left ventricular systolic dysfunction (disorder)"] LeftVentricular
//                   where LeftVentricular.severity in "Moderate or Severe"
//                 )
//       ) LVSD
//       where LVSD.isConfirmedActiveDiagnosis()
//     )

//Execution had issues with returning the expected data when Observation and Condition 
//were joined with a union so made two separate definitions

define "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD":
  ( "Heart Failure Outpatient Encounter" HFOutpatientEncounter
      with "Moderate or Severe LVSD Observations" LVSDObservations
        such that LVSDObservations.effective.toInterval() starts before end of HFOutpatientEncounter.period )
  union (
    "Heart Failure Outpatient Encounter" HFOutpatientEncounter
      with "Moderate or Severe LVSD Conditions" LVSDConditions
        such that LVSDConditions.onset.toInterval() starts before end of HFOutpatientEncounter.period
  )

define "Has Left Ventricular Assist Device Related Diagnosis":
  exists (
            ["Condition": "Left Ventricular Assist Device Related Diagnoses"] LVADCondition
              with "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
                such that LVADCondition.toPrevalenceInterval() starts before end of ModerateOrSevereLVSDHFOutpatientEncounter.period  
              where LVADCondition.isConfirmedActiveDiagnosis()
          )

define "Has Left Ventricular Assist Device":
  exists (
            ["Procedure": "Left Ventricular Assist Device Placement"] LVADOutpatient
              with "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
                such that LVADOutpatient.performed.toInterval() starts before end of ModerateOrSevereLVSDHFOutpatientEncounter.period
              where LVADOutpatient.status = 'completed'
            )

define "Has Heart Transplant":
  exists (
          ["Procedure": "Heart Transplant"] HeartTransplant
            with "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
              such that HeartTransplant.performed.toInterval() starts before end of ModerateOrSevereLVSDHFOutpatientEncounter.period
            where HeartTransplant.status = 'completed'
          )

define "Has Heart Transplant Related Diagnosis":
  exists ( 
          ["Condition": "Heart Transplant Related Diagnoses"] HeartTransplantCondition
            with "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
              such that HeartTransplantCondition.toPrevalenceInterval() starts before end of ModerateOrSevereLVSDHFOutpatientEncounter.period
            where HeartTransplantCondition.isConfirmedActiveDiagnosis()
          )

define fluent function isConfirmedActiveDiagnosis(Diagnosis Condition):
  ( Diagnosis Dx
    where Dx.clinicalStatus ~ Common."active"
        and Dx.verificationStatus ~ Common."confirmed" ) is not null
        
define fluent function isFinished(Visit Encounter):
  (Visit encounter
    where encounter.status = 'finished') is not null