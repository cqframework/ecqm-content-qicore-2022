library SafeUseofOpioidsConcurrentPrescribingFHIR version '0.0.004'

using QICore version '4.1.1'

include SupplementalDataElements version '3.1.000' called SDE
include FHIRCommon version '4.1.000' called FHIRCommon
include FHIRHelpers version '4.1.000' called FHIRHelpers
include QICoreCommon version '1.2.000' called QICoreCommon
include CQMCommon version '1.0.000' called CQMCommon

codesystem "LOINC": 'http://loinc.org'

valueset "All Primary and Secondary Cancer": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1111.161'
valueset "Discharge To Acute Care Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.87'
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
valueset "Hospice Care Referral or Admission": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1116.365'
valueset "Palliative or Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1.1579'
valueset "Patient Expired": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.309'
valueset "Schedule II & III Opioid Medications": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1111.165'
valueset "Schedule IV Benzodiazepines": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1125.1'

code "Birth date": '21112-8' from "LOINC" display 'Birth date'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2023-01-01T00:00:00.0, @2024-01-01T00:00:00.0)

context Patient

define "Denominator":
  "Initial Population"

define "Inpatient Encounter with Age Greater than or Equal to 18":
  CQMCommon."Inpatient Encounter" InpatientHospitalEncounter
    where AgeInYearsAt(date from start of InpatientHospitalEncounter.period) >= 18

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

define "Intervention Palliative or Hospice Care":
  [ServiceRequest: code in "Palliative or Hospice Care"]
    union [Procedure: "Palliative or Hospice Care"]

define "Initial Population":
  "Inpatient Encounters with an Opioid or Benzodiazepine at Discharge"

define "Denominator Exclusion":
  /*Excludes encounters of patients with cancer or who are receiving palliative or hospice care at the time of the encounter*/
  
  "Inpatient Encounters with an Opioid or Benzodiazepine at Discharge" InpatientEncounter
    where exists ( [Condition: "All Primary and Secondary Cancer"] Cancer
        where QICoreCommon."ToPrevalenceInterval" ( Cancer ) overlaps InpatientEncounter.period
    )
      or exists ( "Intervention Palliative or Hospice Care" PalliativeOrHospiceCare
          where Coalesce(start of QICoreCommon."ToInterval"(PalliativeOrHospiceCare.performed), PalliativeOrHospiceCare.authoredOn) during CQMCommon."HospitalizationWithObservation" ( InpatientEncounter )
      )
      or exists ( "Inpatient Encounters with an Opioid or Benzodiazepine at Discharge" InpatientEncounter
          where InpatientEncounter.hospitalization.dischargeDisposition in "Discharge To Acute Care Facility"
            or InpatientEncounter.hospitalization.dischargeDisposition in "Hospice Care Referral or Admission"
            or InpatientEncounter.hospitalization.dischargeDisposition in "Patient Expired"
      )

define "Numerator":
  /*Encounters of patients prescribed two or more opioids or an opioid and benzodiazepine at discharge.
                */
  
  ( "Inpatient Encounter with Age Greater than or Equal to 18" InpatientEncounter
      where ( Count("Opioid at Discharge" Opioids
            return distinct Opioids.medication
        ) >= 2
      )
  )
    union ( "Inpatient Encounter with Age Greater than or Equal to 18" InpatientEncounter
        with "Opioid at Discharge" OpioidsDischarge
          such that OpioidsDischarge.authoredOn during InpatientEncounter.period
        with "Benzodiazepine at Discharge" BenzodiazepinesDischarge
          such that BenzodiazepinesDischarge.authoredOn during InpatientEncounter.period
    )

define "Benzodiazepine at Discharge":
  ( [MedicationRequest: "Schedule IV Benzodiazepines"] BenzoMedications
    where exists BenzoMedications.category BenzoCategory
      where BenzoCategory ~ QICoreCommon."Discharge" ) BenzodiazepineDischargeMedication
    where BenzodiazepineDischargeMedication.status = 'active'
      and BenzodiazepineDischargeMedication.intent = 'plan'

define "Opioid at Discharge":
  ( [MedicationRequest: "Schedule II & III Opioid Medications"] OpioidMedications
    where exists OpioidMedications.category OpioidCategory
      where OpioidCategory ~ QICoreCommon."Discharge" ) OpioidDischargeMedication
    where OpioidDischargeMedication.status = 'active'
      and OpioidDischargeMedication.intent = 'plan'

define "Inpatient Encounters with an Opioid or Benzodiazepine at Discharge":
  "Inpatient Encounter with Age Greater than or Equal to 18" InpatientEncounter
    with ( "Opioid at Discharge"
      union "Benzodiazepine at Discharge" ) OpioidOrBenzodiazepineAtDischarge
      such that OpioidOrBenzodiazepineAtDischarge.authoredOn during InpatientEncounter.period