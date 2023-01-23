library AntithromboticTherapyByEndofHospitalDay2QICore4 version '0.0.000'

/* based upon FHIR library DischargedonAntithromboticTherapyFHIR4 version '0.4.000'
PJM - updated to QICore, shared libraries, valuesets, default Interval to 2022
Definition names with 'DISPLAY' are used to display pertinent data
*/

using QICore version '4.1.1'

include QICoreCommon version '1.2.000' called FHIRCommon
include FHIRHelpers version '4.1.000' called FHIRHelpers
include CQMCommon version '1.0.000' called CQMCommon
include QICoreCommon version '1.2.000' called QICoreCommon
include SupplementalDataElements version '3.0.000' called SDE
include TJCOverallQICore4 version '6.0.000' called TJC

valueset "Antithrombotic Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.62' 
valueset "INR": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.213' 
valueset "Intravenous or Intra arterial Thrombolytic (tPA) Therapy Prior to Arrival": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.21' 
valueset "Intravenous or Intra-arterial Thrombolytic (t-PA) Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.21' 
valueset "Medical Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.473' 
valueset "Patient Refusal": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.93' 
valueset "Pharmacological Contraindications For Antithrombotic Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.52'
valueset "Thrombolytic (t-PA) Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.226' 

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
  default Interval[@2012-01-01T00:00:00.0, @2013-01-01T00:00:00.0)

context Patient

//Temporary stuff beginning
/*
define "zDISPLAY Encounter":
["Encounter"] E
  return Tuple {
    Eperiod: E.period,
    Estatus: E.status,
    Eclass:  E.class,
    Ehosp: CQMCommon."HospitalizationWithObservation" ( E )
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
  
 define "zDISPLAY Medication Administration":
["MedicationAdministration"] AntithromboticAdmin
  return Tuple {
    MAStatus: AntithromboticAdmin.status,
    MAmedication: AntithromboticAdmin.medication,
    MAeffective: AntithromboticAdmin.effective,
    MAinterval: QICoreCommon."ToInterval" (AntithromboticAdmin.effective)
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
/* Copied from MADiE 1/12/2023 */
  
/* I N I T I A L   P O P U L A T I O N ==================================================================================================================================================*/
define "Initial Population":
  TJC."Encounter with Principal Diagnosis and Age"


/* D E N O M I N A T O R =================================================================================================================================================================*/
define "Denominator":
  TJC."Ischemic Stroke Encounter"
  

/* D E N O M I N A T O R   E X C L U S I O N S ============================================================================================================================================*/
define "Denominator Exclusions":
    "Encounter Less Than Two Days"
    union "Encounter with Comfort Measures during Day of or Day After Arrival"
    union "Encounter with Comfort Measure Procedure during Day of or Day After Arrival"
    union "Encounter with Comfort Measure ServiceRequest during Day of or Day After Arrival"
    union "Encounter with Thrombolytic Therapy Given Prior To Arrival Or During Hospitalization"  


    define "Encounter Less Than Two Days":
        TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
            where CQMCommon."LengthInDays" (CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter )) < 2

                  
    define "Encounter with Comfort Measures during Day of or Day After Arrival":
        TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
            with TJC."Intervention Comfort Measures" ComfortMeasure
               such that Coalesce(start of QICoreCommon."ToInterval"(ComfortMeasure.performed), ComfortMeasure.authoredOn) during day of TJC."CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )
    
    /*Try splitting Comfort Measures because coalesce does not work...*/
    define "Encounter with Comfort Measure Procedure during Day of or Day After Arrival":
      TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
       with ["Procedure": code in "Comfort Measures"] ComfortProcedure
            such that ComfortProcedure.status in { 'completed', 'in-progress' }
            and start of QICoreCommon."ToInterval"(ComfortProcedure.performed) during day of TJC."CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )
    
    define "Encounter with Comfort Measure ServiceRequest during Day of or Day After Arrival":
      TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
       with ["ServiceRequest": code in "Comfort Measures"] ComfortServiceRequest
          such that ComfortServiceRequest.intent = 'order'
                and ComfortServiceRequest.status in { 'active', 'on-hold', 'completed'}
                and ComfortServiceRequest.authoredOn  during day of TJC."CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )

    define "Encounter with Thrombolytic Therapy Given Prior To Arrival Or During Hospitalization":
        "Encounter with Thrombolytic Therapy Medication or Procedures"
        union "Encounter with Thrombolytic Therapy Prior to Arrival"
        union "Encounter with Thrombolytic Therapy Documented As Already Given"
        

        define "Encounter with Thrombolytic Therapy Medication or Procedures":
            TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
                with "Thrombolytic Therapy Medication or Procedures" ThrombolyticTherapy
                    such that QICoreCommon."ToInterval" ( ThrombolyticTherapy.effective ) starts during 
                        Interval[ start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) - 24 hours, 
                                end of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )
    
            define "Thrombolytic Therapy Medication or Procedures":
                (["MedicationAdministration": "Thrombolytic (t-PA) Therapy"] ThrombolyticMedication
                    where ThrombolyticMedication.status in { 'in-progress', 'completed' }
                        return { id: ThrombolyticMedication.id, effective: ThrombolyticMedication.effective })
                union (["Procedure": "Intravenous or Intra-arterial Thrombolytic (t-PA) Therapy"] ThrombolyticProcedure
                    where ThrombolyticProcedure.status = 'completed'
                        return { id: ThrombolyticProcedure.id, effective: ThrombolyticProcedure.performed })
    
    
        define "Encounter with Thrombolytic Therapy Prior to Arrival":
            TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
                where exists ((CQMCommon."EncounterDiagnosis"(IschemicStrokeEncounter)) EncounterDiagnosis
                                where (EncounterDiagnosis.code in "Intravenous or Intra arterial Thrombolytic (tPA) Therapy Prior to Arrival")
                             )
    
                                          
        define "Encounter with Thrombolytic Therapy Documented As Already Given":
            TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
                with [Condition: "Intravenous or Intra arterial Thrombolytic (tPA) Therapy Prior to Arrival"] PriorTPA
                    such that PriorTPA.recordedDate during CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter )
                        and (PriorTPA.clinicalStatus ~ QICoreCommon."active"
                            or PriorTPA.clinicalStatus ~ QICoreCommon."recurrence"
                            or PriorTPA.clinicalStatus ~  QICoreCommon."relapse" )
                        and PriorTPA.verificationStatus ~ QICoreCommon."confirmed"


