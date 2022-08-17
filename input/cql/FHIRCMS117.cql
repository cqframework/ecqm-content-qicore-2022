library ChildhoodImmunizationStatusFHIR version '0.0.001'

/*This measure has not been tested.*/

using QICore version '4.1.1'

include FHIRHelpers version '4.0.012' called FHIRHelpers
include QICoreCommon version '1.0.000' called QICoreCommon
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include HospiceQICore4 version '3.0.000' called Hospice
include ImmunizationFHIR version '1.0.0' called Immunization
include StatusFHIR version '1.0.0' called Status

codesystem "SNOMEDCT": 'http://snomed.info/sct' 
codesystem "CPT": 'http://www.ama-assn.org/go/cpt' 
codesystem "CVX": 'http://hl7.org/fhir/sid/cvx' 

valueset "Anaphylactic Reaction to DTaP Vaccine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.199.12.1031' 
valueset "Anaphylactic Reaction to Hepatitis A Vaccine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.199.12.1026' 
valueset "Anti Hepatitis A IgG Antigen Test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1033' 
valueset "Anti Hepatitis B Virus Surface Ab": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1073' 
valueset "Disorders of the Immune System": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.120.12.1001' 
valueset "DTaP Vaccine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.196.12.1214' 
valueset "DTaP Vaccine Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1022' 
valueset "Encephalopathy due to Childhood Vaccination": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.114.12.1007' 
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307' 
valueset "Haemophilus Influenzae Type B (Hib) Vaccine Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1043' 
valueset "Hepatitis A": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1024' 
valueset "Hepatitis A Vaccine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.196.12.1215' 
valueset "Hepatitis A Vaccine Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1041' 
valueset "Hepatitis B": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1025' 
valueset "Hepatitis B Vaccine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.196.12.1216' 
valueset "Hepatitis B Vaccine Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1042' 
valueset "Hib Vaccine (3 dose schedule)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1083' 
valueset "Hib Vaccine (3 dose schedule) Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1084' 
valueset "Hib Vaccine (4 dose schedule)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1085' 
valueset "Hib Vaccine (4 dose schedule) Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1086' 
valueset "HIV": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.120.12.1003' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Hospice care ambulatory": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1108.15' 
valueset "Inactivated Polio Vaccine (IPV)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.196.12.1219' 
valueset "Inactivated Polio Vaccine (IPV) Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1045' 
valueset "Influenza Vaccine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.196.12.1218' 
valueset "Influenza Vaccine Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1044' 
valueset "Influenza Virus LAIV Immunization": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1087' 
valueset "Influenza Virus LAIV Procedure": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1088' 
valueset "Intussusception": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.199.12.1056' 
valueset "Malignant Neoplasm of Lymphatic and Hematopoietic Tissue": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1009' 
valueset "Measles": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1053' 
valueset "Measles, Mumps and Rubella (MMR) Vaccine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.196.12.1224' 
valueset "Measles, Mumps and Rubella (MMR) Vaccine Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1031' 
valueset "Mumps": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1032' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Pneumococcal Conjugate Vaccine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.196.12.1221' 
valueset "Pneumococcal Conjugate Vaccine Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1046' 
valueset "Positive Finding": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.121.12.1016' 
valueset "Preventive Care Services, Initial Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1022' 
valueset "Preventive Care, Established Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1024' 
valueset "Rotavirus Vaccine (2 dose schedule) Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1048' 
valueset "Rotavirus Vaccine (3 dose schedule)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.196.12.1223' 
valueset "Rotavirus Vaccine (3 dose schedule) Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1047' 
valueset "Rubella": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1037' 
valueset "Severe Combined Immunodeficiency": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.120.12.1007' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 
valueset "Varicella Zoster": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1039' 
valueset "Varicella Zoster Vaccine (VZV)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.196.12.1170' 
valueset "Varicella Zoster Vaccine (VZV) Administered": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1040' 

