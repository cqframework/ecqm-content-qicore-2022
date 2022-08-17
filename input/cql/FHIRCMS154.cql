library AppropriateTreatmentforUpperRespiratoryInfectionURIFHIR version '0.0.001'

/*This measure has not been tested.*/

using QICore version '4.1.1'

include FHIRHelpers version '4.0.012' called FHIRHelpers
include QICoreCommon version '1.0.000' called QICoreCommon
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include HospiceQICore4 version '3.0.000' called Hospice
include AntibioticFHIR version '1.0.000' called Antibiotic
include StatusFHIR version '1.0.0' called Status

codesystem "CPT": 'http://www.ama-assn.org/go/cpt' 

valueset "Antibiotic Medications for Pharyngitis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.196.12.1001' 
valueset "Comorbid Conditions for Respiratory Conditions": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.102.12.1025' 
valueset "Competing Conditions for Respiratory Conditions": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.102.12.1017' 
valueset "Emergency Department Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1010' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Hospital Observation Care - Initial": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1002' 
valueset "Medical Disability Exam": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1073' 
valueset "Observation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1086' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Outpatient Consultation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1008' 
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025' 
valueset "Preventive Care Services - Group Counseling": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1027' 
valueset "Preventive Care Services - Other": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1030' 
valueset "Preventive Care Services, Initial Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1022' 
valueset "Preventive Care Services-Individual Counseling": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1026' 
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023' 
valueset "Preventive Care, Established Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1024' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 
valueset "Upper Respiratory Infection": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.102.12.1022' 

code "Observation care discharge day management (This code is to be utilized to report all services provided to a patient on discharge from outpatient hospital observation status if the discharge is on other than the initial date of observation status. To report services to a patient designated as observation status or inpatient status and discharged on the same date, use the codes for Observation or Inpatient Care Services [including Admission and Discharge Services, 99234-99236 as appropriate.])": '99217' from "CPT" display 'Observation care discharge day management (This code is to be utilized to report all services provided to a patient on discharge from outpatient hospital observation status if the discharge is on other than the initial date of observation status. To report services to a patient designated as observation status or inpatient status and discharged on the same date, use the codes for Observation or Inpatient Care Services [including Admission and Discharge Services, 99234-99236 as appropriate.])'

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
  "Encounter with Upper Respiratory Infection" EncounterWithURI
        where AgeInMonthsAt(date from start of "Measurement Period" ) >= 3
          return EncounterWithURI

define "Encounter with Upper Respiratory Infection":
  from
    "Qualifying Encounter" QualifyingEncounter,
      Status."Active Condition"([Condition: "Upper Respiratory Infection"]) URI
        where QICoreCommon."ToPrevalenceInterval"(URI) starts during QICoreCommon."ToInterval"(QualifyingEncounter.period)
            or QICoreCommon."ToPrevalenceInterval"(URI) overlaps before QICoreCommon."ToInterval"(QualifyingEncounter.period)
                return QualifyingEncounter

define "Qualifying Encounter":
   (Status."Finished Encounter"([Encounter: "Observation care discharge day management (This code is to be utilized to report all services provided to a patient on discharge from outpatient hospital observation status if the discharge is on other than the initial date of observation status. To report services to a patient designated as observation status or inpatient status and discharged on the same date, use the codes for Observation or Inpatient Care Services [including Admission and Discharge Services, 99234-99236 as appropriate.])"]
                             union [Encounter: "Emergency Department Visit"]
                             union [Encounter: "Home Healthcare Services"]
                             union [Encounter: "Hospital Observation Care - Initial"]
                             union [Encounter: "Medical Disability Exam"]
                             union [Encounter: "Observation"]
                             union [Encounter: "Office Visit"]
                             union [Encounter: "Outpatient Consultation"]
                             union [Encounter: "Preventive Care Services - Group Counseling"]
                             union [Encounter: "Preventive Care Services-Individual Counseling"]
                             union [Encounter: "Preventive Care Services, Initial Office Visit, 0 to 17"]
                             union [Encounter: "Preventive Care, Established Office Visit, 0 to 17"]
                             union [Encounter: "Preventive Care Services - Established Office Visit, 18 and Up"]
                             union [Encounter: "Preventive Care Services-Initial Office Visit, 18 and Up"]
                             union [Encounter: "Outpatient Consultation"]
                             union [Encounter: "Telephone Visits"]
                             union [Encounter: "Online Assessments"]
                             union [Encounter: "Preventive Care Services - Other"] )) ValidEncounter
                             where QICoreCommon."ToInterval"(ValidEncounter.period) during "Measurement Period"
define "Denominator":
  "Initial Population"
  
define "Denominator Exclusions":
  "In Hospice"
    union Antibiotic."Has Antibiotic Medication History"("Encounter with Upper Respiratory Infection", (Status."Active Medication"("Antibiotic Medications for Pharyngitis")))
    union Antibiotic."Has Competing Diagnosis History"("Encounter with Upper Respiratory Infection", (Status."Active Condition"("Competing Conditions for Respiratory Conditions")))
    union Antibiotic."Has Comorbid Condition History"("Encounter with Upper Respiratory Infection", (Status."Active Condition"("Comorbid Conditions for Respiratory Conditions")))

define "In Hospice":
  "Initial Population" EligibleEncounters
    where Hospice."Has Hospice Services"

define "Numerator":
  "Encounter with Upper Respiratory Infection" EncounterWithURI
        without (Status."Active or Completed Medication Request"([MedicationRequest: "Antibiotic Medications for Pharyngitis"])) OrderedAntibiotic
          such that OrderedAntibiotic.authoredOn 3 days or less on or after start of QICoreCommon."ToInterval"(EncounterWithURI.period)
          return EncounterWithURI

define "Stratification 1":
  "Encounter with Upper Respiratory Infection" EncounterWithURI
      where AgeInMonthsAt( date from start of "Measurement Period" ) >= 3
          and AgeInYearsAt(date from start of "Measurement Period" ) <= 17
          return EncounterWithURI

define "Stratification 2":
  "Encounter with Upper Respiratory Infection" EncounterWithURI
      where AgeInYearsAt( date from start of "Measurement Period" ) in Interval[18, 64]
          return EncounterWithURI

define "Stratification 3":
  "Encounter with Upper Respiratory Infection" EncounterWithURI
      where AgeInYearsAt(date from start of "Measurement Period" ) >= 65
          return EncounterWithURI

