library FollowUpCareforChildrenPrescribedADHDMedicationADDFHIR version '0.0.001'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.0.012' called FHIRHelpers
include QICoreCommon version '1.0.000' called QICoreCommon
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include HospiceQICore4 version '3.0.000' called Hospice
include CumulativeMedicationDurationQICore4 version '2.0.000' called CMD
include StatusFHIR version '1.0.0' called Status

codesystem "CPT": 'http://www.ama-assn.org/go/cpt' 

valueset "ADHD Medications": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.196.12.1171' 
valueset "Ambulatory": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.122.12.1003' 
valueset "Behavioral Health Follow up Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1054' 
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Initial Hospital Observation Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1002' 
valueset "Mental Behavioral and Neurodevelopmental Disorders": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.105.12.1203' 
valueset "Narcolepsy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.114.12.1011' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Outpatient Consultation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1008' 
valueset "Preventive Care Services Group Counseling": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1027' 
valueset "Preventive Care Services Individual Counseling": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1026' 
valueset "Preventive Care Services, Initial Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1022' 
valueset "Preventive Care, Established Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1024' 
valueset "Psych Visit Diagnostic Evaluation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1492' 
valueset "Psych Visit Psychotherapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1496' 
valueset "Psychotherapy and Pharmacologic Management": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1055' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 

code "Observation care discharge day management (This code is to be utilized to report all services provided to a patient on discharge from outpatient hospital observation status if the discharge is on other than the initial date of observation status. To report services to a patient designated as observation status or inpatient status and discharged on the same date, use the codes for Observation or Inpatient Care Services [including Admission and Discharge Services, 99234-99236 as appropriate.])": '99217' from "CPT" display 'Observation care discharge day management (This code is to be utilized to report all services provided to a patient on discharge from outpatient hospital "observation status" if the discharge is on other than the initial date of "observation status." To report services to a patient designated as "observation status" or "inpatient status" and discharged on the same date, use the codes for Observation or Inpatient Care Services [including Admission and Discharge Services, 99234-99236 as appropriate.])'

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

define "Intake Period":
  Interval["March 1 of Year Prior to Measurement Period", "Last Calendar Day of February of Measurement Period"]

define "Last Calendar Day of February of Measurement Period":
  ( DateTime(year from start of "Measurement Period", 3, 1, 23, 59, 59, 0, 0)) - 1 day

define "March 1 of Year Prior to Measurement Period":
  DateTime((year from start of "Measurement Period" - 1), 3, 1, 0, 0, 0, 0, 0)

define "Initial Population 1":
AgeInYearsAt(date from start of "Intake Period")>= 6
    and AgeInYearsAt(date from 
      end of "Intake Period"
    )<= 12
    and exists "Qualifying Encounter"
    and "First ADHD Medication Prescribed During Intake Period" is not null
    and not exists "Previously on ADHD Medication"
    and not exists "Inpatient Stay with Qualifying Diagnosis During Initiation Phase"

