library EXM135v11QICore4 version '11.1.000'

using QICore version '4.1.1'

include FHIRHelpers version '4.0.012' called FHIRHelpers
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include QICoreCommon version '1.0.000' called Common
include AHAOverallQICore4 version '1.0.000' called AHA

codesystem "SNOMEDCT": 'http://snomed.info/sct' 
codesystem "RXNORM": 'http://www.nlm.nih.gov/research/umls/rxnorm' 

valueset "ACE Inhibitor or ARB Ingredient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1489' 
valueset "ACE Inhibitor or ARB or ARNI": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1139' 
valueset "Allergy to ACE Inhibitor or ARB": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1211' 
valueset "Intolerance to ACE Inhibitor or ARB": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1212' 
valueset "Medical Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1007' 
valueset "Patient Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1008' 
valueset "Patient Reason for ACE Inhibitor or ARB Decline": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1140' 
valueset "Pregnancy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.378' 

code "Acute renal failure caused by angiotensin-converting-enzyme inhibitor (disorder)": '422593004' from "SNOMEDCT" display 'Acute renal failure caused by angiotensin-converting-enzyme inhibitor (disorder)'
code "sacubitril": '1656328' from "RXNORM" display 'sacubitril'
code "Substance with angiotensin II receptor antagonist mechanism of action (substance)": '372913009' from "SNOMEDCT" display 'Substance with angiotensin II receptor antagonist mechanism of action (substance)'
code "Substance with angiotensin-converting enzyme inhibitor mechanism of action (substance)": '372733002' from "SNOMEDCT" display 'Substance with angiotensin-converting enzyme inhibitor mechanism of action (substance)'
code "Substance with neprilysin inhibitor mechanism of action (substance)": '786886009' from "SNOMEDCT" display 'Substance with neprilysin inhibitor mechanism of action (substance)'

parameter "Measurement Period" default Interval[@2022-01-01, @2022-12-31]

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
  //curent problem with AgeInYearsAt required a modified approach - refer to https://github.com/cqframework/ecqm-content-qicore-2022/issues/6
  CalculateAgeInYearsAt(Patient.birthDate, date from start of "Measurement Period") >= 18
    and Count(AHA."Qualifying Encounter During Measurement Period") >= 2
    and exists AHA."Heart Failure Outpatient Encounter"

define "Denominator":
  "Initial Population"
    and exists AHA."Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD"

define "Denominator Exclusions":
  AHA."Has Heart Transplant"
    or AHA."Has Heart Transplant Related Diagnosis"
    or AHA."Has Left Ventricular Assist Device"
    or AHA."Has Left Ventricular Assist Device Related Diagnosis"

define "Numerator":
  "Has ACEI or ARB or ARNI Ordered"
    or "Is Currently Taking ACEI or ARB or ARNI"

define "Denominator Exceptions":
  "Has Medical or Patient Reason for Not Ordering ACEI or ARB or ARNI"
    or "Has Allergy or Intolerance to ACEI or ARB or ARNI Ingredient"
    or "Has Diagnosis of Allergy or Intolerance to ACEI or ARB"
    or "Has Diagnosis of Pregnancy"
    or "Has Diagnosis of Renal Failure Due to ACEI"

define "Has Medical or Patient Reason for Not Ordering ACEI or ARB or ARNI":
  exists (
          ["MedicationNotRequested"] NoACEIOrARBOrARNIOrdered
            with AHA."Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
              such that NoACEIOrARBOrARNIOrdered.authoredOn during ModerateOrSevereLVSDHFOutpatientEncounter.period
            where NoACEIOrARBOrARNIOrdered.medication in "ACE Inhibitor or ARB or ARNI"
              and ( NoACEIOrARBOrARNIOrdered.reasonCode in "Medical Reason"
                or NoACEIOrARBOrARNIOrdered.reasonCode in "Patient Reason"
                or NoACEIOrARBOrARNIOrdered.reasonCode in "Patient Reason for ACE Inhibitor or ARB Decline" )
          )

define "Has Allergy or Intolerance to ACEI or ARB or ARNI Ingredient":
  exists (
          ( ["AllergyIntolerance": "ACE Inhibitor or ARB Ingredient"]
              union ["AllergyIntolerance": "Substance with angiotensin-converting enzyme inhibitor mechanism of action (substance)"]
              union ["AllergyIntolerance": "Substance with angiotensin II receptor antagonist mechanism of action (substance)"]
              union ["AllergyIntolerance": "Substance with neprilysin inhibitor mechanism of action (substance)"]
              union ["AllergyIntolerance": "sacubitril"] ) ACEIOrARBOrARNIAllergyIntolerance
            with AHA."Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
              such that (ACEIOrARBOrARNIAllergyIntolerance.onset.toInterval() starts before end of ModerateOrSevereLVSDHFOutpatientEncounter.period
                and (ACEIOrARBOrARNIAllergyIntolerance.resolutionAge.toInterval() ends after end of ModerateOrSevereLVSDHFOutpatientEncounter.period
                  or ACEIOrARBOrARNIAllergyIntolerance.resolutionAge is null ) )
            where ACEIOrARBOrARNIAllergyIntolerance.clinicalStatus ~ Common."allergy-active"
              and ACEIOrARBOrARNIAllergyIntolerance.verificationStatus ~ Common."allergy-confirmed"
          )

define "Has Diagnosis of Allergy or Intolerance to ACEI or ARB":
  exists (
            ( ["Condition": "Allergy to ACE Inhibitor or ARB"]
                union ["Condition": "Intolerance to ACE Inhibitor or ARB"] ) ACEIOrARBAllergyOrIntoleranceDiagnosis
              where ACEIOrARBAllergyOrIntoleranceDiagnosis.overlapsAfterHeartFailureOutpatientEncounter()
          )

define "Has ACEI or ARB or ARNI Ordered":
  exists ( 
            ["MedicationRequest": "ACE Inhibitor or ARB or ARNI"] ACEIOrARBOrARNI
              where ACEIOrARBOrARNI.isOrderedDuringHeartFailureOutpatientEncounter()
          )

define "Has Diagnosis of Pregnancy":
  exists ( 
            ["Condition": "Pregnancy"] Pregnancy
              with AHA."Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
                such that Pregnancy.toPrevalenceInterval() starts 9 months or less before or on start ModerateOrSevereLVSDHFOutpatientEncounter.period
              where Pregnancy.isConfirmedActiveDiagnosis()
          )

define "Is Currently Taking ACEI or ARB or ARNI":
  exists ( 
            ["MedicationRequest": "ACE Inhibitor or ARB or ARNI"] ActiveACEIOrARBOrARNI
              where ActiveACEIOrARBOrARNI.overlapsAfterHeartFailureOutpatientEncounter()         
          )

define "Has Diagnosis of Renal Failure Due to ACEI":
  exists (
            ["Condition": "Acute renal failure caused by angiotensin-converting-enzyme inhibitor (disorder)"] RenalFailureDueToACEI
              where RenalFailureDueToACEI.overlapsHeartFailureOutpatientEncounter()
            )