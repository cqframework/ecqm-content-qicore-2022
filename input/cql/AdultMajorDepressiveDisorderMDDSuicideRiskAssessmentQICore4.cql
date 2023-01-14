/*
@title: Adult Major Depressive Disorder (MDD): Suicide Risk AssessmentFHIR
@identifier: CMS161FHIR
@steward: Mathematica
*/
library AdultMajorDepressiveDisorderMDDSuicideRiskAssessmentQICore4 version '0.0.004'

using QICore version '4.1.1'

include SupplementalDataElements version '3.0.000' called SDE
include QICoreCommon version '1.2.000' called QICoreCommon
include FHIRHelpers version '4.1.000' called FHIRHelpers
include CQMCommon version '1.0.000' called CQMCommon

codesystem "SNOMEDCT": 'http://snomed.info/sct' 
codesystem "LOINC": 'http://loinc.org' 

valueset "Emergency Department Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1010' 
valueset "Ethnicity": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.837' 
valueset "Major Depressive Disorder Active": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1491' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "ONC Administrative Sex": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1' 
valueset "Outpatient Consultation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1008' 
valueset "Payer": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.3591' 
valueset "Psych Visit Diagnostic Evaluation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1492' 
valueset "Psych Visit Psychotherapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1496' 
valueset "Psychoanalysis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1141' 
valueset "Race": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.836' 
valueset "Telehealth Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1031' 

// code "Birth date": '21112-8' from "LOINC" display 'Birth date'
code "Suicide risk assessment (procedure)": '225337009' from "SNOMEDCT" display 'Suicide risk assessment (procedure)'

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

define "Denominator":
  "Initial Population"

define "Initial Population":
  "New or Recurrent Major Depressive Disorder Encounter" NewOrRecurrentMDDEncounter
      where "AgeInYearsAt"(date from start of "Measurement Period")>= 17

define "New or Recurrent Major Depressive Disorder Encounter":
  "Major Depressive Disorder Encounter" NewOrRecurrentMDDEncounter
    without "Major Depressive Disorder Encounter" PriorMDDEpisodeEncounter
      such that ( PriorMDDEpisodeEncounter !~ NewOrRecurrentMDDEncounter
          and PriorMDDEpisodeEncounter.period ends 104 days or less before day of start of NewOrRecurrentMDDEncounter.period
      )
    where NewOrRecurrentMDDEncounter.period during "Measurement Period"

define "Major Depressive Disorder Encounter":
  ( ["Encounter": "Psych Visit Diagnostic Evaluation"]
    union ["Encounter": "Emergency Department Visit"]
    union ["Encounter": "Office Visit"]
    union ["Encounter": "Outpatient Consultation"]
    union ["Encounter": "Psych Visit Psychotherapy"]
    union ["Encounter": "Psychoanalysis"]
    union ["Encounter": "Telehealth Services"] ) ValidEncounter
    where ValidEncounter.status = 'finished'
      and ( ValidEncounter.reasonCode in "Major Depressive Disorder Active"
        or exists ( ( CQMCommon."EncounterDiagnosis" ( ValidEncounter ) ) EncounterDiagnosis
            where EncounterDiagnosis.code in "Major Depressive Disorder Active")
      )

define "Numerator":
  "New or Recurrent Major Depressive Disorder Encounter" NewOrRecurrentMDDEncounter
    with ["Procedure": "Suicide risk assessment (procedure)"] SuicideRiskAssessment
      such that SuicideRiskAssessment.status = 'completed'
        and QICoreCommon."ToInterval" ( SuicideRiskAssessment.performed ) during NewOrRecurrentMDDEncounter.period