/* N U M E R A T O R ================================================================================================================================================*/
define "Numerator":
  "Encounter with Antithrombotic Therapy"

    define "Encounter with Antithrombotic Therapy":
        TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
            with ["MedicationAdministration": "Antithrombotic Therapy"] Antithrombotic
                such that Antithrombotic.status in { 'in-progress', 'completed' }
                and QICoreCommon."ToInterval" (Antithrombotic.effective) starts during day of TJC."CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )
                /*original FHIR - and date from (start of CQMCommon."Normalize Interval" ( Antithrombotic.effective)) during TJC."CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) ) */


/* D E N O M I N A T O R    E X C E P T I O N S =======================================================================================================================*/
define "Denominator Exceptions":
    "No Antithrombotic Ordered or Administered Day Of or Day After Hospital Arrival"
    union "Encounter with Pharmacological Contraindications for Antithrombotic Therapy Given Day Of or Day After Hospital Arrival"
    union "Encounter with An INR Greater Than 3.5"


    define "No Antithrombotic Ordered or Administered Day Of or Day After Hospital Arrival":
        TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
            with "No Antithrombotic Ordered or Administered" NoAntithrombotic
                such that NoAntithrombotic.authoredOn during day of TJC."CalendarDayOfOrDayAfter"(start of CQMCommon."HospitalizationWithObservation"(IschemicStrokeEncounter) )
            /*such that date from NoAntithrombotic.authoredOn during TJC."CalendarDayOfOrDayAfter"(start of CQMCommon."HospitalizationWithObservation"(IschemicStrokeEncounter))*/

        define "No Antithrombotic Ordered or Administered":
          "Reason for Not Ordering Antithrombotic"
          union "Reason for Not Administering Antithrombotic"

            define "Reason for Not Administering Antithrombotic":
                ["MedicationAdministrationNotDone": medication in "Antithrombotic Therapy"] MedicationAdm
                    /*let MedicationNotDoneTiming: QICoreCommon."Recorded" (MedicationAdm)*/
                    /* let MedicationNotDoneTiming: CQMCommon.GetExtension ( MedicationAdm, 'qicore-recorded' ).value */
                    where  MedicationAdm.status = 'not-done' 
                        and (MedicationAdm.statusReason in "Medical Reason"
                            or MedicationAdm.statusReason in "Patient Refusal")
                   return {id: MedicationAdm.id, authoredOn: MedicationAdm.recorded}
            
            define "Reason for Not Ordering Antithrombotic":
                ["MedicationRequest": "Antithrombotic Therapy"] NoAntithromboticOrder
                    where NoAntithromboticOrder.status = 'completed' 
                        and NoAntithromboticOrder.doNotPerform is true 
                        and (NoAntithromboticOrder.reasonCode in "Medical Reason"
                            or NoAntithromboticOrder.reasonCode in "Patient Refusal")
                return {id: NoAntithromboticOrder.id, authoredOn: NoAntithromboticOrder.authoredOn}
    


    define "Encounter with Pharmacological Contraindications for Antithrombotic Therapy Given Day Of or Day After Hospital Arrival":
        TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
            with ["MedicationAdministration": "Pharmacological Contraindications For Antithrombotic Therapy"] PharmacologicalContraindications
                such that PharmacologicalContraindications.status in { 'in-progress', 'completed' }
                    and QICoreCommon."ToInterval" (PharmacologicalContraindications.effective) starts during day of TJC."CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" (IschemicStrokeEncounter) )
    /*such that date from(Coalesce(start of CQMCommon."Normalize Interval"(ComfortMeasure.performed), ComfortMeasure.authoredOn)) during TJC."CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )*/
    
    
    define "Encounter with An INR Greater Than 3.5":
        TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
            with ["Observation": "INR"] INR
                such that INR.issued during day of TJC."CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )
                    and INR.value as Quantity > 3.5
                    and INR.status in { 'final', 'amended', 'corrected' }
    /*such that date from (INR.issued) during TJC."CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )*/

                
define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

