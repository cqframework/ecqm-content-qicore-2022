library AppropriateTreatmentforSTEMIFHIR version '0.0.008'

using QICore version '4.1.1'

/*This spec aligns with AU2022/PY2023 QDM version*/


include SupplementalDataElements version '3.1.000' called SDE
include QICoreCommon version '1.2.000' called QICoreCommon
include FHIRHelpers version '4.1.000' called FHIRHelpers
include CQMCommon version '1.0.000' called CQMCommon

codesystem "LOINC": 'http://loinc.org'
codesystem "HSLOC": 'https://www.cdc.gov/nhsn/cdaportal/terminology/codesystem/hsloc.html'
codesystem "SNOMEDCT": 'http://snomed.info/sct'
codesystem "ActCode": 'http://terminology.hl7.org/CodeSystem/v3-ActCode'

valueset "Active Bleeding or Bleeding Diathesis (Excluding Menses)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.4036'
valueset "Active Peptic Ulcer": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.4031'
valueset "Adverse reaction to thrombolytics": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1170.6'
valueset "Allergy to thrombolytics": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1170.5'
valueset "Anticoagulant Medications, Oral": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.4045'
valueset "Aortic Dissection and Rupture": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.4028'
valueset "birth date": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.560.100.4'
valueset "Cardiopulmonary Arrest": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.4048'
valueset "Cerebral Vascular Lesion": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.4025'
valueset "Closed Head and Facial Trauma": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.4026'
valueset "Dementia": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.4043'
valueset "Discharge To Acute Care Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.87'
valueset "ED": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1085'
valueset "Endotracheal Intubation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.69'
valueset "Fibrinolytic Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.4020'
valueset "Intracranial or Intraspinal surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1170.2'
valueset "Ischemic Stroke": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.104.12.1024'
valueset "Major Surgical Procedure": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.4056'
valueset "Malignant Intracranial Neoplasm Group": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1170.3'
valueset "Mechanical Circulatory Assist Device": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.4052'
valueset "Neurologic impairment": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.114.12.1012'
valueset "Patient Expired": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.309'
valueset "Percutaneous Coronary Intervention": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.2000.5'
valueset "Pregnancy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.4055'
valueset "STEMI": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.3157.4017'
valueset "Thrombolytic medications": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1170.4'

code "Birthdate": '21112-8' from "LOINC" display 'Birthdate'
code "Emergency Department": '1108-0' from "HSLOC" display 'Emergency Department'
code "Patient transfer (procedure)": '107724000' from "SNOMEDCT" display 'Patient transfer (procedure)'
code "Streptokinase adverse reaction (disorder)": '293571007' from "SNOMEDCT" display 'Streptokinase adverse reaction (disorder)'
code "EMER": 'EMER' from "ActCode" display 'emergency'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
  "ED Encounter with STEMI Diagnosis" EDwithSTEMI
    where AgeInYearsAt(date from start of(EDwithSTEMI.period)) >= 18

define "Denominator":
  "Initial Population"

define "Numerator":
  "Fibrinolytic Therapy within 30 Minutes of Arrival"
    union "PCI within 90 Minutes of Arrival"
    union "ED Departure with Transfer to Acute Care Facility Within 45 Minutes of Arrival"

define "Denominator Exclusions":
  "Exclusion Diagnosis During ED Encounter or Within 24 Hours of ED Encounter Start"
    union "Intubation or Mechanical Circulatory Assist Procedure During ED Encounter or Within 24 Hours of ED Encounter Start"
    union "Major Surgical Procedure 21 Days or Less Before End of ED Encounter"
    union "Active Exclusion Diagnosis at Start of ED Encounter"
    union "Intracranial or Intraspinal Procedure 90 Days or Less Before Start of ED Encounter"
    union "Active Oral Anticoagulant Medication Overlaps Before ED Encounter"
    union "Active Exclusion Diagnosis Within 90 Days Before Start of ED Encounter"
    union "Allergy or Intolerance to Thrombolytic Medications Overlaps ED Encounter"
    union "Adverse Effect to Thrombolytic Medications Before End of ED Encounter"
    union "ED Encounter with Expired Discharge Disposition"

