library ControllingHighBloodPressureFHIR version '0.0.001'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance. Tests are available for this content.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
// include FHIRCommon version '4.0.012' called FHIRCommon //https://github.com/cqframework/ecqm-content-qicore-2022/issues/5
include QICoreCommon version '1.2.000' called QICoreCommon
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include StatusFHIR version '1.0.0' called Status
include AdultOutpatientEncountersQICore4 version '3.0.000' called AdultOutpatientEncounters
include AdvancedIllnessandFrailtyExclusionQICore4 version '6.0.000' called AIFrailLTCF
include CumulativeMedicationDurationQICore4 version '2.0.000' called CMD
include HospiceQICore4 version '3.0.000' called Hospice
include PalliativeCareQICore4 version '1.0.000' called PalliativeCare

codesystem "LOINC": 'http://loinc.org'
codesystem "ObservationCategoryCodes": 'http://terminology.hl7.org/CodeSystem/observation-category'

valueset "Chronic Kidney Disease, Stage 5": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1002' 
valueset "Dialysis Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1013' 
valueset "Emergency Department Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1010' 
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307' 
valueset "End Stage Renal Disease": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.353' 
valueset "ESRD Monthly Outpatient Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1014' 
valueset "Essential Hypertension": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.104.12.1011' 
valueset "Kidney Transplant": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1012' 
valueset "Kidney Transplant Recipient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.109.12.1029' 
valueset "Pregnancy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.378' 

code "vital-signs": 'vital-signs' from "ObservationCategoryCodes" display 'vital-signs'
code "Diastolic blood pressure": '8462-4' from "LOINC" display 'Diastolic blood pressure'
code "Systolic blood pressure": '8480-6' from "LOINC" display 'Systolic blood pressure'

parameter "Measurement Period" Interval<DateTime>
default Interval[@2023-01-01T00:00:00.000Z, @2024-01-01T00:00:00.000Z)

context Patient

// AgeInYearsAt workaround due to https://github.com/cqframework/ecqm-content-qicore-2022/issues/6
define "Initial Population":
  // AgeInYearsAt(date from 
  //     end of "Measurement Period"
  //   )in Interval[18, 85]
  CalculateAgeInYearsAt(Patient.birthDate, date from end of "Measurement Period") in Interval[18, 85]
      and exists "Essential Hypertension Diagnosis"
      and exists AdultOutpatientEncounters."Qualifying Encounters"

define "Essential Hypertension Diagnosis":
  ["Condition": "Essential Hypertension"] Hypertension
      where QICoreCommon."ToPrevalenceInterval"(Hypertension) overlaps Interval[start of "Measurement Period", start of "Measurement Period" + 6 months )

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
 Hospice."Has Hospice Services"
      or exists ( "Pregnancy or Renal Diagnosis Exclusions" )
      or exists ( "End Stage Renal Disease Procedures" )
      or exists ( "End Stage Renal Disease Encounter" )
      or AIFrailLTCF."Is Age 66 to 80 with Advanced Illness and Frailty or Is Age 81 or Older with Frailty"
      or AIFrailLTCF."Is Age 66 or Older Living Long Term in a Nursing Home"
      or PalliativeCare."Palliative Care in the Measurement Period"

define "Pregnancy or Renal Diagnosis Exclusions":
  ( ["Condition": "Pregnancy"]
      union ["Condition": "End Stage Renal Disease"]
      union ["Condition": "Kidney Transplant Recipient"]
      union ["Condition": "Chronic Kidney Disease, Stage 5"] ) PregnancyESRDDiagnosis
      where QICoreCommon."ToPrevalenceInterval"(PregnancyESRDDiagnosis) overlaps "Measurement Period"

define "End Stage Renal Disease Procedures":
  ( (Status."Completed Procedure"(["Procedure": "Kidney Transplant"]
      union ["Procedure": "Dialysis Services"] ))) ESRDProcedure
      where 
      end of QICoreCommon."ToInterval" ( ESRDProcedure.performed) on or before 
      end of "Measurement Period"

define "End Stage Renal Disease Encounter":
  (Status."Finished Encounter"(["Encounter": "ESRD Monthly Outpatient Services"])) ESRDEncounter
      where QICoreCommon."ToInterval"(ESRDEncounter.period) starts on or before 
      end of "Measurement Period"

define "Numerator":
  "Has Systolic Blood Pressure Less Than 140"
      and "Has Diastolic Blood Pressure Less Than 90"

define "Has Systolic Blood Pressure Less Than 140":
  "Lowest Systolic Reading on Most Recent Blood Pressure Day" < 140 'mm[Hg]'

define "Has Diastolic Blood Pressure Less Than 90":
  "Lowest Diastolic Reading on Most Recent Blood Pressure Day" < 90 'mm[Hg]'

define "Lowest Diastolic Reading on Most Recent Blood Pressure Day":
  First("Qualifying Diastolic Blood Pressure Reading" DBPReading
        where QICoreCommon."Latest"(DBPReading.effective)same day as "Most Recent Blood Pressure Day"
        return singleton from(DBPReading.component DBPComponent
            where DBPComponent.code ~ "Diastolic blood pressure"
            return DBPComponent.value as Quantity
        )
        sort asc
    )

define "Lowest Systolic Reading on Most Recent Blood Pressure Day":
  First("Qualifying Systolic Blood Pressure Reading" SBPReading
        where QICoreCommon."Latest"(SBPReading.effective)same day as "Most Recent Blood Pressure Day"
        return singleton from(SBPReading.component SBPComponent
            where SBPComponent.code ~ "Systolic blood pressure"
            return SBPComponent.value as Quantity
        )
        sort asc
    )

define "Qualifying Diastolic Blood Pressure Reading":
	(["observation-bp"]) BloodPressure
	  where BloodPressure.status in { 'final', 'amended', 'corrected'}
    and exists (BloodPressure.category BPCategory
                where BPCategory ~ "vital-signs")
    and not (GetEncounter(BloodPressure.encounter).class.code in { 'EMER', 'IMP', 'ACUTE', 'NONAC', 'PRENC', 'SS'})
          and QICoreCommon."Latest"(BloodPressure.effective) during day of "Measurement Period"

define "Qualifying Systolic Blood Pressure Reading":
	(["observation-bp"]) BloodPressure
	  where BloodPressure.status in { 'final', 'amended', 'corrected'}
    and exists (BloodPressure.category BPCategory
                where BPCategory ~ "vital-signs")
    and not (GetEncounter(BloodPressure.encounter).class.code in { 'EMER', 'IMP', 'ACUTE', 'NONAC', 'PRENC', 'SS'})
          and QICoreCommon."Latest"(BloodPressure.effective) during day of "Measurement Period"

define function "GetEncounter"(reference Reference):
  singleton from ([Encounter] E where E.id = reference.reference.getId())

define "Blood Pressure Days":
  ( "Qualifying Diastolic Blood Pressure Reading" DBPExam
        return date from QICoreCommon."Latest" ( DBPExam.effective )
    )
      intersect ( "Qualifying Systolic Blood Pressure Reading" SBPExam
          return date from QICoreCommon."Latest" ( SBPExam.effective )
      )

define "Most Recent Blood Pressure Day":
  Last("Blood Pressure Days" BPDays
        sort asc
    )

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"
