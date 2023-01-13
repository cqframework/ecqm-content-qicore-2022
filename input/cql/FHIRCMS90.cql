library FunctionalStatusAssessmentsforHeartFailureFHIR version '0.0.001'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include QICoreCommon version '1.2.000' called QICoreCommon
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include SupplementalDataElementsQICore4 version '3.0.000' called SDE
include HospiceQICore4 version '3.0.000' called Hospice
include StatusFHIR version '1.0.0' called Status

codesystem "LOINC": 'http://loinc.org' 
codesystem "SNOMEDCT": 'http://snomed.info/sct' 

valueset "Heart Failure": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.376' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 

code "Emotional score [MLHFQ]": '85609-6' from "LOINC" display 'Emotional score [MLHFQ]'
code "Kansas City Cardiomyopathy Questionnaire - 12 item [KCCQ-12]": '86923-0' from "LOINC" display 'Kansas City Cardiomyopathy Questionnaire - 12 item [KCCQ-12]'
code "Overall summary score [KCCQ-12]": '86924-8' from "LOINC" display 'Overall summary score [KCCQ-12]'
code "Overall summary score [KCCQ]": '71940-1' from "LOINC" display 'Overall summary score [KCCQ]'
code "Physical limitation score [KCCQ]": '72195-1' from "LOINC" display 'Physical limitation score [KCCQ]'
code "Physical score [MLHFQ]": '85618-7' from "LOINC" display 'Physical score [MLHFQ]'
code "PROMIS-10 Global Mental Health (GMH) score T-score": '71969-0' from "LOINC" display 'PROMIS-10 Global Mental Health (GMH) score T-score'
code "PROMIS-10 Global Physical Health (GPH) score T-score": '71971-6' from "LOINC" display 'PROMIS-10 Global Physical Health (GPH) score T-score'
code "PROMIS-29 Anxiety score T-score": '71967-4' from "LOINC" display 'PROMIS-29 Anxiety score T-score'
code "PROMIS-29 Depression score T-score": '71965-8' from "LOINC" display 'PROMIS-29 Depression score T-score'
code "PROMIS-29 Fatigue score T-score": '71963-3' from "LOINC" display 'PROMIS-29 Fatigue score T-score'
code "PROMIS-29 Pain interference score T-score": '71961-7' from "LOINC" display 'PROMIS-29 Pain interference score T-score'
code "PROMIS-29 Physical function score T-score": '71959-1' from "LOINC" display 'PROMIS-29 Physical function score T-score'
code "PROMIS-29 Satisfaction with participation in social roles score T-score": '71957-5' from "LOINC" display 'PROMIS-29 Satisfaction with participation in social roles score T-score'
code "PROMIS-29 Sleep disturbance score T-score": '71955-9' from "LOINC" display 'PROMIS-29 Sleep disturbance score T-score'
code "Quality of life score [KCCQ]": '72189-4' from "LOINC" display 'Quality of life score [KCCQ]'
code "Self-efficacy score [KCCQ]": '72190-2' from "LOINC" display 'Self-efficacy score [KCCQ]'
code "Severe dementia (disorder)": '428351000124105' from "SNOMEDCT" display 'Severe dementia (disorder)'
code "Social limitation score [KCCQ]": '72196-9' from "LOINC" display 'Social limitation score [KCCQ]'
code "survey": 'survey' from "ObservationCategoryCodes" display 'Survey'
code "Symptom stability score [KCCQ]": '72194-4' from "LOINC" display 'Symptom stability score [KCCQ]'
code "Total score [MLHFQ]": '71938-5' from "LOINC" display 'Total score [MLHFQ]'
code "Total symptom score [KCCQ]": '72191-0' from "LOINC" display 'Total symptom score [KCCQ]'
code "VR-12 Mental component summary (MCS) score - oblique method T-score": '72026-8' from "LOINC" display 'VR-12 Mental component summary (MCS) score - oblique method T-score'
code "VR-12 Mental component summary (MCS) score - orthogonal method T-score": '72028-4' from "LOINC" display 'VR-12 Mental component summary (MCS) score - orthogonal method T-score'
code "VR-12 Physical component summary (PCS) score - oblique method T-score": '72025-0' from "LOINC" display 'VR-12 Physical component summary (PCS) score - oblique method T-score'
code "VR-12 Physical component summary (PCS) score - orthogonal method T-score": '72027-6' from "LOINC" display 'VR-12 Physical component summary (PCS) score - orthogonal method T-score'
code "VR-36 Mental component summary (MCS) score - oblique method T-score": '71990-6' from "LOINC" display 'VR-36 Mental component summary (MCS) score - oblique method T-score'
code "VR-36 Mental component summary (MCS) score - orthogonal method T-score": '72008-6' from "LOINC" display 'VR-36 Mental component summary (MCS) score - orthogonal method T-score'
code "VR-36 Physical component summary (PCS) score - oblique method T-score": '71989-8' from "LOINC" display 'VR-36 Physical component summary (PCS) score - oblique method T-score'
code "VR-36 Physical component summary (PCS) score - orthogonal method T-score": '72007-8' from "LOINC" display 'VR-36 Physical component summary (PCS) score - orthogonal method T-score'

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
  AgeInYearsAt(date from start of "Measurement Period") >= 18                                      
          and exists (Status."Active Condition"( [Condition: "Heart Failure"]) HeartFailure
              where QICoreCommon."ToPrevalenceInterval"(HeartFailure) overlaps before "Measurement Period"
                     )
          and exists ( "Two Outpatient Encounters during Measurement Period" )

