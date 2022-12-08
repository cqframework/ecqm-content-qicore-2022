library AdvancedIllnessandFrailtyExclusionQICore4 version '6.0.000'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance. Tests are available for this content.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.0.013' called FHIRHelpers
// include FHIRCommon version '4.0.012' called FHIRCommon //https://github.com/cqframework/ecqm-content-qicore-2022/issues/5
include QICoreCommon version '1.0.000' called QICoreCommon 
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include CumulativeMedicationDurationQICore4 version '2.0.000' called CMD
include StatusFHIR version '1.0.0' called Status

codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMEDCT": 'http://snomed.info/sct'

valueset "Acute Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1083'
valueset "Advanced Illness": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1082'
valueset "Dementia Medications": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.196.12.1510'
valueset "Emergency Department Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1010'
valueset "Frailty Device": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.118.12.1300'
valueset "Frailty Diagnosis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.113.12.1074'
valueset "Frailty Encounter": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1088'
valueset "Frailty Symptom": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.113.12.1075'
valueset "Nonacute Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1084'
valueset "Observation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1086'
valueset "Outpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1087'

code "Housing status": '71802-3' from "LOINC" display 'Housing status'
code "Lives in a nursing home (finding)": '160734000' from "SNOMEDCT" display 'Lives in a nursing home (finding)'
code "Medical equipment used": '98181-1' from "LOINC" display 'Medical equipment used'

parameter "Measurement Period" Interval<DateTime>
default Interval[@2023-01-01T00:00:00.000Z, @2024-01-01T00:00:00.000Z)

context Patient

// AgeInYearsAt workaround due to https://github.com/cqframework/ecqm-content-qicore-2022/issues/6
define "Is Age 66 or Older with Advanced Illness and Frailty":
  // AgeInYearsAt(date from 
  //   end of "Measurement Period"
  // )>= 66
  CalculateAgeInYearsAt(Patient.birthDate, date from end of "Measurement Period") >= 66
    and "Has Criteria Indicating Frailty"
    and ( "Has Two Outpatient Encounters with Advanced Illness on Different Dates of Service"
        or "Has Inpatient Encounter with Advanced Illness"
        or "Has Dementia Medications in Year Before or During Measurement Period"
    )

// AgeInYearsAt workaround due to https://github.com/cqframework/ecqm-content-qicore-2022/issues/6
define "Is Age 66 to 80 with Advanced Illness and Frailty or Is Age 81 or Older with Frailty":
  ( 
    // AgeInYearsAt(date from 
  //     end of "Measurement Period"
  //   )in Interval[66, 80]
      CalculateAgeInYearsAt(Patient.birthDate, date from end of "Measurement Period") in Interval[66, 80]
      and "Has Criteria Indicating Frailty"
      and ( "Has Two Outpatient Encounters with Advanced Illness on Different Dates of Service"
          or "Has Inpatient Encounter with Advanced Illness"
          or "Has Dementia Medications in Year Before or During Measurement Period"
      )
  )
    or ( 
      // AgeInYearsAt(date from 
      //   end of "Measurement Period"
      // )>= 81
       CalculateAgeInYearsAt(Patient.birthDate, date from end of "Measurement Period") >= 81
        and "Has Criteria Indicating Frailty"
    )

define "Has Criteria Indicating Frailty":
  exists ( (Status."Completed or Ongoing Device Request"([DeviceRequest: code in "Frailty Device"])) FrailtyDeviceOrder
      where QICoreCommon."ToInterval" ( FrailtyDeviceOrder.authoredOn ) during day of "Measurement Period"
  )
    or exists ( (Status."Final Survey Observation"([Observation: "Medical equipment used"])) FrailtyDeviceApplied
        where FrailtyDeviceApplied.value as Concept in "Frailty Device"
          and QICoreCommon."ToInterval" ( FrailtyDeviceApplied.effective ) ends during day of "Measurement Period"
    )
    or exists ( [Condition: "Frailty Diagnosis"] FrailtyDiagnosis
        where QICoreCommon."ToPrevalenceInterval" ( FrailtyDiagnosis ) overlaps "Measurement Period"
    )
    or exists ( (Status."Finished Encounter"([Encounter: "Frailty Encounter"])) FrailtyEncounter
        where QICoreCommon."ToInterval" ( FrailtyEncounter.period ) overlaps "Measurement Period"
    )
    or exists ( (Status."Initial or Final Observation"([Observation: "Frailty Symptom"])) FrailtySymptom
        where QICoreCommon."ToInterval" ( FrailtySymptom.effective ) overlaps "Measurement Period"
    )

