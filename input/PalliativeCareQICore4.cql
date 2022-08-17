library PalliativeCareQICore4 version '1.0.000'

using QICore version '4.1.1'

include FHIRHelpers version '4.0.012' called FHIRHelpers
// include FHIRCommon version '4.0.012' called FHIRCommon //https://github.com/cqframework/ecqm-content-qicore-2022/issues/5
include QICoreCommon version '1.0.000' called QICoreCommon
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include StatusFHIR version '1.0.0' called Status

codesystem "ICD10CM": 'http://hl7.org/fhir/sid/icd-10-cm'
codesystem "LOINC": 'http://loinc.org'

valueset "Palliative Care Encounter": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1090'
valueset "Palliative Care Intervention": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1135'

code "Encounter for palliative care": 'Z51.5' from "ICD10CM" display 'Encounter for palliative care'
code "Functional Assessment of Chronic Illness Therapy - Palliative Care Questionnaire (FACIT-Pal)": '71007-9' from "LOINC" display 'Functional Assessment of Chronic Illness Therapy - Palliative Care Questionnaire (FACIT-Pal)'

parameter "Measurement Period" Interval<DateTime>
    default Interval[@2023-01-01T00:00:00.000Z, @2024-01-01T00:00:00.000Z) 

context Patient

define "Palliative Care in the Measurement Period":
  exists ( (Status."Final Survey Observation"([Observation: "Functional Assessment of Chronic Illness Therapy - Palliative Care Questionnaire (FACIT-Pal)"])) PalliativeAssessment
      where QICoreCommon."ToInterval" ( PalliativeAssessment.effective ) overlaps "Measurement Period"
  )
    or exists ( [Condition: "Encounter for palliative care"] PalliativeEncounter
        where QICoreCommon."ToPrevalenceInterval" ( PalliativeEncounter ) overlaps "Measurement Period"
    )
    or exists ( (Status."Finished Encounter"([Encounter: "Palliative Care Encounter"])) PalliativeEncounter
        where QICoreCommon."ToInterval" ( PalliativeEncounter.period ) overlaps "Measurement Period"
    )
    or exists ( (Status."Completed Procedure"([Procedure: "Palliative Care Intervention"])) PalliativeIntervention
        where QICoreCommon."ToInterval" ( PalliativeIntervention.performed ) overlaps "Measurement Period"
    )