define "Two Outpatient Encounters during Measurement Period":
  from
    "Qualifying Encounters" OfficeVisit1,
    "Qualifying Encounters" OfficeVisit2
        where QICoreCommon."ToInterval"(OfficeVisit2.period) starts 1 day or more after day of end of QICoreCommon."ToInterval"(OfficeVisit1.period)
              return OfficeVisit1

define "Qualifying Encounters":
  Status."Finished Encounter"([Encounter: "Office Visit"]
      union [Encounter: "Telephone Visits"]
      union [Encounter: "Online Assessments"]) ValidEncounters
        and QICoreCommon."ToInterval"(ValidEncounters.period) during day of "Measurement Period"

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Hospice."Has Hospice Services"
      or exists (Status."Active Condition"([Condition: "Severe dementia (disorder)"]) Dementia
                    where QICoreCommon."ToPrevalenceInterval"(Dementia) overlaps before "Measurement Period"
                )

define "Numerator":
  ( "Has Encounter with Initial and Follow Up PROMIS10 Assessments" )
      or ( "Has Encounter with Initial and Follow Up PROMIS29 Assessments" )
      or ( "Has Encounter with Initial and Follow Up VR12 Oblique Assessments" )
      or ( "Has Encounter with Initial and Follow Up VR12 Orthogonal Assessments" )
      or ( "Has Encounter with Initial and Follow Up VR36 Oblique Assessments" )
      or ( "Has Encounter with Initial and Follow Up VR36 Orthogonal Assessments" )
      or ( "Has Encounter with Initial and Follow Up MLHFQ Assessments" )
      or ( "Has Encounter with Initial and Follow Up KCCQ12 Assessments" )
      or ( "Has Encounter with Initial and Follow Up KCCQ Domain Score Assessments" )
      or ( "Has Encounter with Initial and Follow Up KCCQ Total Score Assessments" )

define "Has Encounter with Initial and Follow Up PROMIS10 Assessments":
  exists ( from
      "Qualifying Encounters" ValidEncounters,
      "Time PROMIS10 Total Assessment Completed" InitialPROMIS10Time,
      "Time PROMIS10 Total Assessment Completed" FollowupPROMIS10Time
          where QICoreCommon."ToInterval"(ValidEncounters.period) ends 180 days or more before end of "Measurement Period"
              and InitialPROMIS10Time 14 days or less on or before day of end of QICoreCommon."ToInterval"(ValidEncounters.period)
              and date from FollowupPROMIS10Time during day of Interval[date from InitialPROMIS10Time + 30 days, date from InitialPROMIS10Time + 180 days]
                  return ValidEncounters
          )

define "Time PROMIS10 Total Assessment Completed":
  from
    Status."Final Survey Observation"([Observation: "PROMIS-10 Global Mental Health (GMH) score T-score"]) PROMIS10MentalScore,
    Status."Final Survey Observation"([Observation: "PROMIS-10 Global Physical Health (GPH) score T-score"]) PROMIS10PhysicalScore
    let PROMIS10MentalScoreTime: start of QICoreCommon."ToInterval"(PROMIS10MentalScore.effective),
      PROMIS10PhysicalScoreTime: start of QICoreCommon."ToInterval"( PROMIS10PhysicalScore.effective)
        where PROMIS10MentalScoreTime same day as PROMIS10PhysicalScoreTime
            and PROMIS10PhysicalScore.value is not null
            and PROMIS10MentalScore.value is not null
            return Max({ PROMIS10MentalScoreTime, PROMIS10PhysicalScoreTime })

