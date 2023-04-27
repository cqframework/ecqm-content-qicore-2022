library PCSDepressionScreenAndFollowUpFHIR version '0.0.017'

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include SupplementalDataElements version '3.1.000' called SDE
include FHIRCommon version '4.1.000' called FHIRCommon
include QICoreCommon version '1.2.000' called QICoreCommon

codesystem "ConditionClinicalStatusCodes": 'http://terminology.hl7.org/CodeSystem/condition-clinical'
codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMEDCT": 'http://snomed.info/sct'

valueset "Adolescent Depression Medications": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1567'
valueset "Adult Depression Medications": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1566'
valueset "Bipolar Disorder": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.67.1.101.1.128'
valueset "Encounter to Screen for Depression": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1916'
valueset "Follow Up for Adolescent Depression": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1569'
valueset "Follow Up for Adult Depression": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1568'
valueset "Medical Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1007'
valueset "Patient Declined": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1582'
valueset "Physical Therapy Evaluation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1022'
valueset "Referral for Adolescent Depression": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1570'
valueset "Referral for Adult Depression": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1571'
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080'

code "active": 'active' from "ConditionClinicalStatusCodes" display 'active'
code "Adolescent depression screening assessment": '73831-0' from "LOINC" display 'Adolescent depression screening assessment'
code "Adult depression screening assessment": '73832-8' from "LOINC" display 'Adult depression screening assessment'
code "Birth date": '21112-8' from "LOINC" display 'Birth date'
code "Depression screening declined (situation)": '720834000' from "SNOMEDCT" display 'Depression screening declined (situation)'
code "Depression screening negative (finding)": '428171000124102' from "SNOMEDCT" display 'Depression screening negative (finding)'
code "Depression screening positive (finding)": '428181000124104' from "SNOMEDCT" display 'Depression screening positive (finding)'
code "recurrence": 'recurrence' from "ConditionClinicalStatusCodes" display 'recurrence'
code "relapse": 'relapse' from "ConditionClinicalStatusCodes" display 'relapse'
code "remission": 'remission' from "ConditionClinicalStatusCodes" display 'remission'
code "Screening declined (situation)": '31021000119100' from "SNOMEDCT" display 'Screening declined (situation)'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  "Initial Population"

define "Denominator Exceptions":
  ( exists "Medical or Patient Reason for Not Screening Adolescent for Depression"
      and not "Has Adolescent Depression Screening"
  )
    or ( exists "Medical or Patient Reason for Not Screening Adult for Depression"
        and not "Has Adult Depression Screening"
    )

define "Patient Age 12 to 16 Years at Start of Measurement Period":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[12, 16]

define "Patient Age 12 Years or Older at Start of Measurement Period":
  AgeInYearsAt(date from start of "Measurement Period") >= 12

define "Patient Age 17 Years at Start of Measurement Period":
  AgeInYearsAt(date from start of "Measurement Period") = 17

define "Patient Age 18 Years or Older at Start of Measurement Period":
  AgeInYearsAt(date from start of "Measurement Period") >= 18

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

define "History of Bipolar Diagnosis Before Qualifying Encounter":
  [Condition: "Bipolar Disorder"] BipolarDiagnosis
    with "Qualifying Encounter During Measurement Period" QualifyingEncounter
      such that QICoreCommon."ToPrevalenceInterval" ( BipolarDiagnosis ) starts before QualifyingEncounter.period
    where ( BipolarDiagnosis.clinicalStatus ~ FHIRCommon."active"
        or BipolarDiagnosis.clinicalStatus ~ FHIRCommon."recurrence"
        or BipolarDiagnosis.clinicalStatus ~ FHIRCommon."relapse"
        or BipolarDiagnosis.clinicalStatus ~ FHIRCommon."remission"
    )

define "Has Most Recent Adolescent Screening Negative":
  ( "Most Recent Adolescent Depression Screening" AdolescentScreen
      where AdolescentScreen.value ~ "Depression screening negative (finding)"
  ) is not null

define "Has Most Recent Adult Screening Negative":
  ( "Most Recent Adult Depression Screening" AdultScreen
      where AdultScreen.value ~ "Depression screening negative (finding)"
  ) is not null

define "Follow Up Intervention for Positive Adolescent Depression Screening":
  [MedicationRequest: "Adolescent Depression Medications"]
    union [ServiceRequest: code in "Referral for Adolescent Depression"]
    union [Procedure: "Follow Up for Adolescent Depression"]

define "Follow Up Intervention for Positive Adult Depression Screening":
  [MedicationRequest: "Adult Depression Medications"]
    union [ServiceRequest: code in "Referral for Adult Depression"]
    union [Procedure: "Follow Up for Adult Depression"]

define "Qualifying Encounter During Measurement Period":
  ( [Encounter: "Encounter to Screen for Depression"]
    union [Encounter: "Physical Therapy Evaluation"]
    union [Encounter: "Telephone Visits"] ) QualifyingEncounter
    where QualifyingEncounter.period during "Measurement Period"
      and QualifyingEncounter.status = 'finished'

define "Denominator Exclusions":
  exists "History of Bipolar Diagnosis Before Qualifying Encounter"

define "Has Adolescent Depression Screening":
  exists ( [Observation: "Adolescent depression screening assessment"] AdolescentScreening
      with "Qualifying Encounter During Measurement Period" QualifyingEncounter
        such that QICoreCommon."ToInterval" ( AdolescentScreening.effective ) 14 days or less on or before day of start of QualifyingEncounter.period
          and AdolescentScreening.value is not null
  )