code "Adverse reaction to vaccine product containing Hepatitis A virus antigen (disorder)": '293126009' from "SNOMEDCT" display 'Adverse reaction to vaccine product containing Hepatitis A virus antigen (disorder)'
code "Adverse reaction to vaccine product containing Human poliovirus antigen (disorder)": '293117006' from "SNOMEDCT" display 'Adverse reaction to vaccine product containing Human poliovirus antigen (disorder)'
code "Adverse reaction to vaccine product containing Influenza virus antigen (disorder)": '420113004' from "SNOMEDCT" display 'Adverse reaction to vaccine product containing Influenza virus antigen (disorder)'
code "Adverse reaction to vaccine product containing Streptococcus pneumoniae antigen (disorder)": '293116002' from "SNOMEDCT" display 'Adverse reaction to vaccine product containing Streptococcus pneumoniae antigen (disorder)'
code "Anaphylaxis due to Haemophilus influenzae type b vaccine (disorder)": '433621000124101' from "SNOMEDCT" display 'Anaphylaxis due to Haemophilus influenzae type b vaccine (disorder)'
code "Anaphylaxis due to Hepatitis B vaccine (disorder)": '428321000124101' from "SNOMEDCT" display 'Anaphylaxis due to Hepatitis B vaccine (disorder)'
code "Anaphylaxis due to rotavirus vaccine (disorder)": '428331000124103' from "SNOMEDCT" display 'Anaphylaxis due to rotavirus vaccine (disorder)'
code "Influenza virus vaccine adverse reaction (disorder)": '420113004' from "SNOMEDCT" display 'Influenza virus vaccine adverse reaction (disorder)'
code "Office or other outpatient visit for the evaluation and management of an established patient, that may not require the presence of a physician or other qualified health care professional. Usually, the presenting problem(s) are minimal.": '99211' from "CPT" display 'Office or other outpatient visit for the evaluation and management of an established patient, that may not require the presence of a physician or other qualified health care professional. Usually, the presenting problem(s) are minimal.'
code "rotavirus, live, monovalent vaccine": '119' from "CVX" display 'rotavirus, live, monovalent vaccine'

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
  AgeInYearsAt(date from end of "Measurement Period") = 2
        and exists ("Qualifying Encounter")

define "Qualifying Encounter":
  (Status."Finished Encounter"([Encounter: "Office Visit"]
        union [Encounter: "Home Healthcare Services"]
        union [Encounter: "Preventive Care, Established Office Visit, 0 to 17"]
        union [Encounter: "Preventive Care Services, Initial Office Visit, 0 to 17"]
        union [Encounter: "Office or other outpatient visit for the evaluation and management of an established patient, that may not require the presence of a physician or other qualified health care professional. Usually, the presenting problem(s) are minimal."]
        union [Encounter: "Online Assessments"]
        union [Encounter: "Telephone Visits"])) ValidEncounters
            and QICoreCommon."ToInterval"(ValidEncounters.period) during day of "Measurement Period"

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice Services"
    or "Has Severe Combined Immunodeficiency"
    or "Has Immunodeficiency"
    or "Has HIV"
    or "Has Lymphoreticular Cancer, Multiple Myeloma or Leukemia"
    or "Has Intussusception"

define "Has Severe Combined Immunodeficiency":
  exists Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( Status."Active Condition" ( [Condition: "Severe Combined Immunodeficiency"] ), "Date of Second Birthday" )

define "Has Immunodeficiency":
  exists Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( Status."Active Condition" ( [Condition: "Disorders of the Immune System"] ), "Date of Second Birthday" )

define "Has HIV":
  exists Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( Status."Active Condition" ( [Condition: "HIV"] ), "Date of Second Birthday" )
  
define "Has Lymphoreticular Cancer, Multiple Myeloma or Leukemia":
  exists Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( Status."Active Condition" ( [Condition: "Malignant Neoplasm of Lymphatic Tissue"] ), "Date of Second Birthday" )

define "Has Intussusception":
  exists Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( Status."Active Condition" ( [Condition: "Intussusception"] ), "Date of Second Birthday" )

