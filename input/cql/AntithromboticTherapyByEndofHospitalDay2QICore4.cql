library AntithromboticTherapyByEndofHospitalDay2QICore4 version '0.0.000'

/* based upon FHIR library DischargedonAntithromboticTherapyFHIR4 version '0.4.000'
PJM - updated to QICore, shared libraries, valuesets, default Interval to 2022
Definition names with 'DISPLAY' are used to display pertinent data
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include CQMCommon version '1.0.000' called CQMCommon
include QICoreCommon version '1.2.000' called QICoreCommon
include SupplementalDataElements version '3.0.000' called SDE
//include TJCOverallQICore4 version '6.0.000' called TJC

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
valueset "Ticagrelor Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.39'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2022-01-01T00:00:00.0, @2023-01-01T00:00:00.0)

context Patient


//===========================================================================================================================
//TJCOverall PJM - fix for AgeInYearsAt issue
//FIX current problem with AgeInYearsAt required a modified approach - refer to https://github.com/cqframework/ecqm-content-qicore-2022/issues/6
define "Encounter with Principal Diagnosis and Age":
  "All Stroke Encounter" AllStrokeEncounter
    where CalculateAgeInYearsAt ( Patient.birthDate, date from start of AllStrokeEncounter.period ) >= 18
//ORIG    where AgeInYearsAt(date from(start of AllStrokeEncounter.period))>= 18

//TJCOverall
define "Non Elective Inpatient Encounter":
  ["Encounter": "Non-Elective Inpatient Encounter"] NonElectiveEncounter
		where CQMCommon."LengthInDays"(NonElectiveEncounter.period) <= 120
			and NonElectiveEncounter.period ends during day of "Measurement Period"

//TJCOverall - needs fix to CQMCommon."PrincipalDiagnosis", should not need to search Condition again and not tied to Dx 
define "All Stroke Encounter":
  "Non Elective Inpatient Encounter" NonElectiveEncounter
    let EncPrincipalDx: CQMCommon."PrincipalDiagnosis"(NonElectiveEncounter)
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

//TJCOverall 
define function "TruncateTime"(Value DateTime ):
  DateTime(year from Value, month from Value, day from Value, 0, 0, 0, 0, timezoneoffset from Value)

//TJCOverall 
define function "CalendarDayOfOrDayAfter"(StartValue DateTime ):
  Interval["TruncateTime"(StartValue), "TruncateTime"(StartValue + 2 days))

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

//TJCOverall - needs fix to CQMCommon."PrincipalDiagnosis", should not need to search Condition again and not tied to Dx
define "Ischemic Stroke Encounter":
  "Encounter with Principal Diagnosis and Age" EncounterWithAge
    let EncPrincipalDx: CQMCommon."PrincipalDiagnosis"(EncounterWithAge)
     where EncounterWithAge.status = 'finished'
        and exists ["Condition": "Ischemic Stroke"] 
/*Original before QICore
define "Ischemic Stroke Encounter":
  "Encounter with Principal Diagnosis and Age" EncounterWithAge
		where CQMCommon."PrincipalDiagnosis"(EncounterWithAge).code in "Ischemic Stroke"
*/
//---------------------------------------------------------------------------------------------------------------------------


//===========================================================================================================================
define "Initial Population":
  "Encounter with Principal Diagnosis and Age" 
//---------------------------------------------------------------------------------------------------------------------------
//===========================================================================================================================
define "Denominator":
  "Ischemic Stroke Encounter"
//---------------------------------------------------------------------------------------------------------------------------
//===========================================================================================================================
//See if can work old way after Bryn gets Coalesce to work
define "Denominator Exclusions":
  "Encounter Less Than Two Days"
    union "Encounter with Comfort Measure Procedure during Day of or Day After Arrival"
    union "Encounter with Comfort Measure ServiceRequest during Day of or Day After Arrival"
    union "Encounter with Thrombolytic Therapy Given Prior To Arrival Or During Hospitalization"
/*Original before QICore
 "Encounter Less Than Two Days"
    union "Encounter with Comfort Measures during Day of or Day After Arrival"
    union "Encounter with Thrombolytic Therapy Given Prior To Arrival Or During Hospitalization"
*/

