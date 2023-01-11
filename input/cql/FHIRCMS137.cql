library InitiationandEngagementofAlcoholandOtherDrugDependenceTreatmentFHIR version '0.0.001'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include QICoreCommon version '1.2.000' called QICoreCommon
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include CumulativeMedicationDurationQICore4 version '2.0.000' called CMD
include HospiceQICore4 version '3.0.000' called Hospice

valueset "Detoxification Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1059' 
valueset "Discharge Services Hospital Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1007' 
valueset "Discharge Services Hospital Inpatient Same Day Discharge": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1006' 
valueset "Emergency Department Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1010' 
valueset "Initial Hospital Inpatient Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1004' 
valueset "Initial Hospital Observation Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1002' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Psych Visit Psychotherapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1496' 
valueset "Substance Use Disorder": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.106.12.1001' 
valueset "Substance Use Disorder Long Acting Medication": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1149' 
valueset "Substance Use Disorder Long Acting Medication Administration": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1156' 
valueset "Substance Use Disorder Short Acting Medication": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1150' 
valueset "Substance Use Disorder Short Acting Medication Administration": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1157' 
valueset "Substance Use Disorder Treatment": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.106.12.1005' 
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
  AgeInYearsAt(date from start of "Measurement Period")>= 13
      and "First SUD Episode During Measurement Period" is not null
      and not exists "History of SUD Diagnosis or Treatment"

define "First SUD Episode During Measurement Period":
  First(("Qualifying Encounters")ValidEncounters
        with ["Condition": "Substance Use Disorder"] SUDDiagnosis
          such that QICoreCommon."ToInterval"(ValidEncounters.period) during "Measurement Period"
            and QICoreCommon."ToPrevalenceInterval"(SUDDiagnosis) starts during QICoreCommon."ToInterval"(ValidEncounters.period)
            and QICoreCommon."ToPrevalenceInterval"(SUDDiagnosis) starts 47 days or more before day of
            end of "Measurement Period"
        sort by start of QICoreCommon."ToPrevalenceInterval"(SUDDiagnosis)
    )

define "Qualifying Encounters":
  Status."Finished Encounter"( ["Encounter": "Office Visit"]
        union ["Encounter": "Emergency Department Visit"]
        union ["Encounter": "Detoxification Visit"]
        union ["Encounter": "Initial Hospital Observation Care"]
        union ["Encounter": "Initial Hospital Inpatient Visit"]
        union ["Encounter": "Discharge Services Hospital Inpatient Same Day Discharge"]
        union ["Encounter": "Discharge Services Hospital Inpatient"]
        union ["Encounter": "Telephone Visits"]
        union ["Encounter": "Online Assessments"]
    )


define "History of SUD Diagnosis or Treatment":
  ( (Status."Completed Procedure"( ["Procedure": "Substance Use Disorder Treatment"]
        union ["Procedure": "Psych Visit Psychotherapy"]
        union ["Procedure": "Substance Use Disorder Long Acting Medication Administration"]
        union ["Procedure": "Substance Use Disorder Short Acting Medication Administration"] )) Interventions
        with "First SUD Episode During Measurement Period" FirstSUDEpisode
          such that QICoreCommon."ToInterval" ( Interventions.performed ) starts 60 days or less before day of start of QICoreCommon."ToInterval"(FirstSUDEpisode.period)
    )
      union ( ( ( "Qualifying Encounters"
          except "Emergency Department or Detoxification Visit" ) QualifyingEncounter
          with ["Condition": "Substance Use Disorder"] SUDDiagnosis 
          such that SUDDiagnosis = Global."EncounterDiagnosis"(QualifyingEncounter)
          ) EncounterWithDiagnosis
          with "First SUD Episode During Measurement Period" FirstSUDEpisode
            such that QICoreCommon."ToInterval"(EncounterWithDiagnosis.period) starts 60 days or less before day of start of QICoreCommon."ToInterval"(FirstSUDEpisode.period)
      )
      union ( (Status."Active or Completed Medication Request"( ["MedicationRequest": "Substance Use Disorder Long Acting Medication"]
          union ["MedicationRequest": "Substance Use Disorder Short Acting Medication"] )) SUDMedication
          with "First SUD Episode During Measurement Period" FirstSUDEpisode
            such that QICoreCommon."ToInterval"(SUDMedication.authoredOn) 60 days or less before day of start of QICoreCommon."ToInterval"(FirstSUDEpisode.period)
      )

define "Emergency Department or Detoxification Visit":
  Status."Finished Encounter"(["Encounter": "Emergency Department Visit"]
      union ["Encounter": "Detoxification Visit"])

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice Services"