define "Has Adult Depression Screening":
  exists ( [Observation: "Adult depression screening assessment"] AdultScreening
      with "Qualifying Encounter During Measurement Period" QualifyingEncounter
        such that QICoreCommon."ToInterval" ( AdultScreening.effective ) 14 days or less on or before day of start of QualifyingEncounter.period
          and AdultScreening.value is not null
  )

define "Most Recent Adolescent Depression Screening":
  Last([Observation: "Adolescent depression screening assessment"] AdolescentDepressionScreening
      with "Qualifying Encounter During Measurement Period" QualifyingEncounter
        such that QICoreCommon."ToInterval"(AdolescentDepressionScreening.effective) 14 days or less on or before day of start of QualifyingEncounter.period
          and AdolescentDepressionScreening.value is not null
      sort by start of QICoreCommon."ToInterval"(effective)
  )

define "Most Recent Adult Depression Screening":
  Last([Observation: "Adult depression screening assessment"] AdultDepressionScreening
      with "Qualifying Encounter During Measurement Period" QualifyingEncounter
        such that QICoreCommon."ToInterval"(AdultDepressionScreening.effective) 14 days or less on or before day of start of QualifyingEncounter.period
          and AdultDepressionScreening.value is not null
      sort by start of QICoreCommon."ToInterval"(effective)
  )

define "Numerator":
  ( "Patient Age 12 to 16 Years at Start of Measurement Period"
      and ( "Has Most Recent Adolescent Screening Negative"
          or exists "Most Recent Adolescent Depression Screening Positive and Follow Up Provided"
      )
  )
    or ( "Patient Age 17 Years at Start of Measurement Period"
        and ( "Has Most Recent Adolescent Screening Negative"
            or exists "Most Recent Adolescent Depression Screening Positive and Follow Up Provided"
            or "Has Most Recent Adult Screening Negative"
            or exists "Most Recent Adult Depression Screening Positive and Follow Up Provided"
        )
    )
    or ( "Patient Age 18 Years or Older at Start of Measurement Period"
        and ( "Has Most Recent Adult Screening Negative"
            or exists "Most Recent Adult Depression Screening Positive and Follow Up Provided"
        )
    )

define "Initial Population":
  "Patient Age 12 Years or Older at Start of Measurement Period"
    and exists ( "Qualifying Encounter During Measurement Period" )

define "Most Recent Adolescent Depression Screening Positive and Follow Up Provided":
  from
    "Most Recent Adolescent Depression Screening" LastAdolescentScreen,
    "Follow Up Intervention for Positive Adolescent Depression Screening" FollowUpPositiveAdolescentScreen,
    "Qualifying Encounter During Measurement Period" QualifyingEncounter
    where QICoreCommon."ToInterval" ( LastAdolescentScreen.effective ) 14 days or less on or before day of start of QualifyingEncounter.period
      and LastAdolescentScreen.value ~ "Depression screening positive (finding)"
      and ( ( Coalesce(start of QICoreCommon."ToInterval"(FollowUpPositiveAdolescentScreen.performed), FollowUpPositiveAdolescentScreen.authoredOn) same day as start of QualifyingEncounter.period )
          or ( Coalesce(start of QICoreCommon."ToInterval"(FollowUpPositiveAdolescentScreen.performed), FollowUpPositiveAdolescentScreen.authoredOn) 2 days or less after day of end of QualifyingEncounter.period )
      )

define "Most Recent Adult Depression Screening Positive and Follow Up Provided":
  from
    "Most Recent Adult Depression Screening" LastAdultScreen,
    "Follow Up Intervention for Positive Adult Depression Screening" FollowUpPositiveAdultScreen,
    "Qualifying Encounter During Measurement Period" QualifyingEncounter
    where QICoreCommon."ToInterval" ( LastAdultScreen.effective ) starts 14 days or less on or before day of start of QualifyingEncounter.period
      and LastAdultScreen.value ~ "Depression screening positive (finding)"
      and ( ( Coalesce(start of QICoreCommon."ToInterval"(FollowUpPositiveAdultScreen.performed), FollowUpPositiveAdultScreen.authoredOn) same day as start of QualifyingEncounter.period )
          or ( Coalesce(start of QICoreCommon."ToInterval"(FollowUpPositiveAdultScreen.performed), FollowUpPositiveAdultScreen.authoredOn) 2 days or less after day of end of QualifyingEncounter.period )
      )

define "Medical or Patient Reason for Not Screening Adolescent for Depression":
  [ObservationNotDone: code ~ "Adolescent depression screening assessment"] NoAdolescentScreen
    with "Qualifying Encounter During Measurement Period" QualifyingEncounter
      such that NoAdolescentScreen.issued during QualifyingEncounter.period
    where ( NoAdolescentScreen.notDoneReason in "Patient Declined"
        or NoAdolescentScreen.notDoneReason in "Medical Reason"
    )
      and NoAdolescentScreen.status = 'cancelled'

define "Medical or Patient Reason for Not Screening Adult for Depression":
  [ObservationNotDone: code ~ "Adult depression screening assessment"] NoAdultScreen
    with "Qualifying Encounter During Measurement Period" QualifyingEncounter
      such that NoAdultScreen.issued during QualifyingEncounter.period
    where ( NoAdultScreen.notDoneReason in "Patient Declined"
        or NoAdultScreen.notDoneReason in "Medical Reason"
    )
      and NoAdultScreen.status = 'cancelled'