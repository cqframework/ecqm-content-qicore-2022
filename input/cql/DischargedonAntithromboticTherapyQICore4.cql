library DischargedonAntithromboticTherapyQICore4 version '0.0.006'

/* based upon FHIR library DischargedonAntithromboticTherapyFHIR4 version '0.4.000'
PJM - updated to QICore, shared libraries, valuesets, default Interval to 2022
Definition names with 'DISPLAY' are used to display pertinent data
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include CQMCommon version '1.1.000' called CQMCommon
include QICoreCommon version '1.3.000' called QICoreCommon
include SupplementalDataElements version '3.0.000' called SDE
include TJCOverallQICore4 version '6.0.000' called TJC

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

parameter "Measurement Period" Interval<DateTime>

context Patient

//Temporary stuff beginning
/*
define "zDISPLAY Encounter":
["Encounter"] E
  return Tuple {
    Eperiod: E.period,
    Estatus: E.status,
    Eclass:  E.class
  }
define "zDISPLAY DxP":
["Encounter"] E
let DxP: CQMCommon."PrincipalDiagnosis"(E)
  return Tuple {
    DxPVerStat: DxP.verificationStatus,
    DxPCode: DxP.code
  }  
define "zDISPLAY Condition":
[Condition] C
  return Tuple {
    Cid: C.id,
    Ccode: C.code,
    CverificationStatus: C.verificationStatus
  }  
define "zDISPLAY Procedure":
[Procedure] Px
  return Tuple {
    Pxid: Px.id,
    Pxcode: Px.code,
    Pxstatus: Px.status,
    Pxperformed: Px.performed
  }    
define "zDISPLAY Medication Request":
["MedicationRequest"] NoAntithromboticDischarge
  return Tuple {
    meta: NoAntithromboticDischarge.meta,
    doNotPerform: NoAntithromboticDischarge.doNotPerform,
    medication: NoAntithromboticDischarge.medication,
    reasonCode: NoAntithromboticDischarge.reasonCode,
    reasonInMed: ( NoAntithromboticDischarge.reasonCode in "Medical Reason"),
    reasonInPatRef: (NoAntithromboticDischarge.reasonCode in "Patient Refusal"),
    category: NoAntithromboticDischarge.category,
    dischargeStatus: NoAntithromboticDischarge.status,
    intent: NoAntithromboticDischarge.intent,
    authoredOn: NoAntithromboticDischarge.authoredOn
  }

define "zDISPLAY Comfort Measure":
    TJC."Intervention Comfort Measures" ComfortMeasure
      return Tuple {
       comfMeasPerformed: ComfortMeasure.performed,
       comfmeasPerfToInt: QICoreCommon."ToInterval"(ComfortMeasure.performed),
       comfMeasAuthoredOn: ComfortMeasure.authoredOn,
       comfMeasCoalesce: Coalesce((start of QICoreCommon."ToInterval"(ComfortMeasure.performed)), ComfortMeasure.authoredOn)
     } 
*/     
//Temporary stuff ending

/* Copied from MADiE on 1/12/2023 */
  
/*==============================================================================*/                 
define "Initial Population":
  TJC."Encounter with Principal Diagnosis and Age"
  
/*==============================================================================*/                 
define "Denominator":
  TJC."Ischemic Stroke Encounter"
  
/*==============================================================================*/                 
define "Denominator Exclusions":
    TJC."Ischemic Stroke Encounters with Discharge Disposition"
    union TJC."Encounter with Comfort Measures during Hospitalization"
  
/*==============================================================================*/                 
define "Numerator":
    TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Antithrombotic Therapy at Discharge" DischargeAntithrombotic
        such that DischargeAntithrombotic.authoredOn during IschemicStrokeEncounter.period
        
define "Antithrombotic Therapy at Discharge":
    ["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic
    where Antithrombotic.doNotPerform is not true
    and exists ( Antithrombotic.category C
        where C ~ QICoreCommon."Community"
            or  C ~ QICoreCommon."Discharge"
        )
    and Antithrombotic.status in { 'active', 'completed' }
    and Antithrombotic.intent = 'order'

/*==============================================================================*/                 
define "Denominator Exceptions":
    "Encounter with No Antithrombotic At Discharge"
    union "Encounter with Pharmacological Contraindications for Antithrombotic Therapy at Discharge"


    define "Encounter with No Antithrombotic At Discharge":
        TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
        with "Reason for Not Giving Antithrombotic at Discharge" NoDischargeAntithrombotic
            such that NoDischargeAntithrombotic.authoredOn during IschemicStrokeEncounter.period
            
        define "Reason for Not Giving Antithrombotic at Discharge":
        ["MedicationRequest": medication in "Antithrombotic Therapy"] NoAntithromboticDischarge
        where NoAntithromboticDischarge.doNotPerform is true
            and ( NoAntithromboticDischarge.reasonCode in "Medical Reason"
                or NoAntithromboticDischarge.reasonCode in "Patient Refusal"
                )
            and exists ( NoAntithromboticDischarge.category C
                where C ~ QICoreCommon."Community"
                    or  C ~ QICoreCommon."Discharge"
                )
            and NoAntithromboticDischarge.status in { 'completed', 'cancelled' }
            and NoAntithromboticDischarge.intent = 'order'


    define "Encounter with Pharmacological Contraindications for Antithrombotic Therapy at Discharge":
        TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
        with "Pharmacological Contraindications for Antithrombotic Therapy at Discharge" DischargePharmacological
            such that DischargePharmacological.authoredOn during IschemicStrokeEncounter.period
        
        define "Pharmacological Contraindications for Antithrombotic Therapy at Discharge":
            ["MedicationRequest": medication in "Pharmacological Contraindications For Antithrombotic Therapy"] Pharmacological
            where Pharmacological.doNotPerform is false
                  and exists ( Pharmacological.category C
                        where C ~ QICoreCommon."Community"
                           or C ~ QICoreCommon."Discharge"
                              )
                         and Pharmacological.status in { 'active', 'completed' }
                         and Pharmacological.intent = 'order'


/*==============================================================================*/                 
define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"