define "Numerator 1":
  exists "Treatment Initiation With Non Medication Intervention Dates"
      or exists "Treatment Initiation With Medication Order Dates"

define "Treatment Initiation With Non Medication Intervention Dates":
  "Psychosocial Visit" PsychosocialVisit
      let treatmentDate: date from start of QICoreCommon."ToInterval" ( PsychosocialVisit.period ) or date from start of QICoreCommon."ToInterval" ( PsychosocialVisit.effective )
      with "First SUD Episode During Measurement Period" FirstSUDEpisode
        such that treatmentDate during Interval[date from start of QICoreCommon."ToInterval"(FirstSUDEpisode.period), date from start of QICoreCommon."ToInterval"(FirstSUDEpisode.period) + 14 days )
          and PsychosocialVisit.id !~ FirstSUDEpisode.id
      return all treatmentDate

define "Psychosocial Visit":
  Status."Completed Procedure"(["Procedure": "Substance Use Disorder Treatment"]
      union ["Procedure": "Psych Visit Psychotherapy"])
      union ( (Status."Finished Encounter"( ["Encounter": "Telephone Visits"]
          union ["Encounter": "Online Assessments"] )) TelehealthEncounter
          with ["Condition": "Substance Use Disorder"] SUDDiagnosis         
          such that SUDDiagnosis = Global."EncounterDiagnosis"(TelehealthEncounter)
          )

define "Treatment Initiation With Medication Order Dates":
  ( ( ["MedicationRequest": "Substance Use Disorder Short Acting Medication"]
        union ["MedicationRequest": "Substance Use Disorder Long Acting Medication"] ) SUDMedication
        let treatmentDate: date from start of QICoreCommon."ToInterval"(SUDMedication.authoredOn)
        with "First SUD Episode During Measurement Period" FirstSUDEpisode
          such that treatmentDate during Interval[date from start of QICoreCommon."ToInterval"(FirstSUDEpisode.period), date from start of QICoreCommon."ToInterval"(FirstSUDEpisode.period) + 14 days )
        return all treatmentDate
    )
      union ( ( ["Procedure": "Substance Use Disorder Short Acting Medication Administration"]
          union ["Procedure": "Substance Use Disorder Long Acting Medication Administration"] ) SUDMedAdministration
          let treatmentDate: date from start of QICoreCommon."ToInterval" ( SUDMedAdministration.performed )
          with "First SUD Episode During Measurement Period" FirstSUDEpisode
            such that treatmentDate during Interval[date from start of QICoreCommon."ToInterval"(FirstSUDEpisode.period), date from start of QICoreCommon."ToInterval"(FirstSUDEpisode.period) + 14 days )
          return all treatmentDate
      )

define "Numerator 2":
  "Has Treatment Engagement With Long Acting Medication"
      or "Has Treatment Engagement With Short Acting Medication or Non Medication Intervention"

define "Has Treatment Engagement With Long Acting Medication":
  exists ( ( ["MedicationRequest": "Substance Use Disorder Long Acting Medication"] LongActingMedOrder
          with ( Min("Treatment Initiation With Non Medication Intervention Dates"
              union "Treatment Initiation With Medication Order Dates"
          )) InitiationTreatmentDate
            such that date from start of QICoreCommon."ToInterval"(LongActingMedOrder.authoredOn) 34 days or less after InitiationTreatmentDate
      )
        union ( ["Procedure": "Substance Use Disorder Long Acting Medication Administration"] LongActingTreatment
            with ( Min("Treatment Initiation With Non Medication Intervention Dates"
                union "Treatment Initiation With Medication Order Dates"
            )) InitiationTreatmentDate
              such that date from start of QICoreCommon."ToInterval" ( LongActingTreatment.performed) 34 days or less after InitiationTreatmentDate
        )
    )

define "Has Treatment Engagement With Short Acting Medication or Non Medication Intervention":
  Count((("Psychosocial Visit"
          union ["Procedure": "Substance Use Disorder Short Acting Medication Administration"])ShortActingTreatment
          with(Min("Treatment Initiation With Non Medication Intervention Dates"
              union "Treatment Initiation With Medication Order Dates"
          ))InitiationTreatmentDate
            such that date from start of QICoreCommon."ToInterval"(ShortActingTreatment.performed)34 days or less after InitiationTreatmentDate
            or date from start of QICoreCommon."ToInterval"(ShortActingTreatment.effective)34 days or less after InitiationTreatmentDate
          return all ShortActingTreatment
      )
        union(["MedicationRequest": "Substance Use Disorder Short Acting Medication"] ShortActingMedOrder
            with(Min("Treatment Initiation With Non Medication Intervention Dates"
                union "Treatment Initiation With Medication Order Dates"
            ))InitiationTreatmentDate
              such that date from start of QICoreCommon."ToInterval"(ShortActingMedOrder.authoredOn) 34 days or less after InitiationTreatmentDate
            return all ShortActingMedOrder
        )
    )>= 2

