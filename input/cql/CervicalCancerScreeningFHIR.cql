library CervicalCancerScreeningFHIR version '0.0.001'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance. Tests are available for this content.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.0.013' called FHIRHelpers
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include StatusFHIR version '1.0.0' called Status
include HospiceQICore4 version '3.0.000' called Hospice
include PalliativeCareQICore4 version '1.0.000' called PalliativeCare
// include FHIRCommon version '4.0.012' called FHIRCommon //https://github.com/cqframework/ecqm-content-qicore-2022/issues/5
include QICoreCommon version '1.0.000' called QICoreCommon

valueset "Congenital or Acquired Absence of Cervix": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.111.12.1016' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "HPV Test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1059' 
valueset "Hysterectomy with No Residual Cervix": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1014' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Pap Test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1017' 
valueset "Preventive Care Services Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025' 
valueset "Preventive Care Services Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 

parameter "Measurement Period" Interval<DateTime>
    default Interval[@2023-01-01T00:00:00.000Z, @2024-01-01T00:00:00.000Z) 

context Patient

// AgeInYearsAt workaround due to https://github.com/cqframework/ecqm-content-qicore-2022/issues/6
define "Initial Population":
   //AgeInYearsAt(date from 
   //    end of "Measurement Period"
   //  ) in Interval[24, 64]
  CalculateAgeInYearsAt(Patient.birthDate, date from end of "Measurement Period") in Interval[24, 64]
      and Patient.gender = 'female'
      and exists "Qualifying Encounters"

define "Qualifying Encounters":
  (Status."Finished Encounter"( ["Encounter": "Office Visit"]
      union ["Encounter": "Preventive Care Services Established Office Visit, 18 and Up"]
      union ["Encounter": "Preventive Care Services Initial Office Visit, 18 and Up"]
      union ["Encounter": "Home Healthcare Services"]
      union ["Encounter": "Telephone Visits"]
      union ["Encounter": "Online Assessments"] )) ValidEncounters
      where QICoreCommon."ToInterval"(ValidEncounters.period) during day of "Measurement Period"

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice Services"
      or exists "Absence of Cervix"
      or PalliativeCare."Palliative Care in the Measurement Period"

define "Numerator":
  exists "Cervical Cytology Within 3 Years"
      or exists "HPV Test Within 5 Years for Women Age 30 and Older"

define "Absence of Cervix":
  ( (Status."Completed Procedure"(["Procedure": "Hysterectomy with No Residual Cervix"])) NoCervixProcedure
        where QICoreCommon."ToInterval" ( NoCervixProcedure.performed ) ends on or before 
        end of "Measurement Period"
    )
      union ( ["Condition": "Congenital or Acquired Absence of Cervix"] NoCervixDiagnosis
          where QICoreCommon."ToPrevalenceInterval"(NoCervixDiagnosis) starts on or before
          end of "Measurement Period"
      )

define "Cervical Cytology Within 3 Years":
  (Status."Final Lab Observation"(["Observation": "Pap Test"])) CervicalCytology
      where QICoreCommon."Latest" ( CervicalCytology.effective ) during day of Interval[start of "Measurement Period" - 2 years, 
      end of "Measurement Period"]
        and CervicalCytology.value is not null

// AgeInYearsAt workaround due to https://github.com/cqframework/ecqm-content-qicore-2022/issues/6
define "HPV Test Within 5 Years for Women Age 30 and Older":
  (Status."Final Lab Observation"(["Observation": "HPV Test"])) HPVTest
      //where AgeInYearsAt(date from QICoreCommon."Latest"(HPVTest.effective))>= 30
        where CalculateAgeInYearsAt(Patient.birthDate, date from QICoreCommon."Latest"(HPVTest.effective))>= 30 
        and QICoreCommon."Latest" ( HPVTest.effective ) during day of Interval[start of "Measurement Period" - 4 years, 
        end of "Measurement Period"]
        and HPVTest.value is not null

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"