define "Encounter Less Than Two Days":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
        where CQMCommon."LengthInDays" (CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter )) < 2

//Note: Below does not have 'as dateTime' after performed because it errored, and tried many variations
define "Encounter with Comfort Measure Procedure during Day of or Day After Arrival":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Intervention Comfort Measures Procedure" ComfortMeasure
     such that start of QICoreCommon."ToInterval"(ComfortMeasure.performed) during day of "CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )

define "Encounter with Comfort Measure ServiceRequest during Day of or Day After Arrival":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Intervention Comfort Measures ServiceRequest" ComfortMeasure
     such that ComfortMeasure.authoredOn  during day of "CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )

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

define "Encounter with Comfort Measures during Day of or Day After Arrival":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
             with "Intervention Comfort Measures" ComfortMeasure
                        such that Coalesce(start of QICoreCommon."ToInterval"(ComfortMeasure.performed), ComfortMeasure.authoredOn) 
                        during day of "CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )
          //              such that date from(Coalesce(start of CQMCommon."Normalize Interval"(ComfortMeasure.performed), ComfortMeasure.authoredOn)) during TJC."CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )


define "Encounter with Thrombolytic Therapy Given Prior To Arrival Or During Hospitalization":
  "Encounter with Thrombolytic Therapy Medication or Procedures"
    union "Encounter with Thrombolytic Therapy Prior to Arrival"
    union "Encounter with Thrombolytic Therapy Documented As Already Given"

/* Error: Target mapping in instance selectors not  yet supported 
define "Thrombolytic Therapy Medication or Procedures":
  (["MedicationAdministration": "Thrombolytic (t-PA) Therapy"] ThrombolyticMedication
    where ThrombolyticMedication.status in { 'in-progress', 'completed' }
         	return "Observation" { id: ThrombolyticMedication.id, effective: ThrombolyticMedication.effective })
  union (["Procedure": "Intravenous or Intra-arterial Thrombolytic (t-PA) Therapy"] ThrombolyticProcedure
  	where ThrombolyticProcedure.status = 'completed'
       		return "Observation" { id: ThrombolyticProcedure.id, effective: ThrombolyticProcedure.performed })
*/          
define "Thrombolytic Therapy Medication or Procedures":
  (["MedicationAdministration": "Thrombolytic (t-PA) Therapy"] ThrombolyticMedication
    where ThrombolyticMedication.status in { 'in-progress', 'completed' }
         	return { id: ThrombolyticMedication.id, effective: ThrombolyticMedication.effective })
  union (["Procedure": "Intravenous or Intra-arterial Thrombolytic (t-PA) Therapy"] ThrombolyticProcedure
  	where ThrombolyticProcedure.status = 'completed'
       		return { id: ThrombolyticProcedure.id, effective: ThrombolyticProcedure.performed })

define "Encounter with Thrombolytic Therapy Medication or Procedures":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Thrombolytic Therapy Medication or Procedures" ThrombolyticTherapy
      such that QICoreCommon."ToInterval" ( ThrombolyticTherapy.effective ) starts during 
        Interval[ start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) - 24 hours, 
                    end of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )


define "Encounter with Thrombolytic Therapy Documented As Already Given":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
        with [Condition: "Intravenous or Intra arterial Thrombolytic (tPA) Therapy Prior to Arrival"] PriorTPA
            such that PriorTPA.recordedDate during CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter )
                and (PriorTPA.clinicalStatus ~ QICoreCommon."active"
                      or PriorTPA.clinicalStatus ~ QICoreCommon."recurrence"
              			  or PriorTPA.clinicalStatus ~  QICoreCommon."relapse" )
                and PriorTPA.verificationStatus ~ QICoreCommon."confirmed"

/*Error: Could not resolve operator Exists with signature (QICore.Condition)
define "Encounter with Thrombolytic Therapy Prior to Arrival":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    where exists ((CQMCommon."EncounterDiagnosis"(IschemicStrokeEncounter)) EncounterDiagnosis
      where (EncounterDiagnosis.code in "Intravenous or Intra arterial Thrombolytic (tPA) Therapy Prior to Arrival")) */