define "ED Encounter with Encounter Diagnosis of STEMI":
  ["Encounter": "ED"] EDEncounter
    where EDEncounter.status = 'finished'
      and EDEncounter.class ~ "EMER"
      and ( EDEncounter.reasonCode in "STEMI"
          or exists ( ( CQMCommon."EncounterDiagnosis" ( EDEncounter ) ) EncDiagnosis
              where EncDiagnosis.code in "STEMI"
          )
      )
      and EDEncounter.period during "Measurement Period"

define "ED Encounter with Diagnosis of STEMI":
  ["Encounter": "ED"] EDEncounter
    with ["Condition": "STEMI"] DxSTEMI
      such that DxSTEMI.clinicalStatus ~ QICoreCommon."active"
        and EDEncounter.status = 'finished'
        and EDEncounter.class ~ "EMER"
        and QICoreCommon."ToPrevalenceInterval" ( DxSTEMI ) starts during EDEncounter.period
        and EDEncounter.period during "Measurement Period"

define "ED Encounter with STEMI Diagnosis":
  "ED Encounter with Encounter Diagnosis of STEMI"
    union "ED Encounter with Diagnosis of STEMI"

define "Exclusion Diagnosis During ED Encounter or Within 24 Hours of ED Encounter Start":
  "ED Encounter with STEMI Diagnosis" EDwithSTEMI
    with ( ["Condition": "Aortic Dissection and Rupture"]
      union ["Condition": "Neurologic impairment"]
      union ["Condition": "Cardiopulmonary Arrest"] ) ExclusionDiagnosis
      such that ( QICoreCommon."ToPrevalenceInterval" ( ExclusionDiagnosis ) starts during EDwithSTEMI.period )
        or ( QICoreCommon."ToPrevalenceInterval" ( ExclusionDiagnosis ) starts 24 hours or less before start of EDwithSTEMI.period )
/*Did not include a status of active as any diagnosis that resolves during the ED visit would not be counted*/


define "Intubation or Mechanical Circulatory Assist Procedure During ED Encounter or Within 24 Hours of ED Encounter Start":
  "ED Encounter with STEMI Diagnosis" EDwithSTEMI
    with ( ["Procedure": "Endotracheal Intubation"]
      union ["Procedure": "Mechanical Circulatory Assist Device"] ) AirwayProcedure
      such that ( ( QICoreCommon."ToInterval" ( AirwayProcedure.performed ) starts during ( EDwithSTEMI.period ) )
          or ( QICoreCommon."ToInterval" ( AirwayProcedure.performed ) starts 24 hours or less before start of ( EDwithSTEMI.period ) )
      )
        and AirwayProcedure.status = 'completed'

define "Active Exclusion Diagnosis at Start of ED Encounter":
  "ED Encounter with STEMI Diagnosis" EDwithSTEMI
    with ( ["Condition": "Active Bleeding or Bleeding Diathesis (Excluding Menses)"]
      union ["Condition": "Malignant Intracranial Neoplasm Group"]
      union ["Condition": "Cerebral Vascular Lesion"]
      union ["Condition": "Dementia"]
      union ["Condition": "Pregnancy"]
      union ["Condition": "Allergy to thrombolytics"] ) ActiveExclusionDx
      such that ActiveExclusionDx.clinicalStatus ~ QICoreCommon."active"
        and QICoreCommon."ToPrevalenceInterval" ( ActiveExclusionDx ) overlaps before ( EDwithSTEMI.period )

define "Major Surgical Procedure 21 Days or Less Before End of ED Encounter":
  "ED Encounter with STEMI Diagnosis" EDwithSTEMI
    with ["Procedure": "Major Surgical Procedure"] MajorSurgery
      such that QICoreCommon."ToInterval" ( MajorSurgery.performed ) starts 21 days or less before end of ( EDwithSTEMI.period )
        and MajorSurgery.status = 'completed'

