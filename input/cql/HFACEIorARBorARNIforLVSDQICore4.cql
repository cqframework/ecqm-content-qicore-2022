library HFACEIorARBorARNIforLVSDQICore4 version '1.0.000'

using QICore version '4.1.1'

include FHIRHelpers version '4.0.012' called FHIRHelpers
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include QICoreCommon version '1.0.000' called Common

codesystem "SNOMEDCT": 'http://snomed.info/sct' 
codesystem "RXNORM": 'http://www.nlm.nih.gov/research/umls/rxnorm' 

valueset "ACE Inhibitor or ARB Ingredient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1489' 
valueset "ACE Inhibitor or ARB or ARNI": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1139' 
valueset "Allergy to ACE Inhibitor or ARB": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1211' 
valueset "Care Services in Long Term Residential Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1014' 
valueset "Discharge Services Hospital Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1007' 
valueset "Ejection Fraction": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1134' 
valueset "Face-to-Face Interaction": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1048' 
valueset "Heart Failure": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.376' 
valueset "Heart Transplant": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1178.33' 
valueset "Heart Transplant Related Diagnoses": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1178.56' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Intolerance to ACE Inhibitor or ARB": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1212' 
valueset "Left Ventricular Assist Device Placement": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1178.61' 
valueset "Left Ventricular Assist Device Related Diagnoses": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1178.58' 
valueset "Medical Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1007' 
valueset "Moderate or Severe": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1092' 
valueset "Moderate or Severe LVSD": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1090' 
valueset "Nursing Facility Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1012' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Outpatient Consultation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1008' 
valueset "Patient Provider Interaction": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1012' 
valueset "Patient Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1008' 
valueset "Patient Reason for ACE Inhibitor or ARB Decline": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1140' 
valueset "Pregnancy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.378' 
valueset "System Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1009' 

code "Acute renal failure caused by angiotensin-converting-enzyme inhibitor (disorder)": '422593004' from "SNOMEDCT" display 'Acute renal failure caused by angiotensin-converting-enzyme inhibitor (disorder)'
code "Left ventricular systolic dysfunction (disorder)": '134401001' from "SNOMEDCT" display 'Left ventricular systolic dysfunction (disorder)'
code "sacubitril": '1656328' from "RXNORM" display 'sacubitril'
code "Substance with angiotensin II receptor antagonist mechanism of action (substance)": '372913009' from "SNOMEDCT" display 'Substance with angiotensin II receptor antagonist mechanism of action (substance)'
code "Substance with angiotensin-converting enzyme inhibitor mechanism of action (substance)": '372733002' from "SNOMEDCT" display 'Substance with angiotensin-converting enzyme inhibitor mechanism of action (substance)'
code "Substance with neprilysin inhibitor mechanism of action (substance)": '786886009' from "SNOMEDCT" display 'Substance with neprilysin inhibitor mechanism of action (substance)'

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
  AgeInYearsAt(date from start of "Measurement Period") >= 18
    and Count("Qualifying Encounter During Measurement Period") >= 2
    and exists "Heart Failure Outpatient Encounter"

define "Denominator":
  "Initial Population"
    and exists "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD"

define "Denominator Exclusions":
  "Has Heart Transplant"
    or "Has Heart Transplant Related Diagnosis"
    or "Has Left Ventricular Assist Device"
    or "Has Left Ventricular Assist Device Related Diagnosis"

define "Numerator":
  "Has ACEI or ARB or ARNI Ordered"
    or "Is Currently Taking ACEI or ARB or ARNI"

define "Denominator Exceptions":
  "Has Medical or Patient Reason for Not Ordering ACEI or ARB or ARNI"
    or "Has Allergy or Intolerance to ACEI or ARB or ARNI Ingredient"
    or "Has Diagnosis of Allergy or Intolerance to ACEI or ARB"
    or "Has Diagnosis of Pregnancy"
    or "Has Diagnosis of Renal Failure Due to ACEI"

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

define "Qualifying Encounter During Measurement Period":
  ( ["Encounter": "Office Visit"]
      union ["Encounter": "Outpatient Consultation"]
      union ["Encounter": "Nursing Facility Visit"]
      union ["Encounter": "Care Services in Long Term Residential Facility"]
      union ["Encounter": "Home Healthcare Services"]
      union ["Encounter": "Patient Provider Interaction"] ) ValidEncounter
    where ValidEncounter.period during "Measurement Period"
      and ValidEncounter.isFinished()

define "Moderate or Severe LVSD Findings":
  ( ["Observation": "Ejection Fraction"] EjectionFraction
      where EjectionFraction.value <= 40 '%'
      and EjectionFraction.status in {'final', 'amended', 'corrected'}
    )
  union ( 
    ( ["Condition": "Moderate or Severe LVSD"]
        union ( ["Condition": "Left ventricular systolic dysfunction (disorder)"] LeftVentricular
                  where LeftVentricular.severity in "Moderate or Severe"
                )
      ) LVSD
      where LVSD.isConfirmedActiveDiagnosis()
    )

define "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD":
  "Heart Failure Outpatient Encounter" HFOutpatientEncounter
    with "Moderate or Severe LVSD Findings" LVSDFindings
      such that Coalesce(LVSDFindings.onset.toInterval(), LVSDFindings.effective.toInterval()) starts before end of HFOutpatientEncounter.period

