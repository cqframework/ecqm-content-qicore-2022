library DocumentationofCurrentMedicationsFHIR version '0.0.010'

using QICore version '4.1.1'

include SupplementalDataElements version '3.1.000' called SDE
include FHIRCommon version '4.1.000' called FHIRCommon
include FHIRHelpers version '4.1.000' called FHIRHelpers
include QICoreCommon version '1.2.000' called QICoreCommon

codesystem "SNOMEDCT": 'http://snomed.info/sct'

valueset "Encounter to Document Medications": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1.1834'
valueset "Medical Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1007'

code "Documentation of current medications (procedure)": '428191000124101' from "SNOMEDCT" display 'Documentation of current medications (procedure)'

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

define "Qualifying Encounter during Measurement Period":
  ["Encounter": "Encounter to Document Medications"] ValidEncounter
    where ValidEncounter.status = 'finished'
      and ValidEncounter.period during "Measurement Period"

define "Initial Population":
  "Qualifying Encounter during Measurement Period" QualifyingEncounter
    where AgeInYearsAt(start of "Measurement Period") >= 18

define "Numerator":
  "Qualifying Encounter during Measurement Period" QualifyingEncounter
    with [Task: "Documentation of current medications (procedure)"] MedicationsDocumented
      such that QICoreCommon."ToInterval" ( MedicationsDocumented.authoredOn ) during QualifyingEncounter.period
        and MedicationsDocumented.status in { 'received', 'accepted' }

define "Denominator Exceptions":
  "Qualifying Encounter during Measurement Period" QualifyingEncounter
    with [Task: "Documentation of current medications (procedure)"] MedicationsNotDocumented
      such that QICoreCommon."ToInterval" ( MedicationsNotDocumented.authoredOn ) during QualifyingEncounter.period
        and MedicationsNotDocumented.status = 'rejected'
        and MedicationsNotDocumented.reasonCode in "Medical Reason"