define "Has Encounter with Initial and Follow Up PROMIS29 Assessments":
  exists ( from
      "Qualifying Encounters" ValidEncounters,
      "Time PROMIS29 Total Assessment Completed" InitialPROMIS29Time,
      "Time PROMIS29 Total Assessment Completed" FollowupPROMIS29Time
                    where QICoreCommon."ToInterval"(ValidEncounters.period) ends 180 days or more before end of "Measurement Period"
                        and InitialPROMIS29Time 14 days or less on or before day of end of QICoreCommon."ToInterval"(ValidEncounters.period)
                        and date from FollowupPROMIS29Time during day of Interval[date from InitialPROMIS29Time + 30 days, date from InitialPROMIS29Time + 180 days]
                            return ValidEncounters
                              	)

define "Time PROMIS29 Total Assessment Completed":
  from
    Status."Final Survey Observation"([Observation: "PROMIS-29 Sleep disturbance score T-score"]) Promis29Sleep,
    Status."Final Survey Observation"([Observation: "PROMIS-29 Satisfaction with participation in social roles score T-score"]) Promis29SocialRoles,
    Status."Final Survey Observation"([Observation: "PROMIS-29 Physical function score T-score"]) Promis29Physical,
    Status."Final Survey Observation"([Observation: "PROMIS-29 Pain interference score T-score"]) Promis29Pain,
    Status."Final Survey Observation"([Observation: "PROMIS-29 Fatigue score T-score"]) Promis29Fatigue,
    Status."Final Survey Observation"([Observation: "PROMIS-29 Depression score T-score"]) Promis29Depression,
    Status."Final Survey Observation"([Observation: "PROMIS-29 Anxiety score T-score"]) Promis29Anxiety
      let Promis29SleepTime: start of QICoreCommon."ToInterval"(Promis29Sleep.effective), 
          Promis29SocialRolesTime: start of QICoreCommon."ToInterval"(Promis29SocialRoles.effective),
          Promis29PhysicalTime: start of QICoreCommon."ToInterval"(Promis29Physical.effective), 
          Promis29PainTime: start of QICoreCommon."ToInterval"(Promis29Pain.effective), 
          Promis29FatigueTime: start of QICoreCommon."ToInterval"(Promis29Fatigue.effective), 
          Promis29DepressionTime: start of QICoreCommon."ToInterval"(Promis29Depression.effective), 
          Promis29AnxietyTime: start of QICoreCommon."ToInterval"(Promis29Anxiety.effective) 
            where Promis29SleepTime same day as Promis29SocialRolesTime
              and Promis29SocialRoles.value is not null
              and Promis29SleepTime same day as Promis29PhysicalTime
              and Promis29Physical.value is not null
              and Promis29SleepTime same day as Promis29PainTime
              and Promis29Pain.value is not null
              and Promis29SleepTime same day as Promis29FatigueTime
              and Promis29Fatigue.value is not null
              and Promis29SleepTime same day as Promis29DepressionTime
              and Promis29Depression.value is not null
              and Promis29SleepTime same day as Promis29AnxietyTime
              and Promis29Anxiety.value is not null
              and Promis29Sleep.value is not null
                return Max({ Promis29SleepTime, Promis29SocialRolesTime, Promis29PhysicalTime, Promis29PainTime, Promis29FatigueTime, Promis29DepressionTime, Promis29AnxietyTime })

define "Has Encounter with Initial and Follow Up VR12 Oblique Assessments":
  exists 
      (from "Qualifying Encounters" ValidEncounters,
          "Time VR12 Oblique Total Assessment Completed" InitialVR12ObliqueTime,
          "Time VR12 Oblique Total Assessment Completed" FollowupVR12ObliqueTime
              where QICoreCommon."ToInterval"(ValidEncounters.period) ends 180 days or more before end of "Measurement Period"
                  and InitialVR12ObliqueTime 14 days or less on or before day of end of QICoreCommon."ToInterval"(ValidEncounters.period)
                  and date from FollowupVR12ObliqueTime during day of Interval[date from InitialVR12ObliqueTime + 30 days, date from InitialVR12ObliqueTime + 180 days]
                      return ValidEncounters
                  )

