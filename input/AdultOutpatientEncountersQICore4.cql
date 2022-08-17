library AdultOutpatientEncountersQICore4 version '3.0.000'

using QICore version '4.1.1'

include FHIRHelpers version '4.0.012' called FHIRHelpers
// include FHIRCommon version '4.0.012' called FHIRCommon //https://github.com/cqframework/ecqm-content-qicore-2022/issues/5
include QICoreCommon version '1.0.000' called QICoreCommon
include StatusFHIR version '1.0.0' called Status

valueset "Annual Wellness Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1240' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Preventive Care Services Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025' 
valueset "Preventive Care Services Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 

parameter "Measurement Period" Interval<DateTime>
default Interval[@2023-01-01T00:00:00.000Z, @2024-01-01T00:00:00.000Z)

context Patient

define "Qualifying Encounters":
  (Status."Finished Encounter"(
                    [Encounter: "Office Visit"]
                  		union [Encounter: "Annual Wellness Visit"]
                  		union [Encounter: "Preventive Care Services Established Office Visit, 18 and Up"]
                  		union [Encounter: "Preventive Care Services Initial Office Visit, 18 and Up"]
                  		union [Encounter: "Home Healthcare Services"]
						union [Encounter: "Online Assessments"]
	                    union [Encounter: "Telephone Visits"]
  )) ValidEncounter 
                		where QICoreCommon."ToInterval"(ValidEncounter.period) during day of "Measurement Period"