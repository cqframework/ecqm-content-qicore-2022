library DepressionRemissionatTwelveMonthsQICore4 version '0.0.001'

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include SupplementalDataElements version '3.0.000' called SDE
include QICoreCommon version '1.2.000' called QICoreCommon
include CQMCommon version '1.0.000' called CQMCommon

codesystem "LOINC": 'http://loinc.org' 
codesystem "SNOMEDCT": 'http://snomed.info/sct' 
codesystem "ICD10CM": 'http://hl7.org/fhir/sid/icd-10-cm' 

valueset "Bipolar Disorder": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.67.1.101.1.128' 
valueset "Care Services in Long-Term Residential Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1014' 
valueset "Contact or Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1080.5' 
valueset "Dysthymia": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.67.1.101.1.254' 
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307' 
valueset "Hospice Care Ambulatory": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1584' 
valueset "Hospice Encounter": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1003' 
valueset "Major Depression Including Remission": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.113883.3.67.1.101.3.2444' 
valueset "Palliative Care Encounter": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1090' 
valueset "Palliative Care Intervention": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1135' 
valueset "Palliative or Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1.1579' 
valueset "Personality Disorder Emotionally Labile": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.67.1.101.1.246' 
valueset "Pervasive Developmental Disorder": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.105.12.1152' 
valueset "PHQ 9 and PHQ 9M Tools": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.67.1.101.1.263' 
valueset "Schizophrenia or Psychotic Disorder": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.105.12.1104' 

code "Birth date": '21112-8' from "LOINC" display 'Birth date'
code "Dead (finding)": '419099009' from "SNOMEDCT" display 'Dead (finding)'
code "Discharge to healthcare facility for hospice care (procedure)": '428371000124100' from "SNOMEDCT" display 'Discharge to healthcare facility for hospice care (procedure)'
code "Discharge to home for hospice care (procedure)": '428361000124107' from "SNOMEDCT" display 'Discharge to home for hospice care (procedure)'
code "Encounter for palliative care": 'Z51.5' from "ICD10CM" display 'Encounter for palliative care'
code "Functional Assessment of Chronic Illness Therapy - Palliative Care Questionnaire (FACIT-Pal)": '71007-9' from "LOINC" display 'Functional Assessment of Chronic Illness Therapy - Palliative Care Questionnaire (FACIT-Pal)'
code "Hospice care [Minimum Data Set]": '45755-6' from "LOINC" display 'Hospice care [Minimum Data Set]'
code "Yes (qualifier value)": '373066001' from "SNOMEDCT" display 'Yes (qualifier value)'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Identification Period":
  Interval[start of "Measurement Period" - 14 months, start of "Measurement Period" - 2 months )

define "Depression Diagnoses":
  ["Condition": "Major Depression Including Remission"]
          union ["Condition": "Dysthymia"]

define "Has Long Term Care Encounter":
  exists ( ["Encounter": "Care Services in Long-Term Residential Facility"] EncounterLongTermCare
            where ToDate(start of EncounterLongTermCare.period)on or before 
            end of "Measure Assessment Period"
        )

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

define "test1":
  exists ( ["Encounter": "Palliative or Hospice Care"] HospiceEncounter
            where HospiceEncounter.period starts during Interval[start of "Denominator Identification Period", 
            end of "Measure Assessment Period"]
        )

define "Denominator Exclusions":
  "Has Hospice Services"
          or "Palliative Care in the Measure Assessment Period"
          or "Has Long Term Care Encounter"
          or "Patient Expired"
          or "Has Mental Health Disorder Diagnoses"

define "Depression Assessments Greater than 9":
  ["Observation": "PHQ 9 and PHQ 9M Tools"] DepressionAssessment
        where DepressionAssessment.value > 9

define "Depression Encounter":
  ["Encounter": "Contact or Office Visit"] ValidEncounter
        with "Depression Diagnoses" Depression
          such that ValidEncounter.period overlaps Depression.onset
            and ValidEncounter.period ends during "Denominator Identification Period"

define "Denominator":
  "Initial Population"

define "Index Depression Assessment":
  First("Depression Assessments Greater than 9" DepressionAssessment
          with "Depression Encounter" DepressionEncounter
            such that QICoreCommon.ToInterval(DepressionAssessment.effective)is not null
              and QICoreCommon.ToInterval(DepressionAssessment.effective)during Interval[ToDate((start of DepressionEncounter.period)- 7 days), 
              end of DepressionEncounter.period]
          sort by start of QICoreCommon.ToInterval(effective)
      )

define "Initial Population":
  AgeInYearsAt(start of QICoreCommon.ToInterval("Index Depression Assessment".effective))>= 12

define "Measure Assessment Period":
  "Index Depression Assessment" FirstIndexAssessment
        let YearAfterIndexAssessment: date from start of QICoreCommon.ToInterval ( FirstIndexAssessment.effective ) + 12 months
        return Interval[YearAfterIndexAssessment - 60 days, YearAfterIndexAssessment + 60 days]