define "Time VR12 Oblique Total Assessment Completed":
  from
      [Observation: "VR-12 Mental component summary (MCS) score - oblique method T-score"] VR12MentalAssessment,
      [Observation: "VR-12 Physical component summary (PCS) score - oblique method T-score"] VR12PhysicalAssessment
      let VR12MentalAssessmentTime: start of QICoreCommon."ToInterval" ( VR12MentalAssessment.effective),
          VR12PhysicalAssessmentTime: start of QICoreCommon."ToInterval" ( VR12PhysicalAssessment.effective)
              where VR12MentalAssessmentTime same day as VR12PhysicalAssessmentTime
                and VR12MentalAssessment.value is not null
                and VR12PhysicalAssessment.value is not null
                      return Max({ VR12MentalAssessmentTime, VR12PhysicalAssessmentTime })

define "Has Encounter with Initial and Follow Up VR12 Orthogonal Assessments":
  exists ( from
      "Qualifying Encounters" ValidEncounters,
      "Time VR12 Orthogonal Total Assessment Completed" InitialVR12OrthogonalTime,
      "Time VR12 Orthogonal Total Assessment Completed" FollowupVR12OrthogonalTime
          where QICoreCommon."ToInterval"(ValidEncounters.period) ends 180 days or more before end of "Measurement Period"
              and InitialVR12OrthogonalTime 14 days or less on or before day of end of QICoreCommon."ToInterval"(ValidEncounters.period)
              and date from FollowupVR12OrthogonalTime during day of Interval[date from InitialVR12OrthogonalTime + 30 days, date from InitialVR12OrthogonalTime + 180 days]
                      return ValidEncounters
                  )

define "Time VR12 Orthogonal Total Assessment Completed":
  from
    [Observation: "VR-12 Mental component summary (MCS) score - orthogonal method T-score"] VR12MentalAssessment,
    [Observation: "VR-12 Physical component summary (PCS) score - orthogonal method T-score"] VR12PhysicalAssessment
    let VR12MentalAssessmentTime: start of QICoreCommon."ToInterval"(VR12MentalAssessment.effective),
    VR12PhysicalAssessmentTime: start of QICoreCommon."ToInterval"(VR12PhysicalAssessment.effective )
        where VR12MentalAssessmentTime same day as VR12PhysicalAssessmentTime
          and VR12MentalAssessment.value is not null
          and VR12PhysicalAssessment.value is not null
                return Max({ VR12MentalAssessmentTime, VR12PhysicalAssessmentTime })

define "Has Encounter with Initial and Follow Up VR36 Oblique Assessments":
  exists ( from
      "Qualifying Encounters" ValidEncounters,
        "Time VR36 Oblique Total Assessment Completed" InitialVR36ObliqueTime,
        "Time VR36 Oblique Total Assessment Completed" FollowupVR36ObliqueTime
          where QICoreCommon."ToInterval"(ValidEncounters.period) ends 180 days or more before end of "Measurement Period"
              and InitialVR36ObliqueTime 14 days or less on or before day of end of QICoreCommon."ToInterval"(ValidEncounters.period)
              and date from FollowupVR36ObliqueTime during day of Interval[date from InitialVR36ObliqueTime + 30 days, date from InitialVR36ObliqueTime + 180 days]
                      return ValidEncounters
                  )

define "Time VR36 Oblique Total Assessment Completed":
  from
      [Observation: "VR-36 Mental component summary (MCS) score - oblique method T-score"] VR36MentalAssessment,
      [Observation: "VR-36 Physical component summary (PCS) score - oblique method T-score"] VR36PhysicalAssessment
      let VR36MentalAssessmentTime: start of QICoreCommon."ToInterval" ( VR36MentalAssessment.effective),
      VR36PhysicalAssessmentTime: start of QICoreCommon."ToInterval"( VR36PhysicalAssessment.effective)
         where VR36MentalAssessmentTime same day as VR36PhysicalAssessmentTime
          and VR36MentalAssessment.value is not null
          and VR36PhysicalAssessment.value is not null
                  return Max({ VR36MentalAssessmentTime, VR36PhysicalAssessmentTime })

