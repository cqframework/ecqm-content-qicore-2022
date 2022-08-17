library PrimaryCariesPreventionasOfferedbyPCPsincludingDentistsFHIR version '0.0.001'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.0.012' called FHIRHelpers
include QICoreCommon version '1.0.000' called QICoreCommon
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include HospiceQICore4 version '3.0.000' called Hospice
include StatusFHIR version '1.0.0' called Status 

valueset "Clinical Oral Evaluation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.125.12.1003' 
valueset "Fluoride Varnish Application for Children": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.125.12.1002' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Preventive Care - Established Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1024' 
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025' 
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023' 
valueset "Preventive Care- Initial Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1022' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 

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

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice Services"

define "Qualifying Encounters":
  (Status."Finished Encounter"([Encounter: "Clinical Oral Evaluation"])) ValidEncounter
        where QICoreCommon."ToInterval"(ValidEncounter.period) during day of "Measurement Period"

define "Stratification 1":
  AgeInMonthsAt( date from start of "Measurement Period" ) >= 6
                  and AgeInYearsAt(date from start of "Measurement Period" ) <= 4

define "Stratification 2":
  AgeInYearsAt( date from start of "Measurement Period" ) in Interval[5, 11]

define "Stratification 3":
  AgeInYearsAt(date from start of "Measurement Period" ) in Interval[12, 20 )

define "Numerator":
  exists  Status."Completed Procedure"([Procedure: "Fluoride Varnish Application for Children"]) FluorideApplication
                where QICoreCommon."ToInterval"(FluorideApplication.performed) during day of "Measurement Period"

define "Initial Population":
  AgeInMonthsAt(date from start of "Measurement Period" ) >= 6
                  and AgeInYearsAt(date from start of "Measurement Period" ) < 20
                    and exists ( "Qualifying Encounters" )

