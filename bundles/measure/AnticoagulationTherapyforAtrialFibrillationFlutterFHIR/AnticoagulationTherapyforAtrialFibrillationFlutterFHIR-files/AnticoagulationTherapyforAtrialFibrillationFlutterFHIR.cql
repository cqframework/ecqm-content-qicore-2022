library AnticoagulationTherapyforAtrialFibrillationFlutterFHIR version '0.2.000'

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include CQMCommon version '1.0.000' called CQMCommon
include QICoreCommon version '1.2.000' called QICoreCommon
include SupplementalDataElements version '3.1.000' called SDE
include TJCOverall version '8.3.000' called TJC

valueset "Anticoagulant Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.200'
valueset "Atrial Ablation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.203'
valueset "Atrial Fibrillation/Flutter": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.202'
valueset "Discharge To Acute Care Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.87'
valueset "Discharged to Health Care Facility for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.207'
valueset "Discharged to Home for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.209'
valueset "Emergency Department Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.292'
valueset "Hemorrhagic Stroke": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.212'
valueset "Ischemic Stroke": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.247'
valueset "Left Against Medical Advice": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.308'
valueset "Medical Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.473'
valueset "Non-Elective Inpatient Encounter": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.424'
valueset "Patient Expired": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.309'
valueset "Patient Refusal": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.93'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2022-01-01T00:00:00.000Z, @2023-01-01T00:00:00.000Z)

context Patient

/* I N I T I A L   P O P U L A T I O N ==================================================================================================================================================*/


define "Initial Population":
  TJC."Encounter with Principal Diagnosis and Age"

/* D E N O M I N A T O R =================================================================================================================================================================*/


define "Denominator":
  "Encounter with Atrial Ablation Procedure"
    union "Encounter with a History of Atrial Fibrillation or Flutter"
    union "Encounter with Current Diagnosis Code of Atrial Fibrillation or Flutter"

define "Encounter with Atrial Ablation Procedure":
  TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
    where exists ( ["Procedure": "Atrial Ablation"] AtrialAblation
        where QICoreCommon."ToInterval" ( AtrialAblation.performed ) starts before start of IschemicStrokeEncounter.period
          and AtrialAblation.status = 'completed'
    )

define "Encounter with a History of Atrial Fibrillation or Flutter":
  TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
    with ["Condition": "Atrial Fibrillation/Flutter"] AtrialFibrillationFlutter
      such that QICoreCommon."ToInterval" ( AtrialFibrillationFlutter.onset ) starts on or before end of IschemicStrokeEncounter.period
                /* try when fluent ready: such that AtrialFibrilationFlutter.prevalenceInterval() starts on or before end of IschemicStrokeEncounter.period */


define "Encounter with Current Diagnosis Code of Atrial Fibrillation or Flutter":
  TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
    where CQMCommon.EncounterDiagnosis ( IschemicStrokeEncounter ).code in "Atrial Fibrillation/Flutter"

/* D E N O M I N A T O R   E X C L U S I O N S ============================================================================================================================================*/


define "Denominator Exclusions":
  ( "Denominator" Encounter
      where Encounter.status = 'finished'
        and ( Encounter.hospitalization.dischargeDisposition in "Discharge To Acute Care Facility"
            or Encounter.hospitalization.dischargeDisposition in "Left Against Medical Advice"
            or Encounter.hospitalization.dischargeDisposition in "Patient Expired"
            or Encounter.hospitalization.dischargeDisposition in "Discharged to Home for Hospice Care"
            or Encounter.hospitalization.dischargeDisposition in "Discharged to Health Care Facility for Hospice Care"
        )
  )
    union "Encounter with Comfort Measures during Hospitalization for Patients with Documented Atrial Fibrillation or Flutter"

define "Encounter with Comfort Measures during Hospitalization for Patients with Documented Atrial Fibrillation or Flutter":
  "Denominator" Encounter
    with TJC."Intervention Comfort Measures" ComfortMeasure
      such that Coalesce(start of QICoreCommon."ToInterval"(ComfortMeasure.performed), ComfortMeasure.authoredOn) during CQMCommon."HospitalizationWithObservation" ( Encounter )
                    

/* N U M E R A T O R ================================================================================================================================================*/


define "Numerator":
  "Denominator" Encounter
    with ["MedicationRequest": "Anticoagulant Therapy"] DischargeAnticoagulant
      such that DischargeAnticoagulant.authoredOn during Encounter.period
        and DischargeAnticoagulant.status in { 'active', 'completed' }
        and DischargeAnticoagulant.doNotPerform is not true
        and exists ( DischargeAnticoagulant.category C
            where C ~ QICoreCommon."Community"
              or C ~ QICoreCommon."Discharge"
        )
        and DischargeAnticoagulant.intent = 'order'

                
/* D E N O M I N A T O R   E X C E P T I O N S ============================================================================================================================================*/


define "Denominator Exceptions":
  "Denominator" Encounter
    with "Reason for Not Giving Anticoagulant at Discharge" NoDischargeAnticoagulant
      such that NoDischargeAnticoagulant.authoredOn during Encounter.period

define "Reason for Not Giving Anticoagulant at Discharge":
  ["MedicationNotRequested": medication in "Anticoagulant Therapy"] NoAnticoagulant
    where NoAnticoagulant.status = 'completed'
      and ( NoAnticoagulant.reasonCode in "Medical Reason"
          or NoAnticoagulant.reasonCode in "Patient Refusal"
      )

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"