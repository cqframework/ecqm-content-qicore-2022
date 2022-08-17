library PreventiveCareandScreeningTobaccoUseScreeningandCessationInterventionFHIR version '0.0.001'

/*This measure has not been tested.*/

using QICore version '4.1.1'

include FHIRHelpers version '4.0.012' called FHIRHelpers
include QICoreCommon version '1.0.000' called QICoreCommon
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include HospiceQICore4 version '3.0.000' called Hospice
include StatusFHIR version '1.0.0' called Status

codesystem "CPT": 'http://www.ama-assn.org/go/cpt' 

valueset "Annual Wellness Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1240' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Nutrition Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1006' 
valueset "Occupational Therapy Evaluation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1011' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Ophthalmological Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1285' 
valueset "Physical Therapy Evaluation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1022' 
valueset "Preventive Care Services Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025' 
valueset "Preventive Care Services Group Counseling": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1027' 
valueset "Preventive Care Services Other": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1030' 
valueset "Preventive Care Services Individual Counseling": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1026' 
valueset "Preventive Care Services Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023' 
valueset "Psych Visit Diagnostic Evaluation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1492' 
valueset "Psych Visit Psychotherapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1496' 
valueset "Psychoanalysis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1141' 
valueset "Speech and Hearing Evaluation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1530' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 
valueset "Tobacco Non User": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1189' 
valueset "Tobacco Use Cessation Counseling": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.509' 
valueset "Tobacco Use Cessation Pharmacotherapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1190' 
valueset "Tobacco Use Screening": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1278' 
valueset "Tobacco User": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1170' 

code "Health behavior assessment, or re-assessment (ie, health-focused clinical interview, behavioral observations, clinical decision making)": '96156' from "CPT" display 'Health behavior assessment, or re-assessment (ie, health-focused clinical interview, behavioral observations, clinical decision making)'
code "Health behavior intervention, individual, face-to-face; initial 30 minutes": '96158' from "CPT" display 'Health behavior intervention, individual, face-to-face; initial 30 minutes'
code "Postoperative follow-up visit, normally included in the surgical package, to indicate that an evaluation and management service was performed during a postoperative period for a reason(s) related to the original procedure": '99024' from "CPT" display 'Postoperative follow-up visit, normally included in the surgical package, to indicate that an evaluation and management service was performed during a postoperative period for a reason(s) related to the original procedure'
code "Unlisted preventive medicine service": '99429' from "CPT" display 'Unlisted preventive medicine service'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

define "Initial Population":
  AgeInYearsAt( date from start of "Measurement Period" ) >= 18
    and ( Count("Qualifying Visit During Measurement Period")>= 2
    or exists "Preventive Visit During Measurement Period"
                                        )
                                        
define "Denominator 1":
  "Initial Population"

define "Denominator Exclusion":
    Hospice."Has Hospice Services"

define "Numerator 1":
  "Most Recent Tobacco Use Screening Indicates Tobacco Non User" is not null
         or "Most Recent Tobacco Use Screening Indicates Tobacco User" is not null

define "Denominator 2":
  "Initial Population"
        and "Most Recent Tobacco Use Screening Indicates Tobacco User" is not null

define "Numerator 2":
  exists "Tobacco Cessation Counseling Given"
      or exists "Tobacco Cessation Pharmacotherapy Ordered"
      or exists "Active Pharmacotherapy for Tobacco Cessation"

define "Denominator 3":
  "Initial Population"

define "Numerator 3":
  "Most Recent Tobacco Use Screening Indicates Tobacco Non User" is not null
        or ( "Most Recent Tobacco Use Screening Indicates Tobacco User" is not null
        and ( exists "Tobacco Cessation Counseling Given"
        or exists "Tobacco Cessation Pharmacotherapy Ordered"
        or exists "Active Pharmacotherapy for Tobacco Cessation"
            )
            )

define "Active Pharmacotherapy for Tobacco Cessation":
  Status."Active Medication"([MedicationRequest: "Tobacco Use Cessation Pharmacotherapy"]) TakingCessationPharmacotherapy
        where MedicationDuration."MedicationPeriod"(TakingCessationPharmacotherapy) during day of Interval[start of "Measurement Period" - 6 months, end of "Measurement Period"]

