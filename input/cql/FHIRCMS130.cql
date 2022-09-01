library ColorectalCancerScreeningsFHIR version '0.0.001'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.0.012' called FHIRHelpers
include QICoreCommon version '1.0.000' called QICoreCommon
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include StatusFHIR version '1.0.0' called Status
include AdultOutpatientEncountersQICore4 version '3.0.000' called AdultOutpatientEncounter
include AdvancedIllnessandFrailtyExclusionQICore4 version '6.0.000' called AIFrailLTCF
include CumulativeMedicationDurationQICore4 version '2.0.000' called CMD
include HospiceQICore4 version '3.0.000' called Hospice
include PalliativeCareQICore4 version '1.0.000' called PalliativeCare

valueset "Colonoscopy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1020' 
valueset "CT Colonography": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1038' 
valueset "Fecal Occult Blood Test (FOBT)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1011' 
valueset "FIT DNA": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1039' 
valueset "Flexible Sigmoidoscopy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1010' 
valueset "Malignant Neoplasm of Colon": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1001' 
valueset "Total Colectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1019'

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
  AgeInYearsAt(date from start of "Measurement Period")in Interval[46, 75]
            and exists AdultOutpatientEncounters."Qualifying Encounters"

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice Services"
      or exists "Malignant Neoplasm"
      or exists "Total Colectomy Performed"
      or AIFrailLTCF."Is Age 66 or Older with Advanced Illness and Frailty"
      or AIFrailLTCF."Is Age 66 or Older Living Long Term in a Nursing Home"
      or PalliativeCare."Palliative Care in the Measurement Period"

define "Malignant Neoplasm":
  [Condition: "Malignant Neoplasm of Colon"] ColorectalCancer
            where QICoreCommon."ToPrevalenceInterval" ( ColorectalCancer ) starts on or before 
              end of "Measurement Period"

define "Total Colectomy Performed":
  (Status."Completed Procedure"([Procedure: "Total Colectomy"])) Colectomy
            where QICoreCommon."ToInterval" ( Colectomy.performed ) ends on or before 
              end of "Measurement Period"

define "Numerator":
  exists "Fecal Occult Blood Test Performed"
      or exists "Fecal Immunochemical Test DNA Performed"
      or exists "Flexible Sigmoidoscopy Performed"
      or exists "CT Colonography Performed"
      or exists "Colonoscopy Performed"

define "Fecal Occult Blood Test Performed":
  (Status."Final Lab Observation"([Observation: "Fecal Occult Blood Test (FOBT)"])) FecalOccultResult
            where FecalOccultResult.value is not null
              and QICoreCommon."Latest" ( FecalOccultResult.effective ) during "Measurement Period"

define "Fecal Immunochemical Test DNA Performed":
  (Status."Final Lab Observation"([Observation: "FIT DNA"])) FitDNA
            where FitDNA.value is not null
              and QICoreCommon."Latest" ( FitDNA.effective ) during day of Interval[start of "Measurement Period" - 2 years, end of "Measurement Period"]

define "Flexible Sigmoidoscopy Performed":
  (Status."Completed Procedure"([Procedure: "Flexible Sigmoidoscopy"])) FlexibleSigmoidoscopy
            where QICoreCommon."ToInterval" ( FlexibleSigmoidoscopy.performed ) ends during day of Interval[start of "Measurement Period" - 4 years, end of "Measurement Period"]

define "CT Colonography Performed":
  (Status."Final Observation"([Observation: "CT Colonography"])) Colonography
            where QICoreCommon."ToInterval" ( Colonography.effective ) ends during day of Interval[start of "Measurement Period" - 4 years, 
  end of "Measurement Period"]

define "Colonoscopy Performed":
  (Status."Completed Procedure"([Procedure: "Colonoscopy"])) Colonoscopy
            where QICoreCommon."ToInterval" ( Colonoscopy.performed ) ends during day of Interval[start of "Measurement Period" - 9 years, 
  end of "Measurement Period"]

define "Stratification 1":
  AgeInYearsAt(date from 
      end of "Measurement Period"
    )in Interval[46, 49]

define "Stratification 2":
  AgeInYearsAt(date from 
      end of "Measurement Period"
    )in Interval[50, 75]
