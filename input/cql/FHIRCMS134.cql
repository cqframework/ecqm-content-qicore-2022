library DiabetesMedicalAttentionforNephropathyFHIR version '0.0.001'

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
include PalliativeCareQICore4 version '1.0.000' called PalliativeCare
include AdvancedIllnessandFrailtyExclusionQICore4 version '6.0.000' called AIFrailLTCF
include StatusFHIR version '1.0.0' called Status

valueset "ACE Inhibitor or ARB or ARNI": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1139' 
valueset "Annual Wellness Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1240' 
valueset "Diabetes": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.103.12.1001' 
valueset "Diabetic Nephropathy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1004' 
valueset "Dialysis Education": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1016' 
valueset "Dialysis Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1013' 
valueset "Discharged to Health Care Facility for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.207' 
valueset "Discharged to Home for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.209' 
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307' 
valueset "ESRD Monthly Outpatient Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1014' 
valueset "Glomerulonephritis and Nephrotic Syndrome": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1018' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Hospice care ambulatory": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1108.15' 
valueset "Hypertensive Chronic Kidney Disease": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1017' 
valueset "Kidney Failure": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1028' 
valueset "Kidney Transplant": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1012' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Other Services Related to Dialysis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1015' 
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025' 
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023' 
valueset "Proteinuria": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1003' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 
valueset "Urine Protein Tests": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1024' 

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
  AgeInYearsAt(date from end of "Measurement Period" ) in Interval[18, 75]
        and exists ( "Qualifying Encounters" )
        and exists (( Status."Active Condition"( [Condition: "Diabetes"]) Diabetes
        where QICoreCommon."ToPrevalenceInterval"(Diabetes) overlaps "Measurement Period")
                    )

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice Services"
    or AIFrailLTCF."Is Age 66 or Older with Advanced Illness and Frailty"
    or AIFrailLTCF."Is Age 66 or Older Living Long Term in a Nursing Home"
    or PalliativeCare."Palliative Care in the Measurement Period"

define "Numerator":
  exists ( "Active ACE or ARB Medications" )
        or exists ( "Nephropathy Diagnoses" )
        or exists ( "Nephropathy Screenings" )

define "Active ACE or ARB Medications":
  Status."Active Medication"([MedicationRequest: "ACE Inhibitor or ARB or ARNI"]) ACEorARBMedication
            and exists (ACEorARBMedication.dosageInstruction.timing T
                where T.repeat.bounds as Period overlaps "Measurement Period")

define "Nephropathy Diagnoses":
( Status."Active Condition"([Diagnosis: "Hypertensive Chronic Kidney Disease"]
  union [Diagnosis: "Kidney Failure"]
  union [Diagnosis: "Glomerulonephritis and Nephrotic Syndrome"]
  union [Diagnosis: "Diabetic Nephropathy"]
  union [Diagnosis: "Proteinuria"] ) NephropathyDiagnoses
  where QICoreCommon."ToPrevalenceInterval"(NephropathyDiagnoses)) overlaps "Measurement Period"

define "Nephropathy Screenings":
(( "Renal Procedures"
    union "Renal Interventions") ScreeningNephropathy
          where QICoreCommon."ToInterval"(ScreeningNephropathy.performed) during day of "Measurement Period"
                )
      union ( "Protein Urea Lab Test" ProteinUreaLabTest
          where QICoreCommon."ToInterval"(ProteinUreaLabTest.effective) during day of "Measurement Period"
                )
      union ( "End Stage Renal Disease Encounter" ESRDEncounter
          where QICoreCommon."ToInterval"(ESRDEncounter.period) during day of "Measurement Period"
                )
      
define "End Stage Renal Disease Encounter":
  Status."Finished Encounter"([Encounter: "ESRD Monthly Outpatient Services"]) 

define "Protein Urea Lab Test":
  Status."Final Lab Observation"([Observation: "Urine Protein Tests"]) ProteinUreaResult
        where ProteinUreaResult.value is not null

define "Renal Interventions":
  Status."Completed Procedure"([Procedure: "Other Services Related to Dialysis"]
                      union [Procedure: "Dialysis Education"]) 

define "Renal Procedures":
  Status."Completed Procedure"( [Procedure: "Kidney Transplant"]
                      union [Procedure: "Dialysis Services"]) 