define "Has Left Ventricular Assist Device Related Diagnosis":
  exists (
            ["Condition": "Left Ventricular Assist Device Related Diagnoses"] LVADCondition
              with "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
                such that LVADCondition.toPrevalenceInterval() starts before end of ModerateOrSevereLVSDHFOutpatientEncounter.period  
              where LVADCondition.isConfirmedActiveDiagnosis()
          )

define "Has Medical or Patient Reason for Not Ordering ACEI or ARB or ARNI":
  exists (
          ["MedicationRequest": "ACE Inhibitor or ARB or ARNI"] NoACEIOrARBOrARNIOrdered
            with "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
              such that NoACEIOrARBOrARNIOrdered.authoredOn during ModerateOrSevereLVSDHFOutpatientEncounter.period
            where NoACEIOrARBOrARNIOrdered.status = 'completed' 
              and NoACEIOrARBOrARNIOrdered.doNotPerform is true 
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
              with "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
                such that ACEIOrARBOrARNIAllergyIntolerance.onset.toInterval() overlaps after ModerateOrSevereLVSDHFOutpatientEncounter.period
              where ACEIOrARBOrARNIAllergyIntolerance.clinicalStatus ~ Common."allergy-active"
                and ACEIOrARBOrARNIAllergyIntolerance.verificationStatus ~ Common."confirmed"
          )

define "Has Diagnosis of Allergy or Intolerance to ACEI or ARB":
  exists (
            ( ["Condition": "Allergy to ACE Inhibitor or ARB"]
                union ["Condition": "Intolerance to ACE Inhibitor or ARB"] ) ACEIOrARBAllergyOrIntoleranceDiagnosis
              with "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
                such that ACEIOrARBAllergyOrIntoleranceDiagnosis.toPrevalenceInterval() overlaps after ModerateOrSevereLVSDHFOutpatientEncounter.period
              where ACEIOrARBAllergyOrIntoleranceDiagnosis.isConfirmedActiveDiagnosis()
          )

define "Has Left Ventricular Assist Device":
  exists (
            ["Procedure": "Left Ventricular Assist Device Placement"] LVADOutpatient
              with "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
                such that LVADOutpatient.performed.toInterval() starts before end of ModerateOrSevereLVSDHFOutpatientEncounter.period
              where LVADOutpatient.status = 'completed'
            )

define "Has ACEI or ARB or ARNI Ordered":
  exists ( 
            ["MedicationRequest": "ACE Inhibitor or ARB or ARNI"] ACEIOrARBOrARNIOrdered
              with "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
                such that ACEIOrARBOrARNIOrdered.authoredOn during ModerateOrSevereLVSDHFOutpatientEncounter.period
              where ACEIOrARBOrARNIOrdered.status in {'active', 'completed'}
                and ACEIOrARBOrARNIOrdered.intent = 'order'
            )

define "Has Diagnosis of Pregnancy":
  exists ( 
          ["Condition": "Pregnancy"] Pregnancy
            with "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
              such that Pregnancy.toPrevalenceInterval() starts 9 months or less before or on start ModerateOrSevereLVSDHFOutpatientEncounter.period
            where Pregnancy.isConfirmedActiveDiagnosis()
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

define "Is Currently Taking ACEI or ARB or ARNI":
  exists ( 
          ["MedicationRequest": "ACE Inhibitor or ARB or ARNI"] ActiveACEIOrARBOrARNI
            with "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
              such that exists ( ActiveACEIOrARBOrARNI.dosageInstruction.timing T
                                  where T.repeat.bounds.toInterval() overlaps after ModerateOrSevereLVSDHFOutpatientEncounter.period )
            where ActiveACEIOrARBOrARNI.status in { 'active', 'completed', 'finished' }            
            )

define "Face to Face Encounter During Measurement Period":
  ( ["Encounter": "Care Services in Long Term Residential Facility"]
      union ["Encounter": "Home Healthcare Services"]
      union ["Encounter": "Nursing Facility Visit"]
      union ["Encounter": "Office Visit"]
      union ["Encounter": "Outpatient Consultation"] ) FaceToFaceEncounter
    where FaceToFaceEncounter.period during "Measurement Period"
        and FaceToFaceEncounter.isFinished()

define "Has Diagnosis of Renal Failure Due to ACEI":
  exists (
            ["Condition": "Acute renal failure caused by angiotensin-converting-enzyme inhibitor (disorder)"] RenalFailureDueToACEI
              with "Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
                such that RenalFailureDueToACEI.toPrevalenceInterval() overlaps ModerateOrSevereLVSDHFOutpatientEncounter.period
              where RenalFailureDueToACEI.isConfirmedActiveDiagnosis()
            )

define fluent function isConfirmedActiveDiagnosis(Diagnosis Condition):
  ( Diagnosis Dx
    where Dx.clinicalStatus ~ Common."active"
        and Dx.verificationStatus ~ Common."confirmed" ) is not null
        
define fluent function isFinished(Visit Encounter):
  (Visit encounter
    where encounter.status = 'finished') is not null