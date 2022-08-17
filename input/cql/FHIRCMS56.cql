library FunctionalStatusAssessmentforTotalHipReplacementFHIR version '0.0.001'

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

codesystem "LOINC": 'http://loinc.org' 
codesystem "CPT": 'http://www.ama-assn.org/go/cpt' 
codesystem "SNOMEDCT": 'http://snomed.info/sct' 

valueset "Ethnicity": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.837' 
valueset "Fracture - Lower Body": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.113.12.1037' 
valueset "Hip Dysfunction and Osteoarthritis Outcome Score for Joint Replacement [HOOSJR]": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.118.12.1210' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "ONC Administrative Sex": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Outpatient Consultation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1008' 
valueset "Payer": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.3591' 
valueset "Primary THA Procedure": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1006' 
valueset "Race": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.836' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 

code "Activities of daily living score [HOOS]": '72095-3' from "LOINC" display 'Activities of daily living score [HOOS]'
code "Pain score [HOOS]": '72097-9' from "LOINC" display 'Pain score [HOOS]'
code "Postoperative follow-up visit, normally included in the surgical package, to indicate that an evaluation and management service was performed during a postoperative period for a reason(s) related to the original procedure": '99024' from "CPT" display 'Postoperative follow-up visit, normally included in the surgical package, to indicate that an evaluation and management service was performed during a postoperative period for a reason(s) related to the original procedure'
code "Problem List Item": 'problem-list-item' from "ConditionCategoryCodes" display 'Problem List Item'
code "PROMIS-10 Global Mental Health (GMH) score T-score": '71969-0' from "LOINC" display 'PROMIS-10 Global Mental Health (GMH) score T-score'
code "PROMIS-10 Global Physical Health (GPH) score T-score": '71971-6' from "LOINC" display 'PROMIS-10 Global Physical Health (GPH) score T-score'
code "Quality of life score [HOOS]": '72093-8' from "LOINC" display 'Quality of life score [HOOS]'
code "Severe dementia (disorder)": '428351000124105' from "SNOMEDCT" display 'Severe dementia (disorder)'
code "Sport-recreation score [HOOS]": '72094-6' from "LOINC" display 'Sport-recreation score [HOOS]'
code "survey": 'survey' from "ObservationCategoryCodes" display 'Survey'
code "Symptoms score [HOOS]": '72096-1' from "LOINC" display 'Symptoms score [HOOS]'
code "Total interval score [HOOSJR]": '82323-7' from "LOINC" display 'Total interval score [HOOSJR]'
code "VR-12 Mental component summary (MCS) score - oblique method T-score": '72026-8' from "LOINC" display 'VR-12 Mental component summary (MCS) score - oblique method T-score'
code "VR-12 Mental component summary (MCS) score - orthogonal method T-score": '72028-4' from "LOINC" display 'VR-12 Mental component summary (MCS) score - orthogonal method T-score'
code "VR-12 Physical component summary (PCS) score - oblique method T-score": '72025-0' from "LOINC" display 'VR-12 Physical component summary (PCS) score - oblique method T-score'
code "VR-12 Physical component summary (PCS) score - orthogonal method T-score": '72027-6' from "LOINC" display 'VR-12 Physical component summary (PCS) score - orthogonal method T-score'

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
  "Has Qualifying Encounter"
        and exists ( "Total Hip Arthroplasty Procedure" )
        and AgeInYearsAt(date from start of "Measurement Period")>= 19

define "Has Qualifying Encounter":
  exists ( Status."Finished Encounter"(( [Encounter: "Outpatient Consultation"]
            union [Encounter: "Office Visit"]
            union [Encounter: "Postoperative follow-up visit, normally included in the surgical package, to indicate that an evaluation and management service was performed during a postoperative period for a reason(s) related to the original procedure"] 
            union [Encounter: "Telephone Visits"]
            union [Encounter: "Online Assessments"])) ValidEncounters
            where QICoreCommon."ToInterval"(ValidEncounters.period) during day of "Measurement Period"
        )

define "Total Hip Arthroplasty Procedure":
  Status."Completed Procedure"([Procedure: "Primary THA Procedure"]) THAProcedure
        where QICoreCommon."ToInterval"(THAProcedure.performed) starts 12 months or less on or before start of "Measurement Period"

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice Services"
    or "Has Total Hip Arthroplasty with 2 or More Lower Body Fractures"
    or "Has Dementia Diagnosis"