define "Has Encounter with Initial and Follow Up VR36 Orthogonal Assessments":
  exists ( from
        "Qualifying Encounters" ValidEncounters,
        "Time VR36 Orthogonal Total Assessment Completed" InitialVR36OrthogonalTime,
        "Time VR36 Orthogonal Total Assessment Completed" FollowupVR36OrthogonalTime
            where QICoreCommon."ToInterval"(ValidEncounters.period) ends 180 days or more before end of "Measurement Period"
              and InitialVR36OrthogonalTime 14 days or less on or before day of end of QICoreCommon."ToInterval"(ValidEncounters.period)
              and date from FollowupVR36OrthogonalTime during day of Interval[date from InitialVR36OrthogonalTime + 30 days, date from InitialVR36OrthogonalTime + 180 days]
                      return ValidEncounters
        )

define "Time VR36 Orthogonal Total Assessment Completed":
  from
                [Observation: "VR-36 Mental component summary (MCS) score - orthogonal method T-score"] VR36MentalAssessment,
                [Observation: "VR-36 Physical component summary (PCS) score - orthogonal method T-score"] VR36PhysicalAssessment
                     let VR36MentalAssessmentTime: start of QICoreCommon."ToInterval"(VR36MentalAssessment.effective),
                  VR36PhysicalAssessmentTime: start of QICoreCommon."ToInterval"( VR36PhysicalAssessment.effective)
                  where VR36MentalAssessmentTime same day as VR36PhysicalAssessmentTime
                    and VR36MentalAssessment.value is not null
                    and VR36PhysicalAssessment.value is not null
                        return Max({ VR36MentalAssessmentTime, VR36PhysicalAssessmentTime  })

define "Has Encounter with Initial and Follow Up MLHFQ Assessments":
  exists ( from
                "Qualifying Encounters" ValidEncounters,
                "Time MLHFQ Total Assessment Completed" InitialMLHFQTime,
                "Time MLHFQ Total Assessment Completed" FollowupMLHFQTime
                    where QICoreCommon."ToInterval"(ValidEncounters.period) ends 180 days or more before end of "Measurement Period"
                        and InitialMLHFQTime 14 days or less on or before day of end of QICoreCommon."ToInterval"(ValidEncounters.period)
                        and date from FollowupMLHFQTime during day of Interval[date from InitialMLHFQTime + 30 days, date from InitialMLHFQTime + 180 days]
                        	    return ValidEncounters
                )

define "Time MLHFQ Total Assessment Completed":
  from
                [Observation: "Physical score [MLHFQ]"] MLHFQPhysical,
                [Observation: "Emotional score [MLHFQ]"] MLHFQEmotional
                    let MLHFQPhysicalTime: start of QICoreCommon."ToInterval"(MLHFQPhysical.effective),
                    MLHFQEmotionalTime: start of QICoreCommon."ToInterval"(MLHFQEmotional.effective)
                            where MLHFQPhysicalTime same day as MLHFQEmotionalTime
                              and MLHFQEmotional.value is not null
                              and MLHFQPhysical.value is not null
                                    return Max({ MLHFQPhysicalTime, MLHFQEmotionalTime  })

define "Has Encounter with Initial and Follow Up KCCQ12 Assessments":
  exists ( from
            "Qualifying Encounters"  ValidEncounters,
              "Time KCCQ12 Total Assessment Completed" InitialKCCQ12Time,
              "Time KCCQ12 Total Assessment Completed" FollowupKCCQ12Time
                    where QICoreCommon."ToInterval"(ValidEncounters.period) ends 180 days or more before end of "Measurement Period"
                      and InitialKCCQ12Time 14 days or less on or before day of end of QICoreCommon."ToInterval"(ValidEncounters.period)
                      and date from FollowupKCCQ12Time during day of Interval[date from InitialKCCQ12Time + 30 days, date from InitialKCCQ12Time + 180 days]
                          return ValidEncounters
            )

define "Time KCCQ12 Total Assessment Completed":
  from
    Status."Final Survey Observation"([Observation: "Kansas City Cardiomyopathy Questionnaire - 12 item [KCCQ-12]"]) KCCQ12Item,
    Status."Final Survey Observation"([Observation: "Overall summary score [KCCQ-12]"]) KCCQ12Summary
    let KCCQ12ItemTime: start of QICoreCommon."ToInterval"(KCCQ12Item.effective),
    KCCQ12SummaryTime: start of QICoreCommon."ToInterval"(KCCQ12Summary.effective)
            where KCCQ12ItemTime same day as KCCQ12SummaryTime
              and KCCQ12Summary.value is not null
              and KCCQ12Item.value is not null
                    return Max({ KCCQ12ItemTime, KCCQ12SummaryTime })