define "Numerator":
  (exists ("Four DTaP Vaccinations")
            or exists ("DTaP Numerator Inclusion Conditions")
        )
        and (exists ("Three Polio Vaccinations"))
        and (exists ("One MMR Vaccination")
            or (exists ("Has History of Measles, Mumps and Rubella Illness"))
            )
        and ("Has Appropriate Number of Hib Immunizations"
            or exists ("Hib Numerator Inclusion Conditions")
            )
            or (exists ("Hepatitis B Numerator Inclusion Conditions")
                )
        and (exists ("One Chicken Pox Vaccination" )
            or exists ("Varicella Zoster Numerator Inclusion Conditions")
                )
        and (exists ("Four Pneumococcal Conjugate Vaccinations"))
        and (exists ("One Hepatitis A Vaccinations")
            or exists ("Hepatitis A Numerator Inclusion Conditions")
                )
        and ("Has Appropriate Number of Rotavirus Immunizations"
            or exists ("Rotavirus Numerator Inclusion Conditions")
                )
        and (exists ("Meets Influenza Vaccination Requirement")
        )

define "Four DTaP Vaccinations":
    Immunization."Meets Required Vaccination Threshold" ( "DTaP Immunizations or Procedures", "Vaccine Administration Interval - 42 Days up to 2 Years Old", 4 )

define "DTaP Immunizations or Procedures":
   (Status."Completed Immunization"( [Immunization: "DTaP Vaccine"] )) 
   union (Status."Completed Procedure"([Procedure: "DTaP Vaccine Administered"]))
        
define "DTaP Numerator Inclusion Conditions":
  exists Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( "Anaphylaxis or Encephalitis due to DTaP Vaccine"), "Date of Second Birthday" )

define "Three Polio Vaccinations":
  Immunization."Meets Required Vaccination Threshold" ( "Polio Immunizations or Procedures", "Vaccine Administration Interval on or between 42 Days and Second Birthday", 3 )

define "Polio Immunizations or Procedures":
   (Status."Completed Immunization"( [Immunization: "Inactivated Polio Vaccine (IPV)"]))
      union (Status."Completed Procedure"([Procedure: "Inactivated Polio Vaccine (IPV) Administered"])) 

define "One MMR Vaccination":
  Immunization."Meets Required Vaccination Threshold" ( "MMR Vaccinations", "Vaccine Administration Interval on or between First Birthday and Second Birthday", 1 )

define "MMR Vaccinations":
  Status."Completed Immunization"([Immunization: "Measles, Mumps and Rubella (MMR) Vaccine"])
      union Status."Completed Procedure"( [Procedure: "Measles, Mumps and Rubella (MMR) Vaccine Administered"])

define "Has History of Measles, Mumps and Rubella Illness":
  exists Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( Status."Active Condition" ( [Condition: "Measles"] ), "Date of Second Birthday" )
    and exists Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( Status."Active Condition" ( [Condition: "Mumps"] ), "Date of Second Birthday" )
    and exists Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( Status."Active Condition" ( [Condition: "Rubella"] ), "Date of Second Birthday" )

define "Meets Influenza Vaccination Requirement":
 Immunization."Meets Required Vaccination Threshold" ( "Influenza Immunizations or Procedures", "Vaccine Administration Interval - 180 Days up to 2 Years Old", 2 )
    or ( Immunization."Meets Required Vaccination Threshold" ( "Influenza Immunizations or Procedures", "Vaccine Administration Interval - 180 Days up to 2 Years Old", 1 )
        and Immunization."Meets Required Vaccination Threshold" ( "LAIV Vaccinations", Interval["Date of Second Birthday", "Date of Second Birthday"], 1 )
        and Immunization."Meets Required Vaccination Threshold" ( ( "LAIV Vaccinations"
            union "Influenza Vaccinations"
        ), "Vaccine Administration Interval - 180 Days up to 2 Years Old", 2 )
    )

define "Influenza Immunizations or Procedures":
  Status."Completed Immunization"([Immunization: "Influenza Vaccine"])
      union Status."Completed Procedure"([Procedure: "Influenza Vaccine Administered"])

define "LAIV Vaccinations":
 Status."Completed Immunization"([Immunization: "Influenza Virus LAIV Immunization"])
      union Status."Completed Procedure"([Procedure: "Influenza Virus LAIV Procedure"])

define "Anaphylaxis or Encephalitis due to DTaP Vaccine":
(Status."Active Condition"([Condition: "Anaphylactic Reaction to DTaP Vaccine"]
        union [Condition: "Encephalopathy due to Childhood Vaccination"]))

