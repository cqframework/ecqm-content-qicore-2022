library DischargedonAntithromboticTherapyQICore4 version '0.0.006'

/* based upon FHIR library DischargedonAntithromboticTherapyFHIR4 version '0.4.000'
PJM - updated to QICore, shared libraries, valuesets, default Interval to 2022
Definition names with 'DISPLAY' are used to display pertinent data
*/

using QICore version '4.1.1'

include FHIRCommon version '4.0.012' called FHIRCommon
include FHIRHelpers version '4.0.012' called FHIRHelpers
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include QICoreCommon version '1.0.000' called QICoreCommon
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
//include TJCOverallQICore4 version '6.0.000' called TJC

valueset "Antithrombotic Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.62' 
valueset "Medical Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.473' 
valueset "Patient Refusal": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.93' 
valueset "Pharmacological Contraindications For Antithrombotic Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.52'

//from TJCOverall
valueset "Comfort Measures": 'http://cts.nlm.nih.gov/fhir/ValueSet/1.3.6.1.4.1.33895.1.3.0.45'
valueset "Discharge To Acute Care Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.87'
valueset "Discharged to Health Care Facility for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.207'
valueset "Discharged to Home for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.209'
valueset "Emergency Department Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.292'
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
valueset "Hemorrhagic Stroke": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.212'
valueset "Ischemic Stroke": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.247'
valueset "Left Against Medical Advice": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.308'
valueset "Non-Elective Inpatient Encounter": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.424'
valueset "Observation Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1111.143'
valueset "Patient Expired": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.309'
valueset "Ticagrelor Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.39'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2022-01-01T00:00:00.0, @2023-01-01T00:00:00.0)

context Patient

define "Initial Population":
  "Encounter with Principal Diagnosis and Age" 
//ORIG TJC."Encounter with Principal Diagnosis and Age"   

// PJM - fix for AgeInYearsAt issue
//FIX current problem with AgeInYearsAt required a modified approach - refer to https://github.com/cqframework/ecqm-content-qicore-2022/issues/6
define "Encounter with Principal Diagnosis and Age":
  "All Stroke Encounter" AllStrokeEncounter
    where CalculateAgeInYearsAt ( Patient.birthDate, date from start of AllStrokeEncounter.period ) >= 18
//ORIG    where AgeInYearsAt(date from(start of AllStrokeEncounter.period))>= 18

//TJCOverall
define "Non Elective Inpatient Encounter":
  ["Encounter": "Non-Elective Inpatient Encounter"] NonElectiveEncounter
		where Global."LengthInDays"(NonElectiveEncounter.period) <= 120
			and NonElectiveEncounter.period ends during day of "Measurement Period"

//TJCOverall - needs fix to Global."PrincipalDiagnosis", should not need to search Condition again and not tied to Dx 
define "All Stroke Encounter":
  "Non Elective Inpatient Encounter" NonElectiveEncounter
    let EncPrincipalDx: Global."PrincipalDiagnosis"(NonElectiveEncounter)
    where NonElectiveEncounter.status ~ 'finished'
      and exists (
            (["Condition": "Hemorrhagic Stroke"]
              union ["Condition": "Ischemic Stroke"]) StrokeCondition
            where StrokeCondition.verificationStatus ~ QICoreCommon."confirmed"
            )   
/*Original before QICore
define "All Stroke Encounter"
"Non Elective Inpatient Encounter" NonElectiveEncounter
  where exists ( NonElectiveEncounter.diagnoses Diagnosis
      where Diagnosis.rank = 1
        and ( Diagnosis.code in "Hemorrhagic Stroke"
            or Diagnosis.code in "Ischemic Stroke"
        )
  )*/

define "Denominator":
  "Ischemic Stroke Encounter"

//TJCOverall - needs fix to Global."PrincipalDiagnosis", should not need to search Condition again and not tied to Dx
define "Ischemic Stroke Encounter":
  "Encounter with Principal Diagnosis and Age" EncounterWithAge
    let EncPrincipalDx: Global."PrincipalDiagnosis"(EncounterWithAge)
     where EncounterWithAge.status = 'finished'
        and exists ["Condition": "Ischemic Stroke"] 
/*Original before QICore
define "Ischemic Stroke Encounter":
  "Encounter with Principal Diagnosis and Age" EncounterWithAge
		where Global."PrincipalDiagnosis"(EncounterWithAge).code in "Ischemic Stroke"
*/