define "Encounter with Thrombolytic Therapy Prior to Arrival":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
   with (CQMCommon."EncounterDiagnosis"(IschemicStrokeEncounter)) EncounterDiagnosis
      such that (EncounterDiagnosis.code in "Intravenous or Intra arterial Thrombolytic (tPA) Therapy Prior to Arrival")

//---------------------------------------------------------------------------------------------------------------------------
//===========================================================================================================================

define "Numerator":
  "Encounter with Antithrombotic Therapy"

define "Encounter with Antithrombotic Therapy":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
     with ["MedicationAdministration": "Antithrombotic Therapy"] Antithrombotic
        such that Antithrombotic.status in { 'in-progress', 'completed' }
            and QICoreCommon."ToInterval" ( Antithrombotic.effective) starts during day of "CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )
          //          and date from (start of CQMCommon."Normalize Interval" ( Antithrombotic.effective)) during TJC."CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )

//from STK-2 -check above to make sure has all of the necessary elements. Delete this example afterwards.
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

//=========================================================================================================================
define "Denominator Exceptions":
  "No Antithrombotic Ordered or Administered Day Of or Day After Hospital Arrival"
  union "Encounter with Pharmacological Contraindications for Antithrombotic Therapy Given Day Of or Day After Hospital Arrival"
  union "Encounter with An INR Greater Than 3.5"

define "No Antithrombotic Ordered or Administered Day Of or Day After Hospital Arrival":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "No Antithrombotic Ordered or Administered" NoAntithrombotic
      such that NoAntithrombotic.authoredOn during day of "CalendarDayOfOrDayAfter"(start of CQMCommon."HospitalizationWithObservation"(IschemicStrokeEncounter) )
              // such that date from NoAntithrombotic.authoredOn during TJC."CalendarDayOfOrDayAfter"(start of CQMCommon."HospitalizationWithObservation"(IschemicStrokeEncounter))

define "No Antithrombotic Ordered or Administered":
  "Reason for Not Ordering Antithrombotic"
    union "Reason for Not Administering Antithrombotic"

define "Reason for Not Administering Antithrombotic":
  ["MedicationAdministration": medication in "Antithrombotic Therapy"] NoAntithromboticAdmin
    where  NoAntithromboticAdmin.status = 'not-done' 
        and (NoAntithromboticAdmin.statusReason in "Medical Reason"
             or NoAntithromboticAdmin.statusReason in "Patient Refusal")
                return {id: NoAntithromboticAdmin.id, authoredOn: start of QICoreCommon."ToInterval"(NoAntithromboticAdmin.effective)}

define "Reason for Not Ordering Antithrombotic":
  ["MedicationRequest": "Antithrombotic Therapy"] NoAntithromboticOrder
    where NoAntithromboticOrder.status = 'completed' 
        and NoAntithromboticOrder.doNotPerform is true 
        and (NoAntithromboticOrder.reasonCode in "Medical Reason"
         or NoAntithromboticOrder.reasonCode in "Patient Refusal")
            return {id: NoAntithromboticOrder.id, authoredOn: NoAntithromboticOrder.authoredOn}

define "Encounter with Pharmacological Contraindications for Antithrombotic Therapy Given Day Of or Day After Hospital Arrival":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with ["MedicationAdministration": "Pharmacological Contraindications For Antithrombotic Therapy"] PharmacologicalContraindications
        such that PharmacologicalContraindications.status in { 'in-progress', 'completed' }
        and QICoreCommon."ToInterval" ( PharmacologicalContraindications.effective) starts during day of "CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )
          //          and date from (start of CQMCommon."Normalize Interval" ( PharmacologicalContraindications.effective))  during TJC."CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )

define "Encounter with An INR Greater Than 3.5":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with ["Observation": "INR"] INR
      such that INR.issued during day of "CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )
            and INR.value as Quantity > 3.5
            and INR.status in { 'final', 'amended', 'corrected' }
        //  such that date from (INR.issued) during TJC."CalendarDayOfOrDayAfter" ( start of CQMCommon."HospitalizationWithObservation" ( IschemicStrokeEncounter ) )

//--------------------------------------------------------------------------------------------------------------------------

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
