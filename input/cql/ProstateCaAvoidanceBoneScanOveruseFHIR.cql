library ProstateCaAvoidanceBoneScanOveruseFHIR version '0.0.009'

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include SupplementalDataElements version '3.1.000' called SDE
include FHIRCommon version '4.1.000' called FHIRCommon
include QICoreCommon version '1.2.000' called QICoreCommon

codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMEDCT": 'http://snomed.info/sct'

valueset "Bone Scan": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.320'
valueset "Pain Related to Prostate Cancer": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.451'
valueset "Prostate Cancer": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.319'
valueset "Prostate Cancer Treatment": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.398'
valueset "Prostate Specific Antigen Test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.401'
valueset "Salvage Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.399'

code "Gleason score in Specimen Qualitative": '35266-6' from "LOINC" display 'Gleason score in Specimen Qualitative'
code "Neoplasm of prostate primary tumor staging category T1c: Tumor identified by needle biopsy (finding)": '433351000124101' from "SNOMEDCT" display 'Neoplasm of prostate primary tumor staging category T1c: Tumor identified by needle biopsy (finding)'
code "Neoplasm of prostate primary tumor staging category T2a: Involves one-half of one lobe or less (finding)": '433361000124104' from "SNOMEDCT" display 'Neoplasm of prostate primary tumor staging category T2a: Involves one-half of one lobe or less (finding)'
code "Procedure reason record (record artifact)": '433611000124109' from "SNOMEDCT" display 'Procedure reason record (record artifact)'
code "T1a: Prostate tumor incidental histologic finding in 5% or less of tissue resected (finding)": '369833007' from "SNOMEDCT" display 'T1a: Prostate tumor incidental histologic finding in 5% or less of tissue resected (finding)'
code "T1b: Prostate tumor incidental histologic finding in > 5% of tissue resected (finding)": '369834001' from "SNOMEDCT" display 'T1b: Prostate tumor incidental histologic finding in > 5% of tissue resected (finding)'
code "Tumor staging (tumor staging)": '254292007' from "SNOMEDCT" display 'Tumor staging (tumor staging)'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2023-01-01T00:00:00.000Z, @2024-01-01T00:00:00.000Z)

context Patient

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

define "Denominator Exceptions":
  "Has Diagnosis of Pain Related to Prostate Cancer"
    or "Has Salvage Therapy Performed After Prostate Cancer Diagnosis"
    or "Has Bone Scan Study Performed with Documented Reason"

define "First Prostate Cancer Treatment During Measurement Period":
  First(["Procedure": "Prostate Cancer Treatment"] ProstateCancerTreatment
      where QICoreCommon."ToInterval"(ProstateCancerTreatment.performed) ends during "Measurement Period"
      sort by start of QICoreCommon."ToInterval"(performed)
  )

define "Has Salvage Therapy Performed After Prostate Cancer Diagnosis":
  exists ( ["Procedure": "Salvage Therapy"] SalvageTherapy
      with "Prostate Cancer Diagnosis" ActiveProstateCancer
        such that QICoreCommon."ToInterval" ( SalvageTherapy.performed ) starts after start of QICoreCommon."ToPrevalenceInterval" ( ActiveProstateCancer )
  )

define "Initial Population":
  exists "Prostate Cancer Diagnosis"

define "Most Recent Gleason Score is Low":
  ( Last(["Observation": "Gleason score in Specimen Qualitative"] GleasonScore
      with "First Prostate Cancer Treatment During Measurement Period" FirstProstateCancerTreatment
        such that QICoreCommon."ToInterval"(GleasonScore.effective) starts before start of QICoreCommon."ToInterval"(FirstProstateCancerTreatment.performed)
      sort by start of QICoreCommon."ToInterval"(effective)
  ) ) LastGleasonScore
    return LastGleasonScore.value as Integer <= 6

define "Most Recent Prostate Cancer Staging Tumor Size T1a to T2a":
  ( Last(["Observation": "Tumor staging (tumor staging)"] ProstateCancerStaging
      with "First Prostate Cancer Treatment During Measurement Period" FirstProstateCancerTreatment
        such that QICoreCommon."ToInterval"(ProstateCancerStaging.effective) starts before start of QICoreCommon."ToInterval"(FirstProstateCancerTreatment.performed)
      sort by start of QICoreCommon."ToInterval"(effective)
  ) ) LastProstateCancerStaging
    where ( LastProstateCancerStaging.value ~ "T1a: Prostate tumor incidental histologic finding in 5% or less of tissue resected (finding)"
        or LastProstateCancerStaging.value ~ "T1b: Prostate tumor incidental histologic finding in > 5% of tissue resected (finding)"
        or LastProstateCancerStaging.value ~ "Neoplasm of prostate primary tumor staging category T1c: Tumor identified by needle biopsy (finding)"
        or LastProstateCancerStaging.value ~ "Neoplasm of prostate primary tumor staging category T2a: Involves one-half of one lobe or less (finding)"
    )

define "Numerator":
  not exists "Bone Scan Study Performed"

define "Denominator":
  "Initial Population"
    and "First Prostate Cancer Treatment During Measurement Period" is not null
    and "Most Recent Prostate Cancer Staging Tumor Size T1a to T2a" is not null
    and "Most Recent PSA Test Result is Low"
    and "Most Recent Gleason Score is Low"

define "Has Bone Scan Study Performed with Documented Reason":
  exists "Bone Scan Study Performed" BoneScanAfterDiagnosis
    where BoneScanAfterDiagnosis.value ~ "Procedure reason record (record artifact)"

define "Bone Scan Study Performed":
  [Observation: "Bone Scan"] BoneScan
    with "Prostate Cancer Diagnosis" ActiveProstateCancer
      such that QICoreCommon."ToInterval" ( BoneScan.effective ) starts after start of QICoreCommon."ToPrevalenceInterval" ( ActiveProstateCancer )

define "Prostate Cancer Diagnosis":
  [Condition: "Prostate Cancer"] ProstateCancer
    where QICoreCommon."ToPrevalenceInterval" ( ProstateCancer ) overlaps day of "Measurement Period"
      and ProstateCancer.clinicalStatus ~ FHIRCommon."active"

define "Most Recent PSA Test Result is Low":
  ( Last([Observation: "Prostate Specific Antigen Test"] PSATest
      with "Most Recent Prostate Cancer Staging Tumor Size T1a to T2a" MostRecentProstateCancerStaging
        such that QICoreCommon."ToInterval"(PSATest.effective) starts before QICoreCommon."ToInterval"(MostRecentProstateCancerStaging.effective)
      sort by start of QICoreCommon."ToInterval"(effective)
  ) ) LastPSATest
    return LastPSATest.value as Quantity < 10 'ng/mL'

define "Has Diagnosis of Pain Related to Prostate Cancer":
  exists ( ["Condition": "Pain Related to Prostate Cancer"] ProstateCancerPain
      with "Prostate Cancer Diagnosis" ActiveProstateCancer
        such that QICoreCommon."ToPrevalenceInterval" ( ProstateCancerPain ) starts after start of QICoreCommon."ToPrevalenceInterval" ( ActiveProstateCancer )
          and ProstateCancerPain.clinicalStatus ~ FHIRCommon."active"
  )