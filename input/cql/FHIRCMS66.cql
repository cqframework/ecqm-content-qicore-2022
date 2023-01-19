/*
@title: Functional Status Assessment for Total Knee Replacement
@identifier: CMS66
*/
library FHIRCMS66 version '0.0.001'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include QICoreCommon version '1.2.000' called QICoreCommon
include CQMCommon version '1.0.000' called CQMCommon
include SupplementalDataElements version '3.0.000' called SDE
include HospiceQICore4 version '3.0.000' called Hospice
include StatusFHIR version '1.0.0' called Status 

codesystem "LOINC": 'http://loinc.org' 
codesystem "CPT": 'http://www.ama-assn.org/go/cpt' 
codesystem "SNOMEDCT": 'http://snomed.info/sct' 

valueset "Ethnicity": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.837' 
valueset "Fracture - Lower Body": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.113.12.1037' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "ONC Administrative Sex": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Outpatient Consultation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1008' 
valueset "Payer": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.3591' 
valueset "Primary TKA Procedure": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1007' 
valueset "Race": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.836' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 

code "Activities of daily living score [KOOS]": '72100-1' from "LOINC" display 'Activities of daily living score [KOOS]'
code "Knee injury and osteoarthritis outcome score for joint replacement [KOOSJR]": '82324-5' from "LOINC" display 'Knee injury and osteoarthritis outcome score for joint replacement [KOOSJR]'
code "Pain score [KOOS]": '72102-7' from "LOINC" display 'Pain score [KOOS]'
code "Postoperative follow-up visit, normally included in the surgical package, to indicate that an evaluation and management service was performed during a postoperative period for a reason(s) related to the original procedure": '99024' from "CPT" display 'Postoperative follow-up visit, normally included in the surgical package, to indicate that an evaluation and management service was performed during a postoperative period for a reason(s) related to the original procedure'
code "PROMIS-10 Global Mental Health (GMH) score T-score": '71969-0' from "LOINC" display 'PROMIS-10 Global Mental Health (GMH) score T-score'
code "PROMIS-10 Global Physical Health (GPH) score T-score": '71971-6' from "LOINC" display 'PROMIS-10 Global Physical Health (GPH) score T-score'
code "Quality of life score [KOOS]": '72098-7' from "LOINC" display 'Quality of life score [KOOS]'
code "Severe dementia (disorder)": '428351000124105' from "SNOMEDCT" display 'Severe dementia (disorder)'
code "Sport-recreation score [KOOS]": '72099-5' from "LOINC" display 'Sport-recreation score [KOOS]'
code "Symptoms score [KOOS]": '72101-9' from "LOINC" display 'Symptoms score [KOOS]'
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
  "Has Qualifying Encounters"
    and exists ( "Total Knee Arthroplasty Procedure" )
    and AgeInYearsAt(date from start of "Measurement Period")>= 19

define "Has Qualifying Encounters":
  exists (( Status."Finished Encounter"( ( [Encounter: "Outpatient Consultation"]
    union [Encounter: "Office Visit"]
    union [Encounter: "Postoperative follow-up visit, normally included in the surgical package, to indicate that an evaluation and management service was performed during a postoperative period for a reason(s) related to the original procedure"] 
    union [Encounter: "Telephone Visits"]
    union [Encounter: "Online Assessments"]  ))) ValidEncounters
        where QICoreCommon."ToInterval"(ValidEncounters.period) during day of "Measurement Period"
      )

define "Total Knee Arthroplasty Procedure":
  (Status."Completed Procedure"([Procedure: "Primary TKA Procedure"])) TKAProcedure
    where QICoreCommon."ToInterval"(TKAProcedure.performed) starts 12 months or less before start of "Measurement Period"

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice Services"
    or "Has Total Knee Arthroplasty with 2 or More Lower Body Fractures"
    or "Has Dementia Diagnosis"

define "Has Total Knee Arthroplasty with 2 or More Lower Body Fractures":
  exists ( "Total Knee Arthroplasty Procedure" TKAProcedure
    where Count(["Condition": "Fracture - Lower Body"] LowerBodyFracture
    where QICoreCommon."ToPrevalenceInterval"(LowerBodyFracture) starts 24 hours or less on or before start of QICoreCommon."ToInterval"(TKAProcedure.performed))>= 2
  )

define "Has Dementia Diagnosis":
  exists ( [Condition: "Severe dementia (disorder)"] Dementia
    where QICoreCommon."ToPrevalenceInterval"(Dementia) overlaps "Measurement Period"
)