//TJCOverall
//See if can work old way after Bryn gets Coalesce to work
define "Denominator Exclusions":
"Ischemic Stroke Encounters with Discharge Disposition"
union "Encounter with Comfort Measure Procedure during Hospitalization"
union "Encounter with Comfort Measure ServiceRequest during Hospitalization"
/*Original before QICore
define "Denominator Exclusions":
  TJC."Ischemic Stroke Encounters with Discharge Disposition"
    union TJC."Encounter with Comfort Measures during Hospitalization"
*/

//TJCOverall
define "Ischemic Stroke Encounters with Discharge Disposition":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    let EncDischDisp: IschemicStrokeEncounter.hospitalization.dischargeDisposition
        where EncDischDisp in "Discharge To Acute Care Facility"
           or EncDischDisp in "Left Against Medical Advice"
           or EncDischDisp in "Patient Expired"
           or EncDischDisp in "Discharged to Home for Hospice Care"
           or EncDischDisp in "Discharged to Health Care Facility for Hospice Care"
/*Original before QICore
...added the let...
*/

/* Could not resolve ComfortMeasure - performed is a choice, Bryn working on a solution.
define "DISPLAY Comfort Measures during Hospitalization":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Intervention Comfort Measures" ComfortMeasure
     such that Coalesce(ComfortMeasure.performed, ComfortMeasure.authoredOn) during Global."HospitalizationWithObservation"(IschemicStrokeEncounter)
     return Tuple {
       comfMeasPerformed: ComfortMeasure.performed,
       comfmeasPerfToInt: QICoreCommon."ToInterval"(ComfortMeasure.performed),
       comfMeasAuthoredOn: ComfortMeasure.authoredOn,
       comfMeasCoalesce: Coalesce((start of QICoreCommon."ToInterval"(ComfortMeasure.performed)), ComfortMeasure.authoredOn),
       hospitalization: Global."HospitalizationWithObservation" ( IschemicStrokeEncounter )
     } 
*/     
//TRIED    such that Coalesce(FHIRHelpers.ToDateTime(ComfortMeasure.performed as FHIR.dateTime), ComfortMeasure.authoredOn)) during Global."HospitalizationWithObservation"(IschemicStrokeEncounter)
/*Original before QICore...This is not used, had to split (see below)
define "Comfort Measures during Hospitalization":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
          with "Intervention Comfort Measures" ComfortMeasure
              such that FHIRHelpers.ToDateTime(Coalesce(ComfortMeasure.performed as dateTime,ComfortMeasure.authoredOn)) during Global."HospitalizationWithObservation"(IschemicStrokeEncounter)
*/

//TJCOverall - needs Coalesce fix
define "Encounter with Comfort Measures during Hospitalization":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Intervention Comfort Measures" ComfortMeasure
     such that Coalesce((start of QICoreCommon."ToInterval"(ComfortMeasure.performed)), ComfortMeasure.authoredOn) during Global."HospitalizationWithObservation" ( IschemicStrokeEncounter )
/*Original before QICore...Note: This is not used, could not get coalesce to work...instead split (see below)
define "Encounter with Comfort Measures during Hospitalization":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
          with "Intervention Comfort Measures" ComfortMeasure
              such that Coalesce((start of Global."Normalize Interval"(ComfortMeasure.performed)), ComfortMeasure.authoredOn)during Global."HospitalizationWithObservation" ( IschemicStrokeEncounter )
*/

//Note: Below does not have 'as dateTime' after performed because it errored, and tried many variations
define "Encounter with Comfort Measure Procedure during Hospitalization":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Intervention Comfort Measures Procedure" ComfortMeasure
     such that start of QICoreCommon."ToInterval"(ComfortMeasure.performed) during Global."HospitalizationWithObservation" ( IschemicStrokeEncounter )

define "Encounter with Comfort Measure ServiceRequest during Hospitalization":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Intervention Comfort Measures ServiceRequest" ComfortMeasure
     such that ComfortMeasure.authoredOn during Global."HospitalizationWithObservation" ( IschemicStrokeEncounter )

//TJCOverall
//Note: Below is not used because could not get coalesce to work in "Encounter with Comfort Measures during Hospitalization"
define "Intervention Comfort Measures":
  ( ["ServiceRequest": "Comfort Measures"] P
      where P.intent = 'order'
       and P.status in { 'active', 'on-hold', 'completed'}
  )
    union ( ["Procedure": "Comfort Measures"] InterventionPerformed
        where InterventionPerformed.status in { 'completed', 'in-progress' }
    )

