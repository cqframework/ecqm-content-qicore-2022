library PreventiveCareandScreeningInfluenzaImmunizationFHIR version '0.0.001'

/*This measure has not been tested.*/

using QICore version '4.1.1'

include FHIRHelpers version '4.0.012' called FHIRHelpers
include QICoreCommon version '1.0.000' called QICoreCommon
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include HospiceQICore4 version '3.0.000' called Hospice

valueset "Annual Wellness Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1240' 
valueset "Care Services in Long Term Residential Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1014' 
valueset "Discharge Services Nursing Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1013' 
valueset "Hemodialysis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1083' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Influenza Virus LAIV Immunization": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1087' 
valueset "Influenza Virus LAIV Procedure": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1088'  
valueset "Influenza Vaccination": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.402' 
valueset "Influenza Vaccine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1254' 
valueset "Nursing Facility Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1012' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Outpatient Consultation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1008' 
valueset "Patient Provider Interaction": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1012' 
valueset "Peritoneal Dialysis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1084' 
valueset "Preventive Care Services Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025' 
valueset "Preventive Care Services Group Counseling": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1027' 
valueset "Preventive Care Services, Initial Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1022' 
valueset "Preventive Care Services Individual Counseling": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1026' 
valueset "Preventive Care Services Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023' 
valueset "Preventive Care, Established Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1024' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 

code "Office or other outpatient visit for the evaluation and management of an established patient, that may not require the presence of a physician or other qualified health care professional. Usually, the presenting problem(s) are minimal.": '99211' from "CPT" display 'Office or other outpatient visit for the evaluation and management of an established patient, that may not require the presence of a physician or other qualified health care professional. Usually, the presenting problem(s) are minimal.'
code "Unlisted preventive medicine service": '99429' from "CPT" display 'Unlisted preventive medicine service'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
  AgeInMonthsAt( date from start of "Measurement Period" ) >= 6
          and ( exists "Qualifying Encounter During Measurement Period"
              		or exists "Hemodialysis During Measurement Period"
                or exists "Peritoneal Dialysis During Measurement Period")

define "Qualifying Encounter During Measurement Period":
  Status."Finished Encounter"(( [Encounter: "Office Visit"]
      union [Encounter: "Outpatient Consultation"]
      union [Encounter: "Care Services in Long Term Residential Facility"]
      union [Encounter: "Home Healthcare Services"]
      union [Encounter: "Patient Provider Interaction"]
      union [Encounter: "Preventive Care Services, Initial Office Visit, 0 to 17"]
      union [Encounter: "Preventive Care Services, Initial Office Visit, 18 and Up"]
      union [Encounter: "Preventive Care Services Individual Counseling"]
      union [Encounter: "Preventive Care Services Group Counseling"]
      union [Encounter: "Unlisted preventive medicine service"]
      union [Encounter: "Discharge Services Nursing Facility"]
      union [Encounter: "Nursing Facility Visit"]
      union [Encounter: "Annual Wellness Visit"]
      union [Encounter: "Preventive Care, Established Office Visit, 0 to 17"]
      union [Encounter: "Preventive Care Services Established Office Visit, 18 and Up"]
      union [Encounter: "Office or other outpatient visit for the evaluation and management of an established patient, that may not require the presence of a physician or other qualified health care professional. Usually, the presenting problem(s) are minimal."]
      union [Encounter: "Online Assessments"]
      union [Encounter: "Telephone Visits"] )) QualifyingEncounter
        	where QICoreCommon."ToInterval"(QualifyingEncounter.period) during day of "Measurement Period"

define "Hemodialysis During Measurement Period":
  Status."Completed Procedure"([Procedure: "Hemodialysis"]) Hemodialysis
              	where QICoreCommon."ToInterval"(Hemodialysis.performed) overlaps "Measurement Period"

define "Peritoneal Dialysis During Measurement Period":
  Status."Completed Procedure"([Procedure: "Peritoneal Dialysis"]) PeritonealDialysis
            where QICoreCommon."ToInterval"( PeritonealDialysis.performed) overlaps "Measurement Period"

define "Denominator":
  "Initial Population"
            and ( exists "Encounter During Influenza Season"
                or exists "Hemodialysis During Influenza Season"
                or exists "Peritoneal Dialysis During Influenza Season"
            )

define "Encounter During Influenza Season":
  Status."Finished Encounter"(([Encounter: "Annual Wellness Visit"]
  union [Encounter: "Office Visit"]
  union [Encounter: "Outpatient Consultation"]
  union [Encounter: "Care Services in Long Term Residential Facility"]
  union [Encounter: "Home Healthcare Services"]
  union [Encounter: "Preventive Care Services, Initial Office Visit, 0 to 17"]
  union [Encounter: "Preventive Care Services Initial Office Visit, 18 and Up"]
  union [Encounter: "Unlisted preventive medicine service"]
  union [Encounter: "Preventive Care Services Group Counseling"]
  union [Encounter: "Preventive Care Services Individual Counseling"]
  union [Encounter: "Discharge Services Nursing Facility"]
  union [Encounter: "Nursing Facility Visit"]
  union [Encounter: "Preventive Care, Established Office Visit, 0 to 17"]
  union [Encounter: "Preventive Care Services Established Office Visit, 18 and Up"])) FluEncounter
              		where QICoreCommon."ToInterval"(FluEncounter.period) starts during day of "Influenza Season"

define "Hemodialysis During Influenza Season":
  Status."Completed Procedure"([Procedure: "Hemodialysis"]) FluSeasonHemodialysis
            where QICoreCommon."ToInterval"(FluSeasonHemodialysis.performed ) overlaps "Influenza Season"

define "Peritoneal Dialysis During Influenza Season":
  Status."Completed Procedure"([Procedure: "Peritoneal Dialysis"]) FluSeasonPeritonealDialysis
            where QICoreCommon."ToInterval"( FluSeasonPeritonealDialysis.performed ) overlaps "Influenza Season"

define "Denominator Exclusion":
    Hospice."Has Hospice Services"

define "Numerator":
  exists "Influenza Vaccination Procedure"
              		or exists "Influenza Immunization Administered"

define "Influenza Vaccination Procedure":
  Status."Completed Procedure"(([Procedure: "Influenza Vaccination"]
      union [Procedure: "Influenza Virus LAIV Procedure"])) FluVaccination
              		where QICoreCommon."ToInterval"(FluVaccination.performed) during day of "Between July 1 of the Year Prior to the Measurement Period and June 30 of the Measurement Period"

define "Influenza Immunization Administered":
  Status."Completed Immunization"(([Immunization: "Influenza Vaccine"]
      union [Immunization: "Influenza Virus LAIV Immunization"])) AdministeredFluVaccine
              		where QICoreCommon."ToInterval"(AdministeredFluVaccine.occurrence) during day of "Between July 1 of the Year Prior to the Measurement Period and June 30 of the Measurement Period"

define "Influenza Season":
  Interval[start of "Measurement Period" - 3 months, start of "Measurement Period" + 3 months )

define "Between July 1 of the Year Prior to the Measurement Period and June 30 of the Measurement Period":
  Interval[start of "Measurement Period" - 6 months, start of "Measurement Period" + 6 months )