define "Has Appropriate Number of Hib Immunizations":
  exists ("All Hib Vaccinations" HibImmunization //union of 3 and 4 dose immunizations
                                  //4 dose test
                                      let HasFourDose: Count("Hib 4 Dose Immunizations or Procedures")> 0
                                      where (HasFourDose //if pt had at least one 4 dose code
                                          and Count(distinct("All Hib Vaccinations" HibVaccinations
                                                return HibVaccinations
                                            )
                                          )>= 4 //pt must have 4 regimens (e.g., 3,3,4,4 or 4,3,4,4)
                                      )
                                        or (HasFourDose is false //if pt did not have at least one 4 dose code
                                            and Count(distinct("All Hib Vaccinations" HibVaccinations
                                                  return HibVaccinations
                                              )
                                            )>= 3 //pt must have 3 regimens of 3 dose codes
                                        )
                                  )

define "All Hib Vaccinations":
  "Hib 3 or 4 Dose Immunizations" AllHibDoses1
        without "Hib 3 or 4 Dose Immunizations" AllHibDoses2
            such that AllHibDoses1 less than 1 day before AllHibDoses2

define "Hib 3 or 4 Dose Immunizations":
  "Hib 3 Dose Immunizations or Procedures"
        union "Hib 4 Dose Immunizations or Procedures"

define "Hib Numerator Inclusion Conditions":
  exists Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( Status."Active Condition" ( [Condition: "Anaphylaxis due to Haemophilus influenzae type b vaccine (disorder)"] ), "Date of Second Birthday" )

define "Hib 4 Dose Immunizations or Procedures":
   Immunization."Meets Required Vaccination Threshold" ( "HiB 4 Dose Vaccinations", "Vaccine Administration Interval - 42 Days up to 2 Years Old", 3 )

define "Hib 3 Dose Immunizations or Procedures":
  Immunization."Meets Required Vaccination Threshold" ( "HiB 3 Dose Vaccinations", "Vaccine Administration Interval - 42 Days up to 2 Years Old", 3 )

define "HiB 3 Dose Vaccinations":
  Status."Completed Immunization"([Immunization: "Hib Vaccine (3 dose schedule)"])
        union Status."Completed Procedure"([Procedure: "Hib Vaccine (3 dose schedule) Administered"])

define "HiB 4 Dose Vaccinations":
  Status."Completed Immunization" ( [Immunization: "Hib Vaccine (4 dose schedule)"] )
    union Status."Completed Procedure" ( [Procedure: "Hib Vaccine (4 dose schedule) Administered"] )

define "Three Hepatitis B Vaccinations":
Immunization."Meets Required Vaccination Threshold" ( "Hepatitis B Immunizations or Procedures", Interval[Patient.birthDate, "Date of Second Birthday"], 3 )
    or ( Immunization."Meets Required Vaccination Threshold" ( "Hepatitis B Immunizations or Procedures", Interval[Patient.birthDate, "Date of Second Birthday"], 2 )
        and Immunization."Meets Required Vaccination Threshold" ( "Hepatitis B Immunizations or Procedures", Interval[Patient.birthDate, Patient.birthDate + 7 days], 1 )
    )

define "Hepatitis B Immunizations or Procedures":
  Status."Completed Immunization"([Immunization: "Hepatitis B Vaccine"]) 
      union Status."Completed Procedure"( [Procedure: "Hepatitis B Vaccine Administered"])

define "Hepatitis B Numerator Inclusion Conditions":
 exists ( Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( Status."Active Condition" ( [Condition: "Anaphylaxis due to Hepatitis B vaccine (disorder)"] ), "Date of Second Birthday" )
      union Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( Status."Active Condition" ( [Condition: "Hepatitis B"] ), "Date of Second Birthday" )
  ) 

define "Varicella Zoster Numerator Inclusion Conditions":
  exists Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( Status."Active Condition" ( [Condition: "Varicella Zoster"] ), "Date of Second Birthday" )

define "One Chicken Pox Vaccination":
  Immunization."Meets Required Vaccination Threshold" ( "VZV Vaccinations", "Vaccine Administration Interval on or between First Birthday and Second Birthday", 1 )

define "VZV Vaccinations":
 Status."Completed Immunization"([Immunization: "Varicella Zoster Vaccine (VZV)"])
      union Status."Completed Procedure"([Procedure: "Varicella Zoster Vaccine (VZV) Administered"])

