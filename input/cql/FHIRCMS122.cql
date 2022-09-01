library DiabetesHemoglobinA1cHbA1cPoorControl9FHIR version '0.0.01'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.0.012' called FHIRHelpers
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include HospiceQICore4 version '3.0.000' called Hospice
include PalliativeCareQICore4 version '1.0.000' called PalliativeCare
include AdvancedIllnessandFrailtyExclusionQICore4 version '6.0.000' called AIFrailLTCF
include StatusFHIR version '1.0.0' called Status

valueset "Annual Wellness Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1240' 
valueset "Diabetes": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.103.12.1001' 
valueset "Discharged to Health Care Facility for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.207' 
valueset "Discharged to Home for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.209' 
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307' 
valueset "HbA1c Laboratory Test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1013' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Hospice care ambulatory": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1108.15' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025' 
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 

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
        and exists ("Qualifying Encounters")
        and exists ( [Condition: "Diabetes"] Diabetes
            where QICoreCommon."ToPrevalenceInterval"(Diabetes) overlaps "Measurement Period"
                    )

define "Qualifying Encounters":
Status."Finished Encounter"([Encounter: "Office Visit"]
    union [Encounter: "Annual Wellness Visit"]
    union [Encounter: "Preventive Care Services Established Office Visit, 18 and Up"]
    union [Encounter: "Preventive Care Services Initial Office Visit, 18 and Up"]
    union [Encounter: "Home Healthcare Services"]
    union [Encounter: "Nutrition Services"]
    union [Encounter: "Medical nutrition therapy; initial assessment and intervention, individual, face-to-face with the patient, each 15 minutes"]
    union [Encounter: "Medical nutrition therapy; re-assessment and intervention, individual, face-to-face with the patient, each 15 minutes"]
    union [Encounter: "Medical nutrition therapy; group (2 or more individual(s)), each 30 minutes"]
    union [Encounter: "Medical nutrition therapy; reassessment and subsequent intervention(s) following second referral in same year for change in diagnosis, medical condition or treatment regimen (including additional hours needed for renal disease), individual, face to face with the patient, each 15 minutes"]
    union [Encounter: "Medical nutrition therapy, reassessment and subsequent intervention(s) following second referral in same year for change in diagnosis, medical condition, or treatment regimen (including additional hours needed for renal disease), group (2 or more individuals), each 30 minutes"]
    union ["Encounter, Performed": "Telephone Visits"] ) ValidEncounters
        where ValidEncounters.period during day of "Measurement Period"

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice Services"
    or AIFrailLTCF."Is Age 66 or Older with Advanced Illness and Frailty"
    or AIFrailLTCF."Is Age 66 or Older Living Long Term in a Nursing Home"
    or PalliativeCare."Palliative Care in the Measurement Period"

define "Numerator":
  "Has Most Recent HbA1c Without Result"
        or "Has Most Recent Elevated HbA1c"
        or "Has No Record Of HbA1c"

define "Has Most Recent HbA1c Without Result":
  "Most Recent HbA1c" is not null
        and "Most Recent HbA1c".value is null

define "Most Recent HbA1c":
  Last(Status."Final Lab Observation"([Observation: "HbA1c Laboratory Test"]) RecentHbA1c
        where QICoreCommon."Latest"(RecentHbA1c.effective) during day of "Measurement Period"
            sort by start of QICoreCommon."ToInterval"(effective)
       )

define "Has Most Recent Elevated HbA1c":
  ("Most Recent HbA1c".value as Quantity) > 9 '%'

define "Has No Record Of HbA1c":
  not exists (Status."Final Lab Observation"([Observation: "HbA1c Laboratory Test"]) NoHbA1c
        where QICoreCommon."Latest"(NoHbA1c.effective) during day of "Measurement Period"
             )