define "Qualifying Encounter":
(Status."Finished Encounter"(( ["Encounter": "Office Visit"]
    union ["Encounter": "Home Healthcare Services"]
    union ["Encounter": "Preventive Care, Established Office Visit, 0 to 17"]
    union ["Encounter": "Preventive Care Services, Initial Office Visit, 0 to 17"] )) ValidEncounters
    where ValidEncounters.period during "Measurement Period"

define "First ADHD Medication Prescribed During Intake Period":
First("ADHD Medication Prescribed During Intake Period")

define "ADHD Medication Prescribed During Intake Period":
(Status."Active or Completed Medication Request"(["MedicationRequest": "ADHD Medications"])) ADHDMedicationOrder
    where Coalesce(ADHDMedicationOrder.dosageInstruction.timing T where (T.repeat.bounds as Period).start, ADHDMedicationOrder.dosageInstruction.timing.event)during "Intake Period"
    sort by Coalesce(dosageInstruction.timing T where (T.repeat.bounds as Period).start, ADHDMedicationOrder.dosageInstruction.timing.event)asc

define "Previously on ADHD Medication":
(Status."Active Medication"(["Medication, Active": "ADHD Medications"])) ActiveADHDMedication
  with "First ADHD Medication Prescribed During Intake Period" InitialADHDMedication
    such that Global."ToDateInterval" ( QICoreCommon."ToInterval" ( ActiveADHDMedication.relevantDatetime, ActiveADHDMedication.relevantPeriod ) ) 
    overlaps Interval[date from Coalesce(ADHDMedicationOrder.dosageInstruction.timing T where (T.repeat.bounds as Period).start, ADHDMedicationOrder.dosageInstruction.timing.event)- 120 days, date from Coalesce(ADHDMedicationOrder.dosageInstruction.timing T where (T.repeat.bounds as Period).start, ADHDMedicationOrder.dosageInstruction.timing.event))

define "Inpatient Stay with Qualifying Diagnosis During Initiation Phase":
  "Inpatient Stay with Qualifying Diagnosis" InpatientStay
      with "First ADHD Medication Prescribed During Intake Period" InitialADHDMedication
        such that QICoreCommon."ToInterval"(InpatientStay.period) starts 30 days or less after day of Coalesce(ADHDMedicationOrder.dosageInstruction.timing T where (T.repeat.bounds as Period).start, ADHDMedicationOrder.dosageInstruction.timing.event)

define "Inpatient Stay with Qualifying Diagnosis":
 (Status."Finished Encounter"([Encounter: "Encounter Inpatient"])) InpatientStay
                    with [Condition: "Mental Behavioral and Neurodevelopmental Disorders"] QualifyingDiagnosis
                      such that Global."PrincipalDiagnosis" ( InpatientStay ) = QualifyingDiagnosis

define "Denominator 1":
  "Initial Population 1"

define "Denominator Exclusions":
Hospice."Has Hospice Services"
    or exists ( "Narcolepsy Exclusion" )

define "Narcolepsy Exclusion":
  [Condition: "Narcolepsy"] Narcolepsy
                    where QICoreCommon."ToPrevalenceInterval" ( Narcolepsy ) starts on or before 
                    end "Measurement Period"

define "Numerator 1":
exists ( "Encounter During Initiation Phase" )

define "Encounter During Initiation Phase":
  ( "Qualifying Numerator Encounter" ValidNumeratorEncounter
        with "First ADHD Medication Prescribed During Intake Period" InitialADHDMedication
          such that QICoreCommon."ToInterval"(ValidNumeratorEncounter.period) starts 30 days or less after day of Coalesce(ADHDMedicationOrder.dosageInstruction.timing T where (T.repeat.bounds as Period).start, ADHDMedicationOrder.dosageInstruction.timing.event)
    )

define "Qualifying Numerator Encounter":
  Status."Finished Encounter"( ["Encounter": "Office Visit"]
        union ["Encounter": "Initial Hospital Observation Care"]
        union ["Encounter": "Preventive Care Services Group Counseling"]
        union ["Encounter": "Behavioral Health Follow up Visit"]
        union ["Encounter": "Preventive Care Services Individual Counseling"]
        union ( ["Encounter": "Psychotherapy and Pharmacologic Management"] PsychPharmManagement
            where exists ( PsychPharmManagement.location Location
                where Global.GetLocation ( Location.location ).type in "Ambulatory"
            )
        )
        union ["Encounter": "Observation care discharge day management (This code is to be utilized to report all services provided to a patient on discharge from outpatient hospital observation status if the discharge is on other than the initial date of observation status. To report services to a patient designated as observation status or inpatient status and discharged on the same date, use the codes for Observation or Inpatient Care Services [including Admission and Discharge Services, 99234-99236 as appropriate.])"]
        union ["Encounter": "Outpatient Consultation"]
        union ["Encounter": "Home Healthcare Services"]
        union ["Encounter": "Preventive Care Services, Initial Office Visit, 0 to 17"]
        union ["Encounter": "Preventive Care, Established Office Visit, 0 to 17"]
        union ["Encounter": "Psych Visit Diagnostic Evaluation"]
        union ["Encounter": "Psych Visit Psychotherapy"]
        union ["Encounter": "Telephone Visits"]
    )

define "Initial Population 2":
  AgeInYearsAt(date from start of "Intake Period")>= 6
      and AgeInYearsAt(date from 
        end of "Intake Period"
      )<= 12
      and exists "Qualifying Encounter"
      and "First ADHD Medication Prescribed During Intake Period" is not null
      and "Has ADHD Cumulative Medication Duration Greater Than or Equal to 210 Days"
      and not exists "Previously on ADHD Medication"
      and not exists "Inpatient Stay with Qualifying Diagnosis During Continuation and Maintenance Phase"

define "ADHD Medications Taken on IPSD or During Continuation and Maintenance Phase":
  "ADHD Medication Prescribed During Intake Period" ADHDMedication
      let IPSD: date from Coalesce("First ADHD Medication Prescribed During Intake Period".relevantPeriod.low, "First ADHD Medication Prescribed During Intake Period".authorDatetime),
      IPSDAndContinuationMaintenancePhase: Interval[IPSD, IPSD + 300 days]
      return CMD."MedicationRequestPeriod" ( ADHDMedication )
        intersect IPSDAndContinuationMaintenancePhase

define "Has ADHD Cumulative Medication Duration Greater Than or Equal to 210 Days":
  CMD."CumulativeDuration"("ADHD Medications Taken within 300 Days after First ADHD Medication Dispensed")>= 210

define "Inpatient Stay with Qualifying Diagnosis During Continuation and Maintenance Phase":
  "Inpatient Stay with Qualifying Diagnosis" InpatientStay
      with "First ADHD Medication Prescribed During Intake Period" InitialADHDMedication
        such that QICoreCommon."ToInterval"(InpatientStay.period) starts 300 days or less after day of Coalesce("InitialADHDMedication".relevantPeriod.low, "InitialADHDMedication".authorDatetime)

define "Denominator 2":
  "Initial Population 2"

define "Numerator 2":
exists ( "Encounter During Initiation Phase" )
    and ( ( "Two or More Encounters 31 to 300 Days into Continuation and Maintenance Phase" )
        or ( exists ( "Encounter 31 to 300 Days into Continuation and Maintenance Phase" )
            and exists ( "Online Assessment 31 to 300 Days into Continuation and Maintenance Phase" )
        )
    )

define "Two or More Encounters 31 to 300 Days into Continuation and Maintenance Phase":
  Count("Encounter 31 to 300 Days into Continuation and Maintenance Phase")>= 2

define "Encounter 31 to 300 Days into Continuation and Maintenance Phase":
  "Qualifying Numerator Encounter" ValidNumeratorEncounter
      with "First ADHD Medication Prescribed During Intake Period" InitialADHDMedication
        such that QICoreCommon."ToInterval"(ValidNumeratorEncounter.period) starts during day of Interval[Coalesce("InitialADHDMedication".relevantPeriod.low, "InitialADHDMedication".authorDatetime)+ 31 days, Coalesce("InitialADHDMedication".relevantPeriod.low, "InitialADHDMedication".authorDatetime)+ 300 days]

define "Online Assessment 31 to 300 Days into Continuation and Maintenance Phase":
  (Status."Finished Encounter"(["Encounter": "Online Assessments"])) OnlineAssessment
      with "First ADHD Medication Prescribed During Intake Period" InitialADHDMedication
        such that QICoreCommon."ToInterval"(OnlineAssessment.period) starts during day of 
        Interval[Coalesce("InitialADHDMedication".relevantPeriod.low, "InitialADHDMedication".authorDatetime)+ 31 days, Coalesce("InitialADHDMedication".relevantPeriod.low, "InitialADHDMedication".authorDatetime)+ 300 days]
