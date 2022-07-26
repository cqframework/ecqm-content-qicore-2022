library DischargedonAntithromboticTherapyQICore4 version '0.0.000'

using QICore version '4.1.1'

include TJCOverallQICore4 version '6.0.000' called TJC
include FHIRHelpers version '4.0.012' called FHIRHelpers
include FHIRCommon version '4.0.012' called FHIRCommon
include SupplementalDataElementsQICore4 version '3.0.000' called SDE

valueset "Antithrombotic Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.62' 
valueset "Medical Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.473' 
valueset "Patient Refusal": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.93' 
valueset "Pharmacological Contraindications For Antithrombotic Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.52' 

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
  TJC."Encounter with Principal Diagnosis and Age"

define "Denominator":
  TJC."Ischemic Stroke Encounter"

define "Denominator Exclusions":
  TJC."Ischemic Stroke Encounters with Discharge Disposition"
    union TJC."Encounter with Comfort Measures during Hospitalization"

define "Numerator":
  TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
        with "Antithrombotic Therapy at Discharge" DischargeAntithrombotic
          such that DischargeAntithrombotic.authoredOn during IschemicStrokeEncounter.period

define "Denominator Exceptions":
  "Encounter with No Antithrombotic At Discharge"
              union "Encounter with Pharmacological Contraindications for Antithrombotic Therapy at Discharge"

define "Encounter with No Antithrombotic At Discharge":
  TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
  	with "Reason for Not Giving Antithrombotic at Discharge" NoDischargeAntithrombotic
  	such that NoDischargeAntithrombotic.authoredOn during IschemicStrokeEncounter.period

define "Encounter with Pharmacological Contraindications for Antithrombotic Therapy at Discharge":
  TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
      with "Pharmacological Contraindications for Antithrombotic Therapy at Discharge" DischargePharmacological
        such that DischargePharmacological.authoredOn during IschemicStrokeEncounter.period

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

define "Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic
      where Antithrombotic.doNotPerform is not true
        and exists ( Antithrombotic.category C
            where FHIRHelpers.ToConcept ( C ) ~ FHIRCommon."Community"
                  or FHIRHelpers.ToConcept ( C ) ~ FHIRCommon."Discharge" )
                and Antithrombotic.status in { 'active', 'completed' }
                and Antithrombotic.intent = 'order'

define "Reason for Not Giving Antithrombotic at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] NoAntithromboticDischarge
      where NoAntithromboticDischarge.doNotPerform is true
        and ( NoAntithromboticDischarge.reasonCode in "Medical Reason"
                or NoAntithromboticDischarge.reasonCode in "Patient Refusal"
            )
        and exists ( NoAntithromboticDischarge.category C 
            where FHIRHelpers.ToConcept ( C ) ~ FHIRCommon."Community"
                  or FHIRHelpers.ToConcept ( C ) ~ FHIRCommon."Discharge" )
            and NoAntithromboticDischarge.status in { 'completed', 'cancelled' }
            and NoAntithromboticDischarge.intent = 'order'

define "Pharmacological Contraindications for Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Pharmacological Contraindications For Antithrombotic Therapy"] Pharmacological
      where Pharmacological.doNotPerform is true
        and exists ( Pharmacological.category C 
          where FHIRHelpers.ToConcept ( C ) ~ FHIRCommon."Community"
             or FHIRHelpers.ToConcept ( C ) ~ FHIRCommon."Discharge"
            and Pharmacological.status in { 'active', 'completed' }
            and Pharmacological.intent = 'order')