define "Intracranial or Intraspinal Procedure 90 Days or Less Before Start of ED Encounter":
  "ED Encounter with STEMI Diagnosis" EDwithSTEMI
    with ["Procedure": "Intracranial or Intraspinal surgery"] CranialorSpinalSurgery
      such that QICoreCommon."ToInterval" ( CranialorSpinalSurgery.performed ) starts 90 days or less before start of ( EDwithSTEMI.period )
        and CranialorSpinalSurgery.status = 'completed'

define "Active Oral Anticoagulant Medication Overlaps Before ED Encounter":
  "ED Encounter with STEMI Diagnosis" EDwithSTEMI
    with ["MedicationRequest": "Anticoagulant Medications, Oral"] OralAnticoagulant
      such that OralAnticoagulant.status = 'active'
        and OralAnticoagulant.intent = 'order'
        and OralAnticoagulant.authoredOn before start of EDwithSTEMI.period
    /*cannot use overlaps for a single point in time*/


define "Active Exclusion Diagnosis Within 90 Days Before Start of ED Encounter":
  "ED Encounter with STEMI Diagnosis" EDwSTEMI
    with ( ["Condition": "Ischemic Stroke"]
      union ["Condition": "Closed Head and Facial Trauma"]
      union ["Condition": "Active Peptic Ulcer"]
      union ["Condition": "Cardiopulmonary Arrest"] ) ExclusionCondition
      such that ExclusionCondition.clinicalStatus ~ QICoreCommon."active"
        and QICoreCommon."ToPrevalenceInterval" ( ExclusionCondition ) overlaps Interval[start of ( EDwSTEMI.period ) - 90 days, start of ( EDwSTEMI.period )]

define "Allergy or Intolerance to Thrombolytic Medications Overlaps ED Encounter":
  "ED Encounter with STEMI Diagnosis" EDwSTEMI
    with ["AllergyIntolerance": "Thrombolytic medications"] ThrombolyticAllergy
      such that ThrombolyticAllergy.clinicalStatus ~ QICoreCommon."active"
        and QICoreCommon."ToInterval" ( ThrombolyticAllergy.onset ) overlaps ( EDwSTEMI.period )

define "Adverse Effect to Thrombolytic Medications Before End of ED Encounter":
  "ED Encounter with STEMI Diagnosis" EDwSTEMI
    with [AdverseEvent: event in "Thrombolytic medications"] ThrombolyticAdverseEvent
      such that ThrombolyticAdverseEvent.category in "Adverse reaction to thrombolytics"
        and ThrombolyticAdverseEvent.recordedDate before end ( EDwSTEMI.period )
        and ThrombolyticAdverseEvent.actuality = 'actual'

define "ED Departure with Transfer to Acute Care Facility Within 45 Minutes of Arrival":
  "ED Encounter with STEMI Diagnosis" EDwithSTEMI
    where ( EDwithSTEMI.period ) ends 45 minutes or less after start of ( EDwithSTEMI.period )
      and EDwithSTEMI.hospitalization.dischargeDisposition in "Discharge To Acute Care Facility"

define "ED Encounter with Expired Discharge Disposition":
  "ED Encounter with STEMI Diagnosis" EDwithSTEMI
    where EDwithSTEMI.hospitalization.dischargeDisposition in "Patient Expired"

define "Fibrinolytic Therapy within 30 Minutes of Arrival":
  "ED Encounter with STEMI Diagnosis" EDwithSTEMI
    with ["MedicationAdministration": "Fibrinolytic Therapy"] Fibrinolytic
      such that Fibrinolytic.status = 'completed'
        and start of ( QICoreCommon."ToInterval" ( Fibrinolytic.effective ) ) 30 minutes or less after start of ( EDwithSTEMI.period )

define "PCI within 90 Minutes of Arrival":
  "ED Encounter with STEMI Diagnosis" EDwithSTEMI
    with ["Procedure": "Percutaneous Coronary Intervention"] PCI
      such that QICoreCommon."ToInterval" ( PCI.performed ) starts 90 minutes or less after start of ( EDwithSTEMI.period )
        and PCI.status = 'completed'

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"