define "Has Encounter with Initial and Follow Up KCCQ Domain Score Assessments":
  exists ( from
              "Qualifying Encounters" ValidEncounters,
              "Time KCCQ Domain Assessment Completed" InitialKCCQAssessmentTime,
              "Time KCCQ Domain Assessment Completed" FollowupKCCQAssessmentTime
              where QICoreCommon."ToInterval"(ValidEncounters.period) ends 180 days or more before 
              end of "Measurement Period"
                and InitialKCCQAssessmentTime 14 days or less on or before day of
                end of QICoreCommon."ToInterval"(ValidEncounters.period)
                and date from FollowupKCCQAssessmentTime during day of Interval[date from InitialKCCQAssessmentTime + 30 days, date from InitialKCCQAssessmentTime + 180 days]
              return ValidEncounters
)

define "Time KCCQ Domain Assessment Completed":
  from
      Status."Final Survey Observation"([Observation: "Quality of life score [KCCQ]"]) KCCQLifeQuality,
      Status."Final Survey Observation"([Observation: "Symptom stability score [KCCQ]"]) KCCQSymptomStability,
      Status."Final Survey Observation"([Observation: "Self-efficacy score [KCCQ]"]) KCCQSelfEfficacy,
      Status."Final Survey Observation"([Observation: "Total symptom score [KCCQ]"]) KCCQSymptoms,
      Status."Final Survey Observation"([Observation: "Physical limitation score [KCCQ]"]) KCCQPhysicalLimits,
      Status."Final Survey Observation"([Observation: "Social limitation score [KCCQ]"]) KCCQSocialLimits
        let KCCQLifeQualityTime: start of QICoreCommon."ToInterval"(KCCQLifeQuality.effective),
          KCCQSymptomStabilityTime: start of QICoreCommon."ToInterval"(KCCQSymptomStability.effective),
          KCCQSelfEfficacyTime: start of QICoreCommon."ToInterval"( KCCQSelfEfficacy.effective),
          KCCQSymptomsTime: start of QICoreCommon."ToInterval"(KCCQSymptoms.effective),
          KCCQPhysicalLimitsTime: start of QICoreCommon."ToInterval"(KCCQPhysicalLimits.effective),
          KCCQSocialLimitsTime: start of QICoreCommon."ToInterval"(KCCQSocialLimits.effective)
              where KCCQLifeQualityTime same day as KCCQSymptomStabilityTime
                and KCCQSymptomStability.value is not null
                and KCCQLifeQualityTime same day as KCCQSelfEfficacyTime
                and KCCQSelfEfficacy.value is not null
                and KCCQLifeQualityTime same day as KCCQSymptomsTime
                and KCCQSymptoms.value is not null
                and KCCQLifeQualityTime same day as KCCQPhysicalLimitsTime
                and KCCQPhysicalLimits.value is not null
                and KCCQLifeQualityTime same day as KCCQSocialLimitsTime
                and KCCQSocialLimits.value is not null
                and KCCQLifeQuality.value is not null
                          return Max({ KCCQLifeQualityTime, KCCQSymptomStabilityTime, KCCQSelfEfficacyTime, KCCQSymptomsTime, KCCQPhysicalLimitsTime, KCCQSocialLimitsTime })

define "Time KCCQ Total Assessment Completed":
  Status."Final Survey Observation"([Observation: "Overall summary score [KCCQ]"]) KCCQSummaryScore
              let KCCQSummaryScoreTime: start of QICoreCommon."ToInterval"(KCCQSummaryScore.effective)
                  where KCCQSummaryScore.value is not null
                          return Max({KCCQSummaryScoreTime})

define "Has Encounter with Initial and Follow Up KCCQ Total Score Assessments":
  exists ( from
             "Qualifying Encounters" ValidEncounters,
             "Time KCCQ Total Assessment Completed" InitialKCCQTotalScore,
              "Time KCCQ Total Assessment Completed" FollowupKCCQTotalScore
                  where QICoreCommon."ToInterval"(ValidEncounters.period) ends 180 days or more before end of "Measurement Period"
                      and InitialKCCQTotalScore 14 days or less on or before end of QICoreCommon."ToInterval"(ValidEncounters.period)
                      and date from FollowupKCCQTotalScore during day of Interval[date from InitialKCCQTotalScore + 30 days, date from InitialKCCQTotalScore + 180 days]
                        	    return ValidEncounters
                )