define "Tobacco Cessation Counseling Given":
  (Status."Finished Procedure"([Procedure: "Tobacco Use Cessation Counseling"]) TobaccoCessationCounseling
        where QICoreCommon."ToInterval"(TobaccoCessationCounseling.performed) during day of Interval[start of "Measurement Period" - 6 months, 
    end of "Measurement Period"]
    )
      union ( Status."Active Condition"([Diagnosis: "Tobacco abuse counseling"]) TobaccoCounseling
        where ( TobaccoCounseling.prevalencePeriod ) starts during day of Interval[start of "Measurement Period" - 6 months, 
        end of "Measurement Period"]
            )

define "Most Recent Tobacco Use Screening Indicates Tobacco Non User":
  ( Last((Status."Final Survey Observation"([Observation: "Tobacco Use Screening"])) TobaccoUseScreening
            where QICoreCommon."ToInterval"(TobaccoUseScreening.effective) during "Measurement Period"
                sort by start of QICoreCommon."ToInterval"(effective))) MostRecentTobaccoUseScreening
                    where MostRecentTobaccoUseScreening.value in "Tobacco Non User"

define "Most Recent Tobacco Use Screening Indicates Tobacco User":
  ( Last((Status."Final Survey Observation"([Observation: "Tobacco Use Screening"])) TobaccoUseScreening
            where QICoreCommon."ToInterval"(TobaccoUseScreening.effective) during "Measurement Period"
                sort by start of QICoreCommon."ToInterval"(effective))) MostRecentTobaccoUseScreening
                    where MostRecentTobaccoUseScreening.value in "Tobacco User"

define "Tobacco Cessation Pharmacotherapy Ordered":
  Status."Active or Completed Medication Request"([MedicationRequest: "Tobacco Use Cessation Pharmacotherapy"]) CessationPharmacotherapyOrdered
        where CessationPharmacotherapyOrdered.authoredOn during day of Interval[start of "Measurement Period" - 6 months, end of "Measurement Period"]
 
define "Preventive Visit During Measurement Period":
  Status."Finished Encounter"(( [Encounter: "Annual Wellness Visit"]
        union [Encounter: "Preventive Care Services Established Office Visit, 18 and Up"]
        union [Encounter: "Preventive Care Services Group Counseling"]
        union [Encounter: "Unlisted preventive medicine service"]
        union [Encounter: "Preventive Care Services Individual Counseling"]
        union [Encounter: "Postoperative follow-up visit, normally included in the surgical package, to indicate that an evaluation and management service was performed during a postoperative period for a reason(s) related to the original procedure"]
        union [Encounter: "Nutrition Services"]
        union [Encounter: "Preventive Care Services Initial Office Visit, 18 and Up"] )) PreventiveEncounter
        where QICoreCommon."ToInterval"(PreventiveEncounter.period) during day of "Measurement Period"                   

define "Qualifying Visit During Measurement Period":
  Status."Finished Encounter"(( [Encounter: "Health behavior intervention, individual, face-to-face; initial 30 minutes"]
        union [Encounter: "Health behavior assessment, or re-assessment (ie, health-focused clinical interview, behavioral observations, clinical decision making)"]
        union [Encounter: "Home Healthcare Services"]
        union [Encounter: "Occupational Therapy Evaluation"]
        union [Encounter: "Office Visit"]
        union [Encounter: "Ophthalmological Services"]
        union [Encounter: "Physical Therapy Evaluation"]
        union [Encounter: "Psych Visit Diagnostic Evaluation"]
        union [Encounter: "Psych Visit Psychotherapy"]
        union [Encounter: "Psychoanalysis"]
        union [Encounter: "Speech and Hearing Evaluation"] 
        union [Encounter: "Telephone Visits"]
        union [Encounter: "Online Assessments"]) OfficeBasedEncounter
        where QICoreCommon."ToInterval"(OfficeBasedEncounter.period)) during day of "Measurement Period"