define "Numerator":
  ( "Has THA with Initial and Follow Up HOOS Assessments" )
        or ( "Has THA with Initial and Follow Up HOOSJr Assessments" )
        or ( "Has THA with Initial and Follow Up PROMIS10 Assessments" )
        or ( "Has THA with Initial and Follow Up VR12 Oblique Assessments" )
        or ( "Has THA with Initial and Follow Up VR12 Orthogonal Assessments" )

define "Has THA with Initial and Follow Up PROMIS10 Assessments":
  exists (( "Total Hip Arthroplasty Procedure" THAProcedure
  return QICoreCommon."ToInterval" ( THAProcedure.performed ) ) TotalHip
        with "Time PROMIS10 Total Assessment Completed" InitialHipAssessmentPROMIS10
            such that TotalHip starts 90 days or less on or after InitialHipAssessmentPROMIS10
        with "Time PROMIS10 Total Assessment Completed" FollowupHipAssessmentPROMIS10
            such that FollowupHipAssessmentPROMIS10 during day of Interval[
            end of TotalHip + 270 days,
            end of TotalHip + 365 days]
    )

define "Has THA with Initial and Follow Up VR12 Oblique Assessments":
  exists (( "Total Hip Arthroplasty Procedure" THAProcedure
  return QICoreCommon."ToInterval" ( THAProcedure.performed ) ) TotalHip
        with "Time VR12 Oblique Total Assessment Completed" InitialHipAssessmentOblique
            such that TotalHip starts 90 days or less on or after InitialHipAssessmentOblique
        with "Time VR12 Oblique Total Assessment Completed" FollowupHipAssessmentOblique
            such that FollowupHipAssessmentOblique during day of Interval[
            end of TotalHip + 270 days,
            end of TotalHip + 365 days]
    )

define "Has THA with Initial and Follow Up VR12 Orthogonal Assessments":
  exists (( "Total Hip Arthroplasty Procedure" THAProcedure
  return QICoreCommon."ToInterval" ( THAProcedure.performed ) ) TotalHip
            with "Time VR12 Orthogonal Total Assessment Completed" InitialHipAssessmentOrthogonal
                such that TotalHip starts 90 days or less on or after InitialHipAssessmentOrthogonal
            with "Time VR12 Orthogonal Total Assessment Completed" FollowupHipAssessmentOrthogonal
                such that FollowupHipAssessmentOrthogonal during day of Interval[
                end of TotalHip + 270 days,
                end of TotalHip + 365 days]
        )

define "Has Dementia Diagnosis":
  exists ( Status."Active Condition"([Condition: "Severe dementia (disorder)"]) Dementia
            where QICoreCommon."ToPrevalenceInterval"(Dementia) overlaps "Measurement Period"
         )

define "Has THA with Initial and Follow Up HOOS Assessments":
  exists (( "Total Hip Arthroplasty Procedure" THAProcedure
  return QICoreCommon."ToInterval" ( THAProcedure.performed ) ) TotalHip
            with "Time HOOS Total Assessment Completed" InitialHipAssessmentHOOS
                such that TotalHip starts 90 days or less on or after InitialHipAssessmentHOOS
            with "Time HOOS Total Assessment Completed" FollowupHipAssessmentHOOS
                such that FollowupHipAssessmentHOOS during day of Interval[
                  end of TotalHip + 270 days,
                  end of TotalHip + 365 days]
         )

define "Has THA with Initial and Follow Up HOOSJr Assessments":
  exists (( "Total Hip Arthroplasty Procedure" THAProcedure
  return QICoreCommon."ToInterval" ( THAProcedure.performed ) ) TotalHip
            with "Time HOOSJr Total Assessment Completed" InitialHipAssessment
                such that TotalHip starts 90 days or less on or after InitialHipAssessment
                with "Time HOOSJr Total Assessment Completed" FollowupHipAssessment
                such that FollowupHipAssessment.effective during day of Interval[
                  end of TotalHip + 270 days, 
                  end of TotalHip + 365 days]
          )

define "Has Total Hip Arthroplasty with 2 or More Lower Body Fractures":
  exists ( "Total Hip Arthroplasty Procedure" THAProcedure
            where Count(Status."Active Condition"([Condition: "Fracture - Lower Body"]) LowerBodyFracture
                where QICoreCommon."ToPrevalenceInterval"(LowerBodyFracture) starts 24 hours or less on or before start of QICoreCommon."ToInterval"(THAProcedure.performed))>= 2
            )

define "Time HOOSJr Total Assessment Completed":
  ( Status."Final Survey Observation"([Observation: "Total interval score [HOOSJR]"]) HOOSJr
            where HOOSJr.value is not null ) DocumentedHOOSJr
  return start of QICoreCommon."ToInterval" ( DocumentedHOOSJr.effective )

