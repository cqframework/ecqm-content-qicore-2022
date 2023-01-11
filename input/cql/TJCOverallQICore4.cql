library TJCOverallQICore4 version '6.0.000'
/*
@update: BTR 2020-03-31 ->
Incremented version to 5.0.000
Updated FHIR version to 4.0.1

@update: BTR 2021-07-02 ->
Incremented GCL version to 6.0.000
Applied 2021 AU changes

@update: BTR 2022-05-26 ->
Refresh from 2022 AU
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include FHIRCommon version '4.0.012' called FHIRCommon

include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include SupplementalDataElementsQICore4 version '3.0.000' called SDE

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
  default Interval[@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)
  
context Patient

define "All Stroke Encounter":
  "Non Elective Inpatient Encounter" NonElectiveEncounter
    where exists ((Global.PrincipalDiagnosis(NonElectiveEncounter)) E where E.code in "Hemorrhagic Stroke")
      or exists ((Global.PrincipalDiagnosis(NonElectiveEncounter)) E where E.code in "Ischemic Stroke")

define "All Stroke Encounter (2)":
  "Non Elective Inpatient Encounter" NonElectiveEncounter
    where NonElectiveEncounter.principalDiagnosis().code in "Hemorrhagic Stroke"
      or NonElectiveEncounter.principalDiagnosis().code in "Ischemic Stroke"

define "Ischemic Stroke Encounter":
  "Encounter with Principal Diagnosis and Age" EncounterWithAge
		where Global.PrincipalDiagnosis(EncounterWithAge).code in "Ischemic Stroke"

define "Ischemic Stroke Encounters with Discharge Disposition":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
		where IschemicStrokeEncounter.hospitalization.dischargeDisposition in "Discharge To Acute Care Facility"
			or IschemicStrokeEncounter.hospitalization.dischargeDisposition in "Left Against Medical Advice"
			or IschemicStrokeEncounter.hospitalization.dischargeDisposition in "Patient Expired"
			or IschemicStrokeEncounter.hospitalization.dischargeDisposition in "Discharged to Home for Hospice Care"
			or IschemicStrokeEncounter.hospitalization.dischargeDisposition in "Discharged to Health Care Facility for Hospice Care"

define "Non Elective Inpatient Encounter":
  ["Encounter": "Non-Elective Inpatient Encounter"] NonElectiveEncounter
		where Global."LengthInDays"(NonElectiveEncounter.period) <= 120
			and NonElectiveEncounter.period ends during day of "Measurement Period"

define "Encounter with Principal Diagnosis and Age":
  "All Stroke Encounter" AllStrokeEncounter
    where AgeInYearsAt(date from(start of AllStrokeEncounter.period))>= 18

define "Comfort Measures during Hospitalization":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Intervention Comfort Measures" ComfortMeasure
     such that FHIRHelpers.ToDateTime(Coalesce(ComfortMeasure.performed as dateTime, ComfortMeasure.authoredOn)) during Global."HospitalizationWithObservation"(IschemicStrokeEncounter)
//      such that (Coalesce(ComfortMeasure.performed, ComfortMeasure.authoredOn)) during Global."HospitalizationWithObservation"(IschemicStrokeEncounter)
//     A named type is required in this context (line 70, col 77) 
//     Could not resolve call to operator ToDateTime with signature dateTime 
//     Could not resolve call to operator ToDateTime with signature (choice<System.DateTime.interval<System.DateTime>>).  

define "Encounter with Comfort Measures during Hospitalization":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Intervention Comfort Measures" ComfortMeasure
     such that Coalesce((start of Global."Normalize Interval"(ComfortMeasure.performed)), ComfortMeasure.authoredOn) during Global."HospitalizationWithObservation" ( IschemicStrokeEncounter )
//      such that Coalesce((start of ComfortMeasure.performed), ComfortMeasure.authoredOn) during Global."HospitalizationWithObservation" ( IschemicStrokeEncounter )
//      Could not resolve call to operator Normalize interval with signature (choice<System.DateTime.interval<System.DateTime>>).
//      Could not resolve call to operator ToInterval with signature (choice<System.DateTime.interval<System.DateTime>>).

define "Intervention Comfort Measures":
  ( ["ServiceRequest": "Comfort Measures"] P
      where P.intent = 'order'
       and P.status in { 'active', 'on-hold', 'completed'}
  )
    union ( ["Procedure": "Comfort Measures"] InterventionPerformed
        where InterventionPerformed.status in { 'completed', 'in-progress' }
    )

define function "TruncateTime"(Value DateTime ):
  DateTime(year from Value, month from Value, day from Value, 0, 0, 0, 0, timezoneoffset from Value)

define function "CalendarDayOfOrDayAfter"(StartValue DateTime ):
  Interval["TruncateTime"(StartValue), "TruncateTime"(StartValue + 2 days))

define function "HospitalizationWithObservationLengthofStay"(Encounter "Encounter"):
  Global."LengthInDays"(Global."HospitalizationWithObservation"(Encounter))