define "Numerator":
  "Has TKA with Initial and Follow Up KOOS Assessments"
    or "Has TKA with Initial and Follow Up KOOSJr Assessments"
    or "Has TKA with Initial and Follow Up PROMIS10 Assessments"
    or "Has TKA with Initial and Follow Up VR12 Oblique Assessments"
    or "Has TKA with Initial and Follow Up VR12 Orthogonal Assessments"

define "Has TKA with Initial and Follow Up KOOS Assessments":
  exists (( "Total Knee Arthroplasty Procedure" TKAProcedure
    return QICoreCommon."ToInterval" (TKAProcedure.performed)) TotalKnee
    with "Time KOOS Total Assessment Completed" InitialKOOSAssessmentTime
      such that TotalKnee starts 90 days or less on or after InitialKOOSAssessmentTime
    with "Time KOOS Total Assessment Completed" FollowupKOOSAssessmentTime
          such that FollowupKOOSAssessmentTime during day of Interval[
              end of TotalKnee + 270 days,
              end of TotalKnee + 365 days]
        )

define "Time KOOS Total Assessment Completed":
  from
    (Status."Final Survey Observation"([Observation: "Quality of life score [KOOS]"])) KOOSLifeQuality,
    (Status."Final Survey Observation"([Observation: "Sport-recreation score [KOOS]"])) KOOSSport,
    (Status."Final Survey Observation"([Observation: "Activities of daily living score [KOOS]"])) KOOSActivityScore,
    (Status."Final Survey Observation"([Observation: "Symptoms score [KOOS]"])) KOOSSymptoms,
    (Status."Final Survey Observation"([Observation: "Pain score [KOOS]"])) KOOSPain
    let KOOSLifeQualityTime: start of QICoreCommon."ToInterval"(KOOSLifeQuality.effective),
    KOOSSportTime: start of QICoreCommon."ToInterval"(KOOSSport.effective),
    KOOSActivityScoreTime: start of QICoreCommon."ToInterval"(KOOSActivityScore.effective),
    KOOSSymptomsTime: start of QICoreCommon."ToInterval"(KOOSSymptoms.effective),
    KOOSPainTime: start of QICoreCommon."ToInterval"(KOOSPain.effective)
    where KOOSLifeQualityTime same day as KOOSSportTime
        and KOOSSport.value is not null
        and KOOSLifeQualityTime same day as KOOSActivityScoreTime
        and KOOSActivityScore.value is not null
        and KOOSLifeQualityTime same day as KOOSSymptomsTime
        and KOOSSymptoms.value is not null
        and KOOSLifeQualityTime same day as KOOSPainTime
        and KOOSPain.value is not null
        and KOOSLifeQuality.value is not null
      return Max({ KOOSLifeQualityTime, KOOSSportTime, KOOSActivityScoreTime, KOOSSymptomsTime, KOOSPainTime })

define "Has TKA with Initial and Follow Up KOOSJr Assessments":
  exists (("Total Knee Arthroplasty Procedure" TKAProcedure
  return QICoreCommon."ToInterval" ( TKAProcedure.performed )) TotalKnee
    with "KOOSJr Total Assessment Completed" InitialKOOSJrAssessment
      such that TotalKnee starts 90 days or less on or after InitialKOOSJrAssessment
    with "KOOSJr Total Assessment Completed" FollowupKOOSJrAssessment
      such that FollowupKOOSJrAssessment during day of Interval[
      end of TotalKnee + 270 days,
      end of TotalKnee + 365 days]
)

define "KOOSJr Total Assessment Completed":
  ((Status."Final Survey Observation"(( [Observation: "Knee injury and osteoarthritis outcome score for joint replacement [KOOSJR]"]))) KOOSJr
    where KOOSJr.value is not null) DocumentedKOOSJr
  return start of QICoreCommon."ToInterval" ( DocumentedKOOSJr.effective )

define "Has TKA with Initial and Follow Up PROMIS10 Assessments":
  exists (( "Total Knee Arthroplasty Procedure" TKAProcedure
    return QICoreCommon."ToInterval" ( TKAProcedure.performed ) ) TotalKnee
    with "Time PROMIS10 Total Assessment Completed" InitialPROMIS10AssessmentTime
      such that QICoreCommon."ToInterval"(TotalKnee) starts 90 days or less on or after InitialPROMIS10AssessmentTime
    with "Time PROMIS10 Total Assessment Completed" FollowupPROMIS10AssessmentTime
      such that FollowupPROMIS10AssessmentTime during day of Interval[
      end of TotalKnee + 270 days,
      end of TotalKnee + 365 days]
)

