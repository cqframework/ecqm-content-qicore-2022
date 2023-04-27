library DischargedonAntithromboticTherapyFHIR version '0.8.000'

/* based upon FHIR library DischargedonAntithromboticTherapyFHIR4 version '0.4.000' */


using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include CQMCommon version '1.0.000' called CQMCommon
include QICoreCommon version '1.2.000' called QICoreCommon
include SupplementalDataElements version '3.1.000' called SDE
include TJCOverall version '8.3.000' called TJC

valueset "Antithrombotic Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.62'
valueset "Medical Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.473'
valueset "Patient Refusal": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.93'
valueset "Pharmacological Contraindications For Antithrombotic Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.52'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2022-01-01T00:00:00.000Z, @2023-01-01T00:00:00.000Z)

context Patient
  
/*==============================================================================*/


define "Initial Population":
  TJC."Encounter with Principal Diagnosis and Age"
  
/*==============================================================================*/


define "Denominator":
  TJC."Ischemic Stroke Encounter"
  
/*==============================================================================*/


define "Denominator Exclusions":
  TJC."Ischemic Stroke Encounters with Discharge Disposition"
    union "Encounter with Comfort Measures during Hospitalization for Patients with Documented Ischemic Stroke"
//    union TJC."Encounter with Comfort Measures during Hospitalization"
/*union {
        TJC."Ischemic Stroke Encounter" Encounter
        with TJC."Intervention Comfort Measures" ComfortMeasure
            such that Coalesce(start of QICoreCommon."ToInterval"(ComfortMeasure.performed), ComfortMeasure.authoredOn) during CQMCommon."HospitalizationWithObservation" ( Encounter )
    }
*/



define "Encounter with Comfort Measures during Hospitalization for Patients with Documented Ischemic Stroke":
  "Denominator" Encounter
    with TJC."Intervention Comfort Measures" ComfortMeasure
      such that Coalesce(start of QICoreCommon."ToInterval"(ComfortMeasure.performed), ComfortMeasure.authoredOn) during CQMCommon."HospitalizationWithObservation" ( Encounter )
  
/*==============================================================================*/


define "Numerator":
  TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Antithrombotic Therapy at Discharge" DischargeAntithrombotic
      such that DischargeAntithrombotic.authoredOn during IschemicStrokeEncounter.period

define "Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic
    where exists ( Antithrombotic.category C
        where C ~ QICoreCommon."Community"
          or C ~ QICoreCommon."Discharge"
    )
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent = 'order'
      and Antithrombotic.doNotPerform is not true
/*==============================================================================*/


define "Denominator Exceptions":
  "Encounter with No Antithrombotic At Discharge"
    union "Encounter with Pharmacological Contraindications for Antithrombotic Therapy at Discharge"

define "Encounter with No Antithrombotic At Discharge":
  TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Reason for Not Giving Antithrombotic at Discharge" NoDischargeAntithrombotic
      such that NoDischargeAntithrombotic.authoredOn during IschemicStrokeEncounter.period

define "Reason for Not Giving Antithrombotic at Discharge":
  ["MedicationNotRequested": medication in "Antithrombotic Therapy"] NoAntithromboticDischarge
    where ( NoAntithromboticDischarge.reasonCode in "Medical Reason"
        or NoAntithromboticDischarge.reasonCode in "Patient Refusal"
    )
      and exists ( NoAntithromboticDischarge.category C
          where C ~ QICoreCommon."Community"
            or C ~ QICoreCommon."Discharge"
      )
      and NoAntithromboticDischarge.intent = 'order'

define "Encounter with Pharmacological Contraindications for Antithrombotic Therapy at Discharge":
  TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Pharmacological Contraindications for Antithrombotic Therapy at Discharge" DischargePharmacological
      such that DischargePharmacological.authoredOn during IschemicStrokeEncounter.period

define "Pharmacological Contraindications for Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Pharmacological Contraindications For Antithrombotic Therapy"] Pharmacological
    where exists ( Pharmacological.category C
        where C ~ QICoreCommon."Community"
          or C ~ QICoreCommon."Discharge"
    )
      and Pharmacological.status in { 'active', 'completed' }
      and Pharmacological.intent = 'order'
      and Pharmacological.doNotPerform is not true

/*==============================================================================*/


define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"