define "Stratification 1":
  AgeInYearsAt(date from start of "Measurement Period")in Interval[13, 17]

define "Stratification 2":
  AgeInYearsAt(date from start of "Measurement Period")in Interval[18, 64]

define "Stratification 3":
  AgeInYearsAt(date from start of "Measurement Period")>= 65

// define "SDE Ethnicity":
//   SDE."SDE Ethnicity"

// define "SDE Payer":
//   SDE."SDE Payer"

// define "SDE Race":
//   SDE."SDE Race"

// define "SDE Sex":
//   SDE."SDE Sex"

// define "Denominator":
//   "Initial Population"

// define "Denominator Exclusions":
//   Hospice."Has Hospice"
//       or exists "History of Dependence Diagnosis or Treatment"

// define "Qualifying Encounters":
//   ( [Encounter: "Office Visit"]
//       union [Encounter: "Emergency Department Visit"]
//       union [Encounter: "Detoxification Visit"]
//       union [Encounter: "Hospital Observation Care - Initial"]
//       union [Encounter: "Hospital Inpatient Visit - Initial"]
//       union [Encounter: "Discharge Services - Hospital Inpatient Same Day Discharge"]
//       union [Encounter: "Discharge Services - Hospital Inpatient"]
//       union [Encounter: "Telephone Visits"]
//       union [Encounter: "Online Assessments"] ) ValidEncounters
//       where ValidEncounters.status = 'finished'
//         and QICoreCommon."ToInterval" ( ValidEncounters.period ) during "Measurement Period"

// define "Continuation of Treatment Event Following Medication Initiation":
//   "Psychosocial Visit" ContinuedTreatment
//       with "Treatment Initiation With Medication Order" TreatmentEvent
//         such that QICoreCommon."ToInterval" ( ContinuedTreatment.performed ) starts 34 days or less after start of CMD."MedicationPeriod" ( TreatmentEvent )

// define "Initial Population":
//   AgeInYearsAt(date from start of "Measurement Period")>= 13
//       and "First Dependence Diagnosis During Measurement Period" is not null

// define "History of Dependence Diagnosis or Treatment":
//   ( ( [Procedure: "Alcohol and Drug Dependence Treatment"]
//         union [Procedure: "Psych Visit - Psychotherapy"] ) Interventions
//         with "First Dependence Diagnosis During Measurement Period" FirstDiagnosis
//           such that Interventions.status = 'completed'
//             and QICoreCommon."ToInterval" ( Interventions.performed ) starts 60 days or less before start of QICoreCommon."ToPrevalenceInterval" ( FirstDiagnosis )
//     )
//       union ( ( "Qualifying Encounters" QualifyingEncounter
//           with [Condition: "Alcohol and Drug Dependence"] DependenceDiagnosis
//             such that DependenceDiagnosis in Global."EncounterDiagnosis" ( QualifyingEncounter ) ) EncounterWithDiagnosis
//           with "First Dependence Diagnosis During Measurement Period" FirstDiagnosis
//             such that QICoreCommon."ToInterval" ( EncounterWithDiagnosis.period ) starts 60 days or less before start of QICoreCommon."ToPrevalenceInterval" ( FirstDiagnosis )
//       )
//       union ( [MedicationRequest: "Opiate Antagonists"] Opiates
//           with "First Dependence Diagnosis During Measurement Period" FirstDiagnosis
//             such that Opiates.status in { 'active', 'completed', 'on-hold' }
//               and Opiates.intent = 'order'
//               and CMD."MedicationPeriod" ( Opiates ) starts 60 days or less before start of QICoreCommon."ToPrevalenceInterval" ( FirstDiagnosis )
//       )

// define "Has Dependence Treatment Intervention Continued":
//   Count("Psychosocial Visit" ContinuedTreatment
//         with "Treatment Initiation with Non Medication Intervention" InitiatedTreatment
//           such that start of QICoreCommon."ToInterval"(ContinuedTreatment.performed)34 days or less after start of QICoreCommon."ToInterval"(InitiatedTreatment.performed)
//     )>= 2

// define "Has Treatment Initiation With Medication and Continuation of Treatment with Encounters":
//   Count("Psychosocial Visit" ContinuedTreatment
//         with("Treatment Initiation With Medication Order")InitiatedTreatment
//           such that QICoreCommon."ToInterval"(ContinuedTreatment.performed)starts 34 days or less after start of CMD."MedicationPeriod"(InitiatedTreatment)
//     )>= 2