define "Time PROMIS10 Total Assessment Completed":
  from
    (Status."Final Survey Observation"([Observation: "PROMIS-10 Global Mental Health (GMH) score T-score"])) PROMIS10MentalScore,
    (Status."Final Survey Observation"([Observation: "PROMIS-10 Global Physical Health (GPH) score T-score"])) PROMIS10PhysicalScore
    let PROMIS10MentalScoreTime: start of QICoreCommon."ToInterval"(PROMIS10MentalScore.effective),
    PROMIS10PhysicalScoreTime: start of QICoreCommon."ToInterval"( PROMIS10PhysicalScore.effective)
    where PROMIS10MentalScoreTime same day as PROMIS10PhysicalScoreTime
        and PROMIS10PhysicalScore.value is not null
        and PROMIS10MentalScore.value is not null
      return Max({ PROMIS10MentalScoreTime, PROMIS10PhysicalScoreTime })

define "Has TKA with Initial and Follow Up VR12 Oblique Assessments":
  exists (( "Total Knee Arthroplasty Procedure" TKAProcedure
  return QICoreCommon."ToInterval" ( TKAProcedure.performed ) ) TotalKnee
    with "Time VR12 Oblique Total Assessment Completed" InitialKneeAssessmentObliqueTime
      such that TotalKnee starts 90 days or less on or after InitialKneeAssessmentObliqueTime
    with "Time VR12 Oblique Total Assessment Completed" FollowupObliqueAssessmentTime
      such that FollowupObliqueAssessmentTime in Interval[
      end of TotalKnee + 270 days,
      end of TotalKnee + 365 days]
)

define "Time VR12 Oblique Total Assessment Completed":
  from
    (Status."Final Survey Observation"([Observation: "VR-12 Mental component summary (MCS) score - oblique method T-score"])) VR12MentalAssessment,
    (Status."Final Survey Observation"([Observation: "VR-12 Physical component summary (PCS) score - oblique method T-score"])) VR12PhysicalAssessment
    let VR12MentalAssessmentTime: start of QICoreCommon."ToInterval"( VR12MentalAssessment.effective),
    VR12PhysicalAssessmentTime: start of QICoreCommon."ToInterval"( VR12PhysicalAssessment.effective)           
    where VR12MentalAssessmentTime same day as VR12PhysicalAssessmentTime
        and VR12MentalAssessment.value is not null
        and VR12PhysicalAssessment.value is not null
    return Max({ VR12MentalAssessmentTime, VR12PhysicalAssessmentTime })

define "Has TKA with Initial and Follow Up VR12 Orthogonal Assessments":
  exists (( "Total Knee Arthroplasty Procedure" TKAProcedure
  return QICoreCommon."ToInterval" ( TKAProcedure.performed ) ) TotalKnee
    with "Time VR12 Orthogonal Total Assessment Completed" InitialOrthogonalAssessmentTime
      such that TotalKnee starts 90 days or less on or after InitialOrthogonalAssessmentTime
    with "Time VR12 Orthogonal Total Assessment Completed" FollowupOrthogonalAssessmentTime
      such that FollowupOrthogonalAssessmentTime in Interval[
      end of TotalKnee + 270 days,
      end of TotalKnee + 365 days]
)

define "Time VR12 Orthogonal Total Assessment Completed":
  from
    (Status."Final Survey Observation"([Observation: "VR-12 Mental component summary (MCS) score - orthogonal method T-score"])) VR12MentalAssessment,
    (Status."Final Survey Observation"([Observation: "VR-12 Physical component summary (PCS) score - orthogonal method T-score"])) VR12PhysicalAssessment
    let VR12MentalAssessmentTime: start of QICoreCommon."ToInterval"( VR12MentalAssessment.effective),
    VR12PhysicalAssessmentTime: start of QICoreCommon."ToInterval"( VR12PhysicalAssessment.effective)
    where VR12MentalAssessmentTime same day as VR12PhysicalAssessmentTime
        and VR12MentalAssessment.value is not null
        and VR12PhysicalAssessment.value is not null
      return Max({ VR12MentalAssessmentTime, VR12PhysicalAssessmentTime })