define "Has Two Outpatient Encounters with Advanced Illness on Different Dates of Service":
  exists ( from
      "Outpatient Encounters with Advanced Illness" OutpatientEncounter1,
      "Outpatient Encounters with Advanced Illness" OutpatientEncounter2
      where OutpatientEncounter2.period ends 1 day or more after day of 
      end of OutpatientEncounter1.period
      return OutpatientEncounter1
  )

// BTR 2022-10-13:
// Addressed by fixes in QICore ModelInfo and the MATGlobalCommonFunctions EncounterDiagnosis function.
// Use EncounterDiagnosis as shown below

//Encounter diagnosis workaround due to https://github.com/cqframework/ecqm-content-qicore-2022/issues/8 
define "Outpatient Encounters with Advanced Illness":
   (Status."Finished Encounter"( [Encounter: "Outpatient"]
    union [Encounter: "Observation"]
    union [Encounter: "Emergency Department Visit"]
    union [Encounter: "Nonacute Inpatient"] )) OutpatientEncounter
      where exists ((Global.EncounterDiagnosis(OutpatientEncounter)) Diagnosis where Diagnosis.code in "Advanced Illness")
        and QICoreCommon."ToInterval" ( OutpatientEncounter.period ) starts during day of Interval[start of "Measurement Period" - 1 year, 
        end of "Measurement Period"]

// define "Has Inpatient Encounter with Advanced Illness":
//   exists ( ( Status."Finished Encounter"([Encounter: "Acute Inpatient"])) InpatientEncounter
//       with [Condition: "Advanced Illness"] AdvancedIllnessDiagnosis
//         such that AdvancedIllnessDiagnosis in Global.EncounterDiagnosis ( InpatientEncounter )
//         where Global.EncounterDiagnosis (InpatientEncounter) in [Condition: "Advanced Illness"]
//           and QICoreCommon."ToInterval" ( InpatientEncounter.period ) starts during day of Interval[start of "Measurement Period" - 1 year, 
//           end of "Measurement Period"]
//   )

//Encounter diagnosis workaround due to https://github.com/cqframework/ecqm-content-qicore-2022/issues/8 
define "Has Inpatient Encounter with Advanced Illness":
  exists ( ( Status."Finished Encounter"([Encounter: "Acute Inpatient"])) InpatientEncounter
      where exists ((Global.EncounterDiagnosis(InpatientEncounter)) Diagnosis where Diagnosis.code in "Advanced Illness")
        and QICoreCommon."ToInterval" ( InpatientEncounter.period ) starts during day of Interval[start of "Measurement Period" - 1 year, 
          end of "Measurement Period"]
  )

define "Has Dementia Medications in Year Before or During Measurement Period":
  exists (( Status."Active Medication"([MedicationRequest: "Dementia Medications"])) DementiaMedication
      where CMD."MedicationRequestPeriod" ( DementiaMedication ) overlaps Interval[start of "Measurement Period" - 1 year, 
        end of "Measurement Period"]
  )

// AgeInYearsAt workaround due to https://github.com/cqframework/ecqm-content-qicore-2022/issues/6
define "Is Age 66 or Older Living Long Term in a Nursing Home":
  // AgeInYearsAt(date from 
  //   end of "Measurement Period"
  // )>= 66
CalculateAgeInYearsAt(Patient.birthDate, date from end of "Measurement Period") >= 66
    and ( ( Last( (Status."Final Survey Observation"([Observation: "Housing status"])) HousingStatus    
          where QICoreCommon."ToInterval"(HousingStatus.effective)ends on or before 
          end of "Measurement Period"
          sort by 
          end of QICoreCommon."ToInterval"(effective)asc
      )) LastHousingStatus
        where LastHousingStatus.value ~ "Lives in a nursing home (finding)"
    ) is not null