// define "Stratification 1":
//   AgeInYearsAt(date from start of "Measurement Period")in Interval[13, 17]

// define "Stratification 2":
//   AgeInYearsAt(date from start of "Measurement Period")>= 18

// define "Treatment with Single Medication Order During Measurement Period":
//   [MedicationRequest: "Opiate Antagonists"] MedicationOrderOpiate
//       where MedicationOrderOpiate.status in { 'active', 'completed' }
//         and MedicationOrderOpiate.intent = 'order'
//         and start of CMD."MedicationPeriod" ( MedicationOrderOpiate ) during "Measurement Period"

// define "Numerator 2":
//   exists ( "Treatment Initiation with Non Medication Intervention" NonMedicationInitiation
//         with "Treatment with Single Medication Order During Measurement Period" MedicationContinuation
//           such that CMD."MedicationPeriod" ( MedicationContinuation ) starts 34 days or less after start of QICoreCommon."ToInterval" ( NonMedicationInitiation.performed )
//     )
//       or "Has Dependence Treatment Intervention Continued"
//       or ( exists "Treatment Initiation With Medication Order" InitiatedTreatment
//           where ( exists "Continuation of Treatment Event Following Medication Initiation" )
//             and ( exists "Treatment with Single Medication Order During Measurement Period" MedicationContinuation
//                 where CMD."MedicationPeriod" ( MedicationContinuation ) starts 34 days or less after start of CMD."MedicationPeriod" ( InitiatedTreatment )
//             )
//       )
//       or "Has Treatment Initiation With Medication and Continuation of Treatment with Encounters"

// define "Numerator 1":
//   exists "Treatment Initiation with Non Medication Intervention"
//       or exists "Treatment Initiation With Medication Order"

// define "First Dependence Diagnosis During Measurement Period":
//   First(([Condition: "Alcohol and Drug Dependence"] DependenceDiagnosis
//         where DependenceDiagnosis.clinicalStatus ~ Global."active"
//           or DependenceDiagnosis.clinicalStatus ~ Global."recurrence"
//           or DependenceDiagnosis.clinicalStatus ~ Global."relapse")ActiveDependenceDiagnosis
//         with("Qualifying Encounters")ValidEncounter
//           such that QICoreCommon."ToInterval"(ValidEncounter.period)during "Measurement Period"
//             and QICoreCommon."ToPrevalenceInterval"(ActiveDependenceDiagnosis)starts during QICoreCommon."ToInterval"(ValidEncounter.period)
//             and QICoreCommon."ToPrevalenceInterval"(ActiveDependenceDiagnosis)starts 47 days or more before day of 
//             end of "Measurement Period"
//         sort by start of QICoreCommon."ToInterval"(onset)
//     )

// define "Treatment Initiation with Non Medication Intervention":
//   "Psychosocial Visit" TreatmentInitiatedWithIntervention
//       with "First Dependence Diagnosis During Measurement Period" FirstDiagnosed
//         such that QICoreCommon."ToInterval" ( TreatmentInitiatedWithIntervention.performed ) starts 14 days or less after day of start of QICoreCommon."ToPrevalenceInterval" ( FirstDiagnosed )

// define "Psychosocial Visit":
//   ( ( [Procedure: "Alcohol and Drug Dependence Treatment"]
//         union [Procedure: "Psych Visit - Psychotherapy"] ) DependenceIntervention
//         where DependenceIntervention.status in { 'completed', 'in-progress' }
//     )
//       union ( ( ( [Encounter: "Telephone Visits"]
//           union [Encounter: "Online Assessments"] ) Telehealth
//           with [Condition: "Alcohol and Drug Dependence"] DependenceDiagnosis
//             such that Telehealth.status = 'finished'
//               and DependenceDiagnosis in Global."EncounterDiagnosis" ( Telehealth ) ) TelehealthEncounter
//           return Procedure { performed: TelehealthEncounter.period }
//       )

// define "Treatment Initiation With Medication Order":
//   [MedicationRequest: "Opiate Antagonists"] TreatmentInitiatedWithMedication
//       with "First Dependence Diagnosis During Measurement Period" FirstDiagnosed
//         such that TreatmentInitiatedWithMedication.status in { 'active', 'completed' }
//           and TreatmentInitiatedWithMedication.intent = 'order'
//           and CMD."MedicationPeriod" ( TreatmentInitiatedWithMedication ) starts 14 days or less on or after day of start of QICoreCommon."ToPrevalenceInterval" ( FirstDiagnosed )

