library ChildandAdolescentMajorDepressiveDisorderMDDSuicideRiskAssessmentFHIR version '0.0.003'

using QICore version '4.1.1'

/*This spec aligns with AU2022/PY2023 QDM version*/


include SupplementalDataElements version '3.1.000' called SDE
include QICoreCommon version '1.2.000' called QICoreCommon
include FHIRHelpers version '4.1.000' called FHIRHelpers
include FHIRCommon version '4.1.000' called FHIRCommon
include CQMCommon version '1.0.000' called CQMCommon

codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMEDCT": 'http://snomed.info/sct'
codesystem "ActCode": 'http://terminology.hl7.org/CodeSystem/v3-ActCode'

valueset "Group Psychotherapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1187'
valueset "Major Depressive Disorder Active": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1491'
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Outpatient Consultation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1008'
valueset "Psych Visit Diagnostic Evaluation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1492'
valueset "Psych Visit for Family Psychotherapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1018'
valueset "Psych Visit Psychotherapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1496'
valueset "Psychoanalysis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1141'
valueset "Telehealth Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1031'

code "Birth date": '21112-8' from "LOINC" display 'Birth date'
code "Suicide risk assessment (procedure)": '225337009' from "SNOMEDCT" display 'Suicide risk assessment (procedure)'
code "AMB": 'AMB' from "ActCode" display 'Ambulatory'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
  "Major Depressive Disorder Encounter" MDDEncounter
    where ( "AgeInYearsAt"(date from start of "Measurement Period") >= 6
        and "AgeInYearsAt"(date from start of "Measurement Period") < 17
    )

define "Denominator":
  "Initial Population"

define "Numerator":
  "Major Depressive Disorder Encounter" MDDEncounter
    with ["Procedure": "Suicide risk assessment (procedure)"] SuicideRiskAssessment
      such that SuicideRiskAssessment.status = 'completed'
        and QICoreCommon."ToInterval" ( SuicideRiskAssessment.performed ) during MDDEncounter.period

define "Major Depressive Disorder Encounter":
  ( ["Encounter": "Office Visit"]
    union ["Encounter": "Outpatient Consultation"]
    union ["Encounter": "Psych Visit Diagnostic Evaluation"]
    union ["Encounter": "Psych Visit for Family Psychotherapy"]
    union ["Encounter": "Psych Visit Psychotherapy"]
    union ["Encounter": "Psychoanalysis"]
    union ["Encounter": "Group Psychotherapy"]
    union ["Encounter": "Telehealth Services"] ) ValidEncounter
    where ValidEncounter.status = 'finished'
      and ValidEncounter.class ~ "AMB"
      and ( ValidEncounter.reasonCode in "Major Depressive Disorder Active"
          or exists ( ( CQMCommon."EncounterDiagnosis" ( ValidEncounter ) ) EncounterDiagnosis
              where EncounterDiagnosis.code in "Major Depressive Disorder Active"
          )
      )
      and ValidEncounter.period during "Measurement Period"

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"