define "Has Hospice Services":
  exists ( ["Encounter": "Encounter Inpatient"] InpatientEncounter
          where ( InpatientEncounter.hospitalization.dischargeDisposition ~ "Discharge to home for hospice care (procedure)"
              or InpatientEncounter.hospitalization.dischargeDisposition ~ "Discharge to healthcare facility for hospice care (procedure)"
          )
            and InpatientEncounter.period ends during day of Interval[start of "Denominator Identification Period", 
            end of "Measure Assessment Period"]
      )
        or exists ( ["Encounter": "Hospice Encounter"] HospiceEncounter
            where HospiceEncounter.period overlaps Interval[start of "Denominator Identification Period", 
            end of "Measure Assessment Period"]
        )
        or exists ( ["Observation": "Hospice care [Minimum Data Set]"] HospiceAssessment
            where HospiceAssessment.value ~ "Yes (qualifier value)"
              and QICoreCommon.ToInterval ( HospiceAssessment.effective ) overlaps Interval[start of "Denominator Identification Period",
              end of "Measure Assessment Period"]
        )
        or exists ( ["ServiceRequest": "Hospice Care Ambulatory"] HospiceOrder
            where HospiceOrder.authoredOn during day of Interval[start of "Denominator Identification Period", 
            end of "Measure Assessment Period"]
        )
        or exists ( ["Procedure": "Hospice Care Ambulatory"] HospicePerformed
            where QICoreCommon.ToInterval ( HospicePerformed.performed ) overlaps Interval[start of "Denominator Identification Period", 
            end of "Measure Assessment Period"]
        )

define "Numerator":
  Last(["Observation": "PHQ 9 and PHQ 9M Tools"] DepressionAssessment
          where ToDate(start of QICoreCommon.ToInterval(DepressionAssessment.effective))during "Measure Assessment Period"
          sort by start of QICoreCommon.ToInterval(effective)
      ).value < 5

define "Has Mental Health Disorder Diagnoses":
  exists ( ( ["Condition": "Bipolar Disorder"]
          union ["Condition": "Personality Disorder Emotionally Labile"]
          union ["Condition": "Schizophrenia or Psychotic Disorder"]
          union ["Condition": "Pervasive Developmental Disorder"] ) MentalHealthDisorderDiagnoses
          where MentalHealthDisorderDiagnoses.onset on or before 
          end of "Measure Assessment Period"
      )

define "Patient Expired":
  Patient.deceased on or before 
      end of "Measure Assessment Period"

define "Palliative Care in the Measure Assessment Period":
  exists ( ["Observation": "Functional Assessment of Chronic Illness Therapy - Palliative Care Questionnaire (FACIT-Pal)"] PalliativeAssessment
        where QICoreCommon.ToInterval ( PalliativeAssessment.effective ) overlaps Interval[start of "Denominator Identification Period", 
        end of "Measure Assessment Period"]
    )
      or exists ( ["Condition": "Encounter for palliative care"] PalliativeDiagnosis
          where PalliativeDiagnosis.onset overlaps Interval[start of "Denominator Identification Period", 
          end of "Measure Assessment Period"]
      )
      or exists ( ["Encounter": "Palliative Care Encounter"] PalliativeEncounter
          where PalliativeEncounter.period overlaps Interval[start of "Denominator Identification Period", 
          end of "Measure Assessment Period"]
      )
      or exists ( ["Procedure": "Palliative Care Intervention"] PalliativeIntervention
          where QICoreCommon.ToInterval ( PalliativeIntervention.performed ) overlaps Interval[start of "Denominator Identification Period", 
          end of "Measure Assessment Period"]
      )

define "Stratification 1":
  "Index Depression Assessment" IndexAssessment
    where AgeInYearsAt(date from start of QICoreCommon.ToInterval(IndexAssessment.effective))in Interval[12, 17]

define "Stratification 2":
  "Index Depression Assessment" IndexAssessment
    where AgeInYearsAt(date from start of QICoreCommon.ToInterval(IndexAssessment.effective))>= 18

define function "test"():
  exists ( ["Observation": "Functional Assessment of Chronic Illness Therapy - Palliative Care Questionnaire (FACIT-Pal)"] PalliativeAssessment
      where QICoreCommon.ToInterval ( PalliativeAssessment.effective ) overlaps "Measurement Period"
  )
    or exists ( ["Condition": "Encounter for palliative care"] PalliativeDiagnosis
        where PalliativeDiagnosis.onset overlaps "Measure Assessment Period"
    )
    or exists ( ["Encounter": "Palliative Care Encounter"] PalliativeEncounter
        where PalliativeEncounter.period overlaps "Measurement Period"
    )
    or exists ( ["Procedure": "Palliative Care Intervention"] PalliativeIntervention
        where QICoreCommon.ToInterval ( PalliativeIntervention.performed ) overlaps "Measurement Period"
    )