define "Time HOOS Total Assessment Completed":
  from
    Status."Final Survey Observation"([Observation: "Quality of life score [HOOS]"]) HOOSLifeQuality,  
    Status."Final Survey Observation"([Observation: "Sport-recreation score [HOOS]"]) HOOSSport,
    Status."Final Survey Observation"([Observation: "Activities of daily living score [HOOS]"]) HOOSActivityScore,
    Status."Final Survey Observation"([Observation: "Symptoms score [HOOS]"]) HOOSSymptoms,
    Status."Final Survey Observation"([Observation: "Pain score [HOOS]"]) HOOSPain
    let HOOSLifeQualityTime: start of QICoreCommon."ToInterval"(HOOSLifeQuality.effective),
    HOOSSportTime: start of QICoreCommon."ToInterval" ( HOOSSport.effective),
    HOOSActivityScoreTime: start of QICoreCommon."ToInterval" (HOOSActivityScore.effective),
    HOOSSymptomsTime: start of QICoreCommon."ToInterval" (HOOSSymptoms.effective),
    HOOSPainTime: start of QICoreCommon."ToInterval" (HOOSPain.effective)                   
    where HOOSLifeQualityTime same day as HOOSSportTime
        and HOOSSport.value is not null
        and HOOSLifeQualityTime same day as HOOSActivityScoreTime
        and HOOSActivityScore.value is not null
        and HOOSLifeQualityTime same day as HOOSSymptomsTime
        and HOOSSymptoms.value is not null
        and HOOSLifeQualityTime same day as HOOSPainTime
        and HOOSPain.value is not null
        and HOOSLifeQuality.value is not null
            return Max({ HOOSLifeQualityTime, HOOSSportTime, HOOSActivityScoreTime, HOOSSymptomsTime, HOOSPainTime })

define "Time PROMIS10 Total Assessment Completed":
  from
    Status."Final Survey Observation"([Observation: "PROMIS-10 Global Mental Health (GMH) score T-score"]) PROMIS10MentalScore,
    Status."Final Survey Observation"([Observation: "PROMIS-10 Global Physical Health (GPH) score T-score"]) PROMIS10PhysicalScore
    let PROMIS10MentalScoreTime: start of QICoreCommon."ToInterval"( PROMIS10MentalScore.effective),
        PROMIS10PhysicalScoreTime: start of QICoreCommon."ToInterval"( PROMIS10PhysicalScore.effective)
        where PROMIS10MentalScoreTime same day as PROMIS10PhysicalScoreTime
            and PROMIS10PhysicalScore.value is not null
            and PROMIS10MentalScore.value is not nul
                return Max({PROMIS10MentalScoreTime, PROMIS10PhysicalScoreTime})

define "Time VR12 Oblique Total Assessment Completed":
  from
    Status."Final Survey Observation"([Observation: "VR-12 Mental component summary (MCS) score - oblique method T-score"]) VR12MentalAssessment,
    Status."Final Survey Observation"([Observation: "VR-12 Physical component summary (PCS) score - oblique method T-score"]) VR12PhysicalAssessment
    let VR12MentalAssessmentTime: start of QICoreCommon."ToInterval"(VR12MentalAssessment.effective),
VR12PhysicalAssessmentTime: start of QICoreCommon."ToInterval"( VR12PhysicalAssessment.effective)          
    where VR12MentalAssessmentTime same day as VR12PhysicalAssessmentTime
        and VR12MentalAssessment.value is not null
        and VR12PhysicalAssessment.value is not null
      return Max({ VR12MentalAssessmentTime, VR12PhysicalAssessmentTime })

define "Time VR12 Orthogonal Total Assessment Completed":
  from
    Status."Final Survey Observation"([Observation: "VR-12 Mental component summary (MCS) score - orthogonal method T-score"]) VR12MentalAssessment,
    Status."Final Survey Observation"([Observation: "VR-12 Physical component summary (PCS) score - orthogonal method T-score"]) VR12PhysicalAssessment
    let VR12MentalAssessmentTime: start of QICoreCommon."ToInterval" (VR12MentalAssessment.effective),
VR12PhysicalAssessmentTime: start of QICoreCommon."ToInterval"(VR12PhysicalAssessment.effective)          
     where VR12MentalAssessmentTime same day as VR12PhysicalAssessmentTime
        and VR12MentalAssessment.value is not null
        and VR12PhysicalAssessment.value is not null
    return Max({  VR12MentalAssessmentTime, VR12PhysicalAssessmentTime })