//Instead split ServiceRequest and Procedure into two different definitions
define "Intervention Comfort Measures ServiceRequest":
  ( ["ServiceRequest": "Comfort Measures"] P
      where P.intent = 'order'
       and P.status in { 'active', 'on-hold', 'completed'}
  )

define "Intervention Comfort Measures Procedure":
  ( ["Procedure": "Comfort Measures"] InterventionPerformed
        where InterventionPerformed.status in { 'completed', 'in-progress' }
  )

define "Numerator":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Antithrombotic Therapy at Discharge" DischargeAntithrombotic
      such that DischargeAntithrombotic.authoredOn during IschemicStrokeEncounter.period
/* Original before QICore
define "Numerator":
  TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
        with "Antithrombotic Therapy at Discharge" DischargeAntithrombotic
          such that DischargeAntithrombotic.authoredOn during IschemicStrokeEncounter.period
*/

//Note: QICore manual says to constrain status to 'active' and category to 'Community' and does not mention intent.
//      ask Yanyan if should follow that or what is below.
define "Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic
      where Antithrombotic.doNotPerform is not true
        and Antithrombotic.status in { 'active', 'completed' } 
        and Antithrombotic.intent = 'order'
        and exists (Antithrombotic.category C where 
                   C ~ QICoreCommon."Discharge" or C ~ QICoreCommon."Community")
/* Original FHIR before QICore
define "Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic
      where Antithrombotic.doNotPerform is not true
        and exists ( Antithrombotic.category C
            where FHIRHelpers.ToConcept ( C ) ~ FHIRCommon."Community"
                  or FHIRHelpers.ToConcept ( C ) ~ FHIRCommon."Discharge"
                    )
                and Antithrombotic.status in { 'active', 'completed' }
                and Antithrombotic.intent = 'order'
*/

define "Denominator Exceptions":
  "Encounter with No Antithrombotic At Discharge"
  union "Encounter with Pharmacological Contraindications for Antithrombotic Therapy at Discharge"

define "Reason for Not Giving Antithrombotic at Discharge":
  ["MedicationRequest": "Antithrombotic Therapy"] NoAntithromboticDischarge
      where NoAntithromboticDischarge.doNotPerform is true
        and ( NoAntithromboticDischarge.reasonCode in "Medical Reason"
                or NoAntithromboticDischarge.reasonCode in "Patient Refusal"
            )
        and NoAntithromboticDischarge.status in { 'completed', 'cancelled' }
        and NoAntithromboticDischarge.intent = 'order'
        and exists (NoAntithromboticDischarge.category C where 
                   C ~ QICoreCommon.Discharge or C ~ QICoreCommon.Community)
//  ["MedicationRequest": medication in "Antithrombotic Therapy"] NoAntithromboticDischarge

define "zDISPLAY Medication Request":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] NoAntithromboticDischarge
  return Tuple {
    doNotPerform: NoAntithromboticDischarge.doNotPerform,
    medication: NoAntithromboticDischarge.medication,
    reasonCode: NoAntithromboticDischarge.reasonCode,
    reasonInMed: ( NoAntithromboticDischarge.reasonCode in "Medical Reason"),
    reasonInPatRef: (NoAntithromboticDischarge.reasonCode in "Patient Refusal"),
    category: NoAntithromboticDischarge.category,
    dischargeStatus: NoAntithromboticDischarge.status,
    intent: NoAntithromboticDischarge.intent
  }

define "Encounter with No Antithrombotic At Discharge":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
  	with "Reason for Not Giving Antithrombotic at Discharge" NoDischargeAntithrombotic
  	such that NoDischargeAntithrombotic.authoredOn during IschemicStrokeEncounter.period

define "Encounter with Pharmacological Contraindications for Antithrombotic Therapy at Discharge":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
      with "Pharmacological Contraindications for Antithrombotic Therapy at Discharge" DischargePharmacological
        such that DischargePharmacological.authoredOn during IschemicStrokeEncounter.period

define "Pharmacological Contraindications for Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Pharmacological Contraindications For Antithrombotic Therapy"] Pharmacological
      where Pharmacological.doNotPerform is not true
        and exists (Pharmacological.category C where 
                   C ~ QICoreCommon.Discharge or C ~ QICoreCommon.Community)
        and Pharmacological.status in { 'active', 'completed' }
        and Pharmacological.intent = 'order'

/*Temporarily comment out so less clutter in the output
define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"
*/  
