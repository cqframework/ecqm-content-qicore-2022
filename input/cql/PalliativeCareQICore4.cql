library PalliativeCareQICore4 version '1.0.000'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance. Tests are available for this content.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include QICoreCommon version '1.2.000' called QICoreCommon
include CQMCommon version '1.0.000' called CQMCommon
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