define "Four Pneumococcal Conjugate Vaccinations":
  Immunization."Meets Required Vaccination Threshold" ( "Pneumococcal Conjugate Vaccinations", "Vaccine Administration Interval on or between 42 Days and Second Birthday", 4 )

define "Pneumococcal Conjugate Immunizations or Procedures":
  Status."Completed Immunization"([Immunization: "Pneumococcal Conjugate Vaccine"])
      union Status."Completed Procedure"( [Procedure: "Pneumococcal Conjugat\e Vaccine Administered"])

define "Hepatitis A Numerator Inclusion Conditions":
  exists Immunization."Diagnosis on or before Latest Possible Vaccination Date" ( Status."Active Condition" ( [Condition: "Hepatitis A"] ), "Date of Second Birthday" )

define "Has Appropriate Number of Rotavirus Immunizations":
  exists ("All Rotavirus Vaccinations" RotavirusImmunization
                                      let HasThreeDose: Count("Rotavirus 3 Dose Immunizations or Procedures")> 0
                                      where (HasThreeDose
                                          and Count(distinct("All Rotavirus Vaccinations" RotavirusVaccinations
                                                return RotavirusVaccinations
                                            )
                                          )>= 3
                                      )
                                        or (HasThreeDose is false
                                            and Count(distinct("All Rotavirus Vaccinations" RotavirusVaccinations
                                                  return RotavirusVaccinations
                                              )
                                            )>= 2
                                        )
                                  )

define "All Rotavirus Vaccinations":
  "Rotavirus 2 or 3 Dose Immunizations" AllRotavirusDoses1
                                    without "Rotavirus 2 or 3 Dose Immunizations" AllRotavirusDoses2
                                      such that AllRotavirusDoses1 less than 1 day before AllRotavirusDoses2

define "Rotavirus 2 or 3 Dose Immunizations":
  "Rotavirus 2 Dose Immunizations or Procedures"
          union "Rotavirus 3 Dose Immunizations or Procedures"

define "Rotavirus Numerator Inclusion Conditions":
  Status."Active Condition"([Condition: "Anaphylaxis due to rotavirus vaccine (disorder)"]) RotavirusConditions
        where start of QICoreCommon."ToPrevalenceInterval"(RotavirusConditions) during "Date of Second Birthday"

define "One Hepatitis A Vaccinations":
  Status."Completed Immunization"([Immunization: "Hepatitis A Vaccine"])
      union Status."Completed Procedure"([Procedure: "Hepatitis A Vaccine Administered"])

define "Rotavirus 2 Dose Immunizations or Procedures":
  Status."Completed Immunization"([Immunization: "rotavirus, live, monovalent vaccine"])
      union Status."Completed Procedure"([Procedure: "Rotavirus Vaccine (2 dose schedule) Administered"])

define "Rotavirus 3 Dose Immunizations or Procedures":
  Status."Completed Immunization"([Immunization: "Rotavirus Vaccine (3 dose schedule)"]) 
      union Status."Completed Procedure"([Procedure: "Rotavirus Vaccine (3 dose schedule) Administered"])

define "Influenza Immunizations or Procedures":
  Status."Completed Immunization"([Immunization: "Influenza Vaccine"])
      union Status."Completed Procedure"([Procedure: "Influenza Vaccine Administered"])

define "LAIV Vaccinations":
 Status."Completed Immunization"([Immunization: "Influenza Virus LAIV Immunization"])
      union Status."Completed Procedure"([Procedure: "Influenza Virus LAIV Procedure"])
          
define "Vaccine Administration Interval - 180 Days up to 2 Years Old":
  Interval[Patient.birthDate + 180 days, "Date of Second Birthday"]

define "Vaccine Administration Interval - 42 Days up to 2 Years Old":
  Interval[Patient.birthDate + 42 days, "Date of Second Birthday"]

define "Date of First Birthday":
  Patient.birthDate + 1 year

define "Date of Second Birthday":
  Patient.birthDate + 2 years

define "Date of First Birthday to Date of Second Birthday":
  Interval["Date of First Birthday", "Date of Second Birthday"]

define "Vaccine Administration Interval on or between First Birthday and Second Birthday":
  "Date of First Birthday to Date of Second Birthday"
