library BreastCancerScreeningFHIR version '0.0.001'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include QICoreCommon version '1.2.000' called QICoreCommon
include CQMCommon version '1.0.000' called CQMCommon
include SupplementalDataElements version '3.0.000' called SDE
include StatusFHIR version '1.0.0' called Status
include AdultOutpatientEncountersQICore4 version '3.0.000' called AdultOutpatientEncounter
include AdvancedIllnessandFrailtyExclusionQICore4 version '6.0.000' called AIFrailLTCF
include HospiceQICore4 version '3.0.000' called Hospice
include PalliativeCareQICore4 version '1.0.000' called PalliativeCare

codesystem "AdministrativeGender": 'http://terminology.hl7.org/CodeSystem/v3-AdministrativeGender' 
codesystem "SNOMEDCT": 'http://snomed.info/sct' 

valueset "Bilateral Mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1005' 
valueset "History of bilateral mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1068' 
valueset "Mammography": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018' 
valueset "Outpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1087' 
valueset "Status Post Left Mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1069' 
valueset "Status Post Right Mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1070' 
valueset "Unilateral Mastectomy Left": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1133' 
valueset "Unilateral Mastectomy Right": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1134' 
valueset "Unilateral Mastectomy, Unspecified Laterality": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1071' 

code "Female": 'F' from "AdministrativeGender" display 'Female'
code "Left (qualifier value)": '7771000' from "SNOMEDCT" display 'Left (qualifier value)'
code "Right (qualifier value)": '24028007' from "SNOMEDCT" display 'Right (qualifier value)'

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

define "Bilateral Mastectomy Diagnosis":
  ["Condition": "History of bilateral mastectomy"] BilateralMastectomyHistory
      where QICoreCommon."ToPrevalenceInterval"(BilateralMastectomyHistory) starts on or before
      end of "Measurement Period"

define "Bilateral Mastectomy Procedure":
  (Status."Completed Procedure"(["Procedure": "Bilateral Mastectomy"])) BilateralMastectomyPerformed
      where QICoreCommon."ToInterval" ( BilateralMastectomyPerformed.performed) ends on or before 
      end of "Measurement Period"

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice Services"
      or ( ( exists ( "Right Mastectomy Diagnosis" )
            or exists ( "Right Mastectomy Procedure" )
        )
          and ( exists ( "Left Mastectomy Diagnosis" )
              or exists ( "Left Mastectomy Procedure" )
          )
      )
      or exists "Bilateral Mastectomy Diagnosis"
      or exists "Bilateral Mastectomy Procedure"
      or AIFrailLTCF."Is Age 66 or Older with Advanced Illness and Frailty"
      or AIFrailLTCF."Is Age 66 or Older Living Long Term in a Nursing Home"
      or PalliativeCare."Palliative Care in the Measurement Period"

define "Left Mastectomy Diagnosis":
  ( ["Condition": "Status Post Left Mastectomy"]
      union ( ["Condition": "Unilateral Mastectomy, Unspecified Laterality"] UnilateralMastectomyDiagnosis
          // NOTE: This should be a ~contains, but until that operator is defined, reverse it to use an in
          where "Left (qualifier value)" in UnilateralMastectomyDiagnosis.bodySite 
      ) ) LeftMastectomy
      where QICoreCommon."ToPrevalenceInterval"(LeftMastectomy) starts on or before 
      end of "Measurement Period"

define "Left Mastectomy Procedure":
  (Status."Completed Procedure"(["Procedure": "Unilateral Mastectomy Left"])) UnilateralMastectomyLeftPerformed
      where QICoreCommon."ToInterval" ( UnilateralMastectomyLeftPerformed.performed ) ends on or before 
      end of "Measurement Period"

define "Right Mastectomy Diagnosis":
  ( ["Condition": "Status Post Right Mastectomy"] RightMastectomyProcedure
      union ( ["Condition": "Unilateral Mastectomy, Unspecified Laterality"] UnilateralMastectomyDiagnosis
        // NOTE: This should be a ~contains, but until that operator is defined, reverse it to use an in
          where "Right (qualifier value)" in UnilateralMastectomyDiagnosis.bodySite 
      ) ) RightMastectomy
      where QICoreCommon."ToPrevalenceInterval"(RightMastectomy) starts on or before 
      end of "Measurement Period"

define "Right Mastectomy Procedure":
  (Status."Completed Procedure"(["Procedure": "Unilateral Mastectomy Right"])) UnilateralMastectomyRightPerformed
      where QICoreCommon."ToInterval" ( UnilateralMastectomyRightPerformed.performed) ends on or before 
      end of "Measurement Period"

define "Initial Population":
 AgeInYearsAt(date from 
        end of "Measurement Period"
      )in Interval[52, 74]
      and Patient.gender = 'female'
      and exists AdultOutpatientEncounter."Qualifying Encounters"
  
define "Numerator":
  exists ( (Status."Final Observation"(["Observation": "Mammography"])) Mammogram
        where ( QICoreCommon."ToInterval" ( Mammogram.effective) ends during day of Interval["October 1 Two Years Prior to the Measurement Period", 
          end of "Measurement Period"]
        )
    )

define "October 1 Two Years Prior to the Measurement Period":
  DateTime((year from start of "Measurement Period" - 2), 10, 1, 0, 0, 0, 0, 0)

