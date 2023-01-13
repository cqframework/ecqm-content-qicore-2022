/*
@update: 2022-08-24: based on AU 2022 content and updated to QI-Core 
rename this file to v'0.0.14', as v'0.0.13' is FHIR version in 2022 R4 folder
added include QICoreCommon version '1.1.000' called QICoreCommon
removed valueset "Device Application": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.48 
removed valueset "Hemorrhagic Stroke": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.212'
removed valueset "Ischemic Stroke": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.247' 
added value set Application of Graduated Compression Stockings (GCS) 
added value set Application of Intermittent Pneumatic Compression Devices 
added value set Application of Venous Foot Pumps (VFP)
added value set Comfort Measures
Updated Low risk Indicate for VTE and 2 assocatie definitions by using Earliest()
Updated requestStatusReason by using qicore-doNOTperformReason for ServiceRequest and removed Function "GetStatusReason"
Updated all extensions by using sliceName in QI-Core profile
Updated all profile nagation profile wtih new QICore not done name - like MedicationAdministration, ServiceNotRequested, ProcedureNotDone
included category evaludation to Observation to prepare for QICORE v5.
*/
library IntensiveCareUnitVenousThromboembolismProphylaxisQICore4 version '0.0.014'

using QICore version '4.1.1'

include QICoreCommon version '1.2.000' called QICoreCommon
include MATGlobalCommonFunctionsQICore4 version '7.0.000' called Global
include VTEQICore4 version '7.0.000' called VTE
include FHIRHelpers version '4.1.000' called FHIRHelpers
include SupplementalDataElementsQICore4 version '3.0.000' called SDE


codesystem "LOINC": 'http://loinc.org' 

valueset "Application of Graduated Compression Stockings (GCS)":'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.66'
valueset "Application of Intermittent Pneumatic Compression Devices (IPC)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.65'
valueset "Application of Venous Foot Pumps (VFP)": 'http://cts.nlm.nih.gov/fhir/ValueSeint/2.16.840.1.113762.1.4.1110.64'
valueset "Atrial Fibrillation/Flutter": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.202' 
valueset "Comfort Measures": 'http://cts.nlm.nih.gov/fhir/ValueSet/1.3.6.1.4.1.33895.1.3.0.45'
valueset "Direct Thrombin Inhibitor": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.205' 
valueset "Emergency Department Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.292' 
valueset "General or Neuraxial Anesthesia": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.1743' 
valueset "General Surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.255' 
valueset "Glycoprotein IIb/IIIa Inhibitors": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.41' 
valueset "Graduated compression stockings (GCS)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.256' 
valueset "Gynecological Surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.257' 
valueset "Hip Fracture Surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.258' 
valueset "Hip Replacement Surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.259' 
valueset "Injectable Factor Xa Inhibitor for VTE Prophylaxis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.211' 
valueset "INR": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.213' 
valueset "Intensive Care Unit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1029.206' 
valueset "Intermittent pneumatic compression devices (IPC)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.214' 
valueset "Intracranial Neurosurgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.260' 
valueset "Intravenous route": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.222' 
valueset "Knee Replacement Surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.261' 
valueset "Low Dose Unfractionated Heparin for VTE Prophylaxis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.39' 
valueset "Low Molecular Weight Heparin for VTE Prophylaxis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.219' 
valueset "Low Risk": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.400' 
valueset "Medical Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.473' 
valueset "Mental Health Diagnoses": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.105.12.1004' 
valueset "Obstetrics": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.263' 
valueset "Obstetrics VTE": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.264' 
valueset "Oral Factor Xa Inhibitor for VTE Prophylaxis or VTE Treatment": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.134' 
valueset "Patient Refusal": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.93' 
valueset "Rivaroxaban for VTE Prophylaxis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.50' 
valueset "Subcutaneous route": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.223' 
valueset "Unfractionated Heparin": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.218' 
valueset "Urological Surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.272' 
valueset "Venous foot pumps (VFP)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.230' 
valueset "Venous Thromboembolism": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.279' 
valueset "Warfarin": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.232' 

code "Risk for venous thromboembolism": '72136-5' from "LOINC" display 'Risk for venous thromboembolism'

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
"Encounter with Age Range and without VTE Diagnosis or Obstetrical Conditions"


define "Encounter with Age Range and without VTE Diagnosis or Obstetrical Conditions":
  ( Global."Inpatient Encounter" InpatientEncounter
              where CalculateAgeInYearsAt(Patient.birthDate, date from start of "Measurement Period") >= 18
              )
              intersect "Admission without VTE or Obstetrical Conditions"

//QA: 8/30 Collob call - Bryn needs to fix ModelInfo and QICoreCOmmon to allow EncounterDiagnoses return more than 1 dx so continue using exists() - CQLIT-330
define "Admission without VTE or Obstetrical Conditions":
  Global."Inpatient Encounter" InpatientEncounter
  where not exists (Global.EncounterDiagnosis(InpatientEncounter).code in "Obstetrics" 
      or Global.EncounterDiagnosis(InpatientEncounter).code in "Venous Thromboembolism"
      or Global.EncounterDiagnosis(InpatientEncounter).code in "Obstetrics VTE")
          		  /*  where not (exists (Global.EncounterDiagnosis(InpatientEncounter) EncDx
                  where (EncDx.code in "Obstetrics" 
                      or EncDx.code in "Venous Thromboembolism"
          							or EncDx.code in "Obstetrics VTE"
          			         )
                     )
                  )
*/

define "Denominator":
  "Encounter with ICU Location"

define "Encounter with ICU Location":
  VTE."Encounter with Age Range and without VTE Diagnosis or Obstetrical Conditions" QualifyingEncounter
          	where exists (QualifyingEncounter.location Location
        				where Global.GetLocation(Location.location).type in "Intensive Care Unit"
          			and Location.period during QualifyingEncounter.period
          	)

define "Denominator Exclusions":
  "Encounter with ICU Location And Encounter Less Than 2 Days"
          union "Encounter with First ICU Stay with Principal Procedure of SCIP VTE Selected Surgery"
        	union "Encounter with Intervention Comfort Measures From Day Of Start of Hospitalization To Day After First ICU Stay"
          union "Encounter with Intervention Comfort Measures on Day of or Day After Procedure"

define "Encounter with ICU Location And Encounter Less Than 2 Days":
  "Encounter with ICU Location"QualifyingEncounterICU
          	where Global."LengthInDays"(QualifyingEncounterICU.period)< 2


define "SCIP VTE Selected Surgery":
  (	["Procedure": "General Surgery"]
          		union ["Procedure": "Gynecological Surgery"]
          		union ["Procedure": "Hip Fracture Surgery"]
          		union ["Procedure": "Hip Replacement Surgery"]
          		union ["Procedure": "Intracranial Neurosurgery"]
          		union ["Procedure": "Knee Replacement Surgery"]
          		union ["Procedure": "Urological Surgery"] ) Procedure
          		where Procedure.status = 'completed'

//QA: 9/6 - Bryn will add getID() into QICoreCommon
define "Encounter with First ICU Stay with Principal Procedure of SCIP VTE Selected Surgery":
  from
      "Encounter with ICU Location" QualifyingEncounterICU,
      "SCIP VTE Selected Surgery" SelectedProcedure
      let EncounterProcedure: singleton from (QualifyingEncounterICU.procedure P where P.rank = 1)
      where EncounterProcedure.procedure.reference.getId() = SelectedProcedure.id
        and date from ( 
          end of QICoreCommon."ToInterval" ( SelectedProcedure.performed )
        ) during VTE."CalendarDayOfOrDayAfter" ( VTE."StartOfFirstICU" ( QualifyingEncounterICU ) )
      return QualifyingEncounterICU


define "Encounter with Intervention Comfort Measures From Day Of Start of Hospitalization To Day After First ICU Stay":
  "Encounter with ICU Location" QualifyingEncounterICU
              with "Intervention Comfort Measures" ComfortMeasure
            such that date from(Coalesce(start of QICoreCommon."ToInterval" (ComfortMeasure.performed), ComfortMeasure.authoredOn)) during VTE."FromDayOfStartOfHospitalizationToDayAfterFirstICU"(QualifyingEncounterICU)


define "Intervention Comfort Measures":
  ( ["ServiceRequest": "Comfort Measures"] P
      where P.intent = 'order'
      and P.status in { 'active', 'on-hold', 'completed'}
  )
    union ( ["Procedure": "Comfort Measures"] InterventionPerformed
        where InterventionPerformed.status in { 'completed', 'in-progress' }
    )


define "Encounter with Intervention Comfort Measures on Day of or Day After Procedure":
  from
            "Encounter with ICU Location" QualifyingEncounterICU,
            ["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
            "Intervention Comfort Measures" ComfortMeasure
            where  AnesthesiaProcedure.status = 'completed'
              	and QICoreCommon."ToInterval" (AnesthesiaProcedure.performed ) ends 1 day after day of VTE."StartOfFirstICU"(QualifyingEncounterICU)
                and date from (Coalesce(start of QICoreCommon."ToInterval" (ComfortMeasure.performed), ComfortMeasure.authoredOn)) during VTE.CalendarDayOfOrDayAfter( 
                  end of QICoreCommon.ToInterval(AnesthesiaProcedure.performed))
            	return QualifyingEncounterICU


define "Numerator":
  "Encounter with VTE Prophylaxis Received on Day of or Day After First ICU Stay or Procedure"
        	union ( "Encounter with Medication Oral Factor Xa Inhibitor Administered on Day of or Day After First ICU Stay or Procedure"
        			intersect ( "Encounter with Prior or Present Diagnosis of Atrial Fibrillation or Prior Diagnosis of VTE"
        					union "Encounter with Prior or Present Procedure of Hip or Knee Replacement Surgery"
        			)
        	)
        	union "Encounter with Low Risk for VTE or Anticoagulant Administered"
        	union "Encounter with No VTE Prophylaxis Due to Medical Reason"
        	union "Encounter with No VTE Prophylaxis Due to Patient Refusal"

define "Pharmacological or Mechanical VTE Prophylaxis Received":
  ( ["MedicationAdministration":"Low Dose Unfractionated Heparin for VTE Prophylaxis"] VTEMedication
              where VTEMedication.status ='completed'
                   and VTEMedication.dosage.route in "Subcutaneous route"
          )
           union (["MedicationAdministration": "Low Molecular Weight Heparin for VTE Prophylaxis"] LMWH where LMWH.status = 'completed')
            union (["MedicationAdministration":  "Injectable Factor Xa Inhibitor for VTE Prophylaxis"] FactorXa where FactorXa.status = 'completed')
             union (["MedicationAdministration":  "Warfarin"] Warfarin where Warfarin.status = 'completed')
             union (["MedicationAdministration": "Rivaroxaban for VTE Prophylaxis"] Rivaroxaban where Rivaroxaban.status = 'completed')
              union (
                  (["Procedure": "Application of Intermittent Pneumatic Compression Devices (IPC)"] 
                  union ["Procedure": "Application of Venous Foot Pumps (VFP)"] 
                  union ["Procedure": "Application of Graduated Compression Stockings (GCS)"] ) DeviceApplied
                  where DeviceApplied.status = 'completed'
                            ) 

define "Encounter with VTE Prophylaxis Received on Day of or Day After First ICU Stay or Procedure":
  ( "Encounter with ICU Location" QualifyingEncounterICU
      with	"Pharmacological or Mechanical VTE Prophylaxis Received" VTEProphylaxis
        //such that date from(start of QICoreCommon."ToInterval" (VTEProphylaxis.effective)) during VTE.CalendarDayOfOrDayAfter(VTE.StartOfFirstICU(QualifyingEncounterICU))
        such that date from(start of Coalesce(QICoreCommon."ToInterval" (VTEProphylaxis.effective), QICoreCommon."ToInterval" (VTEProphylaxis.performed))) during VTE."CalendarDayOfOrDayAfter"(VTE."StartOfFirstICU"(QualifyingEncounterICU))
        	)
        	union ( from
        				"Encounter with ICU Location" QualifyingEncounterICU,
        				["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
        				"Pharmacological or Mechanical VTE Prophylaxis Received" VTEProphylaxis
        				where QICoreCommon."ToInterval" (AnesthesiaProcedure.performed) ends 1 day after day of VTE."StartOfFirstICU"(QualifyingEncounterICU)
        					//and date from(start of QICoreCommon."ToInterval" (VTEProphylaxis.effective)) during VTE."CalendarDayOfOrDayAfter"(
        					and date from(start of Coalesce(QICoreCommon."ToInterval" (VTEProphylaxis.effective), QICoreCommon."ToInterval" (VTEProphylaxis.performed))) during VTE."CalendarDayOfOrDayAfter"(
          				end of QICoreCommon."ToInterval" (AnesthesiaProcedure.performed))
                    return QualifyingEncounterICU
                )
               

define "Encounter with Medication Oral Factor Xa Inhibitor Administered on Day of or Day After First ICU Stay or Procedure":
  (  "Encounter with ICU Location" QualifyingEncounterICU
     with ["MedicationAdministration":  "Oral Factor Xa Inhibitor for VTE Prophylaxis or VTE Treatment"] FactorXaMedication
     such that FactorXaMedication.status = 'completed'
                  and date from(start of QICoreCommon."ToInterval" (FactorXaMedication.effective)) during VTE.CalendarDayOfOrDayAfter(VTE.StartOfFirstICU(QualifyingEncounterICU))
           )
          union ( from
            			 "Encounter with ICU Location" QualifyingEncounterICU,
            			["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
            			["MedicationAdministration":  "Oral Factor Xa Inhibitor for VTE Prophylaxis or VTE Treatment"] FactorXaMedication
            			where FactorXaMedication.status = 'completed'
                    and AnesthesiaProcedure.status = 'completed'
            				and QICoreCommon."ToInterval" (AnesthesiaProcedure.performed) ends 1 day after day of VTE."StartOfFirstICU"(QualifyingEncounterICU)
            					and date from(start of QICoreCommon."ToInterval" (FactorXaMedication.effective)) during VTE."CalendarDayOfOrDayAfter"(
              				end of QICoreCommon."ToInterval" (AnesthesiaProcedure.performed))
            			return QualifyingEncounterICU
                )


define "Encounter with Prior or Present Diagnosis of Atrial Fibrillation or Prior Diagnosis of VTE":
  ( "Encounter with ICU Location" QualifyingEncounterICU 
      with ["Condition": "Atrial Fibrillation/Flutter"] AtrialFibrillation
        such that ( AtrialFibrillation.clinicalStatus ~ QICoreCommon."active"
        or AtrialFibrillation.clinicalStatus ~ QICoreCommon."recurrence"
        or AtrialFibrillation.clinicalStatus ~ QICoreCommon."relapse"
        )
          and  AtrialFibrillation.verificationStatus  ~ QICoreCommon."confirmed"
          and QICoreCommon."ToInterval"  ( AtrialFibrillation.onset ) starts on or before 
          end of QualifyingEncounterICU.period
  )
    union ( "Encounter with ICU Location" QualifyingEncounterICU
        where Global.EncounterDiagnosis ( QualifyingEncounterICU ).code in "Atrial Fibrillation/Flutter"
    )
    union ( "Encounter with ICU Location" QualifyingEncounterICU
        with ["Condition": "Venous Thromboembolism"] VTEDiagnosis
          such that  (VTEDiagnosis.clinicalStatus  ~ QICoreCommon."inactive"
              or VTEDiagnosis.clinicalStatus  ~ QICoreCommon."remission"
              or  VTEDiagnosis.clinicalStatus ~ QICoreCommon."resolved"
            )
            and VTEDiagnosis.verificationStatus ~ QICoreCommon."confirmed"
            and QICoreCommon."ToInterval"  ( VTEDiagnosis.onset ) before start of QualifyingEncounterICU.period
           )


define "Encounter with Prior or Present Procedure of Hip or Knee Replacement Surgery":
  "Encounter with ICU Location" QualifyingEncounterICU
        	with ( ["Procedure": "Hip Replacement Surgery"]
          			union ["Procedure": "Knee Replacement Surgery"] ) HipKneeProcedure
        	such that HipKneeProcedure.status = 'completed'
        			and QICoreCommon."ToInterval" (HipKneeProcedure.performed)  starts on or before end of QualifyingEncounterICU.period


define "Encounter with Low Risk for VTE or Anticoagulant Administered":
  "Low Risk for VTE or Anticoagulant Administered From Day of Start of Hospitalization To Day After First ICU Stay"
          union "Low Risk for VTE or Anticoagulant Administered on Day of or Day After Procedure"


//QA: 8/30 FHIR Collab call - due to bryn, oberservation.value for INR as Quantiy (not ratio) wihtout unit after 3.0. The default unit for as quantity will be '1' if there is no unit after the number
define "Low Risk Indicator For VTE":
  ( ["Observation": "Risk for venous thromboembolism"] VTERiskAssessment
      where  exists (VTERiskAssessment.category C
                where C ~ QICoreCommon."exam" )
        and VTERiskAssessment.value as Concept in "Low Risk"
        and VTERiskAssessment.status in { 'final', 'amended', 'corrected' }
      return {
        id: VTERiskAssessment.id,
        LowRiskDatetime: QICoreCommon.Earliest(VTERiskAssessment.effective)
      }
  )
    union ( ["Observation": "INR"] INRLabTest
        where  exists (INRLabTest.category C
                where C ~ QICoreCommon."laboratory" )
        and INRLabTest.value as Quantity > 3.0 
          and INRLabTest.status in { 'final', 'amended', 'corrected' }
        return  { 
          id: INRLabTest.id, 
          LowRiskDatetime: INRLabTest.issued }
    )
    union ( ( ( ["MedicationAdministration": "Unfractionated Heparin"] UnfractionatedHeparin
          where UnfractionatedHeparin.dosage.route in "Intravenous route"
      )
        union ["MedicationAdministration": "Direct Thrombin Inhibitor"]
        union ["MedicationAdministration": "Glycoprotein IIb/IIIa Inhibitors"] ) AnticoagulantMedication
        where AnticoagulantMedication.status = 'completed'
        return { 
          id: AnticoagulantMedication.id, 
          LowRiskDatetime: start of QICoreCommon."ToInterval" (AnticoagulantMedication.effective) }
    )


define "Low Risk for VTE or Anticoagulant Administered From Day of Start of Hospitalization To Day After First ICU Stay":
  "Encounter with ICU Location" QualifyingEncounterICU
          with "Low Risk Indicator For VTE" LowRiskForVTE
          such that LowRiskForVTE.LowRiskDatetime during day of VTE."FromDayOfStartOfHospitalizationToDayAfterFirstICU"(QualifyingEncounterICU)

define "Low Risk for VTE or Anticoagulant Administered on Day of or Day After Procedure":
  from
          	"Encounter with ICU Location" QualifyingEncounterICU,
          	["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
            "Low Risk Indicator For VTE" LowRiskForVTE
          where AnesthesiaProcedure.status = 'completed'
            and QICoreCommon."ToInterval" (AnesthesiaProcedure.performed) ends 1 day after day of VTE."StartOfFirstICU"(QualifyingEncounterICU)
          	and LowRiskForVTE.LowRiskDatetime during day of VTE."CalendarDayOfOrDayAfter"(end of QICoreCommon."ToInterval" (AnesthesiaProcedure.performed))
          return QualifyingEncounterICU


define "Encounter with No VTE Prophylaxis Due to Medical Reason":
  ( "No VTE Prophylaxis Medication Due to Medical Reason From Day of Start of Hospitalization To Day After First ICU Stay"
            intersect "No Mechanical VTE Prophylaxis Due to Medical Reason From Day of Start of Hospitalization To Day After First ICU Stay"
          )
          union ( "No VTE Prophylaxis Medication Due to Medical Reason on Day of or Day After Procedure"
              intersect "No Mechanical VTE Prophylaxis Due to Medical Reason on Day of or Day After Procedure"
          )


define "No VTE Prophylaxis Medication Due to Medical Reason From Day Of Start of Hospitalization To Day After First ICU Stay":
  "Encounter with ICU Location" QualifyingEncounterICU
      with "No VTE Prophlaxis Medication Administered or Order" NoVTEMedication
        such that NoVTEMedication.MedicationStatusReason in "Medical Reason"
          and date from ( NoVTEMedication.authoredOn ) during VTE."FromDayOfStartOfHospitalizationToDayAfterFirstICU" ( QualifyingEncounterICU )         


//QA: Terminology retrieving issue occurs in MedicationAdminstration - CQLIT-331
//QA: 9/6 Bryn will look into ModelInfo to fix terminology issue
define "No VTE Prophylaxis Medication Administered or Ordered":
  ( ( [MedicationAdministrationNotDone: "Low Dose Unfractionated Heparin for VTE Prophylaxis"]
       union [MedicationAdministrationNotDone: "Low Molecular Weight Heparin for VTE Prophylaxis"]
        union [MedicationAdministrationNotDone: "Injectable Factor Xa Inhibitor for VTE Prophylaxis"]
        union [MedicationAdministrationNotDone: "Warfarin"]
        union [MedicationAdministrationNotDone: "Rivaroxaban for VTE Prophylaxis"] ) MedicationAdm
        where MedicationAdm.status = 'not-done' //still needed for tooling usage
        return {
          id: MedicationAdm.id,
          MedicationStatusReason: MedicationAdm.statusReason,
          authoredOn: MedicationAdm.recorded
        }
    )
      union ( ( ["MedicationRequest": "Low Dose Unfractionated Heparin for VTE Prophylaxis"]
          union ["MedicationRequest": "Low Molecular Weight Heparin for VTE Prophylaxis"]
          union ["MedicationRequest": "Injectable Factor Xa Inhibitor for VTE Prophylaxis"]
          union ["MedicationRequest": "Warfarin"]
          union ["MedicationRequest": "Rivaroxaban for VTE Prophylaxis"]) MedicationOrder
          where MedicationOrder.doNotPerform is true
            and MedicationOrder.status in { 'completed', 'cancelled' }
          return {
            id: MedicationOrder.id,
            MedicationStatusReason: MedicationOrder.reasonCode,
            authoredOn: MedicationOrder.authoredOn
          }
      )



define "No Mechanical VTE Prophylaxis Due to Medical Reason From Day of Start of Hospitalization To Day After First ICU Stay":
  "Encounter with ICU Location" QualifyingEncounterICU
            with "No Mechanical VTE Prophylaxis Performed or Ordered" NoVTEDevice
            such that NoVTEDevice.requestStatusReason in "Medical Reason"
                and date from(NoVTEDevice.authoredOn) during VTE."FromDayOfStartOfHospitalizationToDayAfterFirstICU"(QualifyingEncounterICU)


//QA: Terminology retrieving issue occurs in ProcedureNotDone and Precedure.recorded is not regnozied - CQLIT-331
//QA: 9/6 Bryn will look into ModelInfo to fix terminology issue
define "No Mechanical VTE Prophylaxis Performed or Ordered":
  ( ( [ServiceNotRequested: "Venous foot pumps (VFP)"]
      union [ServiceNotRequested: "Intermittent pneumatic compression devices (IPC)"]
      union [ServiceNotRequested: "Graduated compression stockings (GCS)"] ) DeviceNotOrder
      where DeviceNotOrder.status = 'completed'
        and DeviceNotOrder.doNotPerform is true
      return {
        id: DeviceNotOrder.id,
        requestStatusReason: DeviceNotOrder.reasonRefused,
        authoredOn: DeviceNotOrder.authoredOn
      }
  )
   union ( ([ProcedureNotDone: "Application of Intermittent Pneumatic Compression Devices (IPC)"] 
                  union [ProcedureNotDone: "Application of Venous Foot Pumps (VFP)"] 
                  union [ProcedureNotDone: "Application of Graduated Compression Stockings (GCS)"]) DeviceNotApplied
        let DeviceNotDoneTiming: DeviceNotApplied.recorded
        where DeviceNotApplied.status = 'not-done'
        return {
          id: DeviceNotApplied.id,
          requestStatusReason: DeviceNotApplied.statusReason,
          authoredOn: DeviceNotDoneTiming
        }
    )  


define "No VTE Prophylaxis Medication Due to Medical Reason on Day of or Day After Procedure":
  from
      "Encounter with ICU Location" QualifyingEncounterICU,
      ["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
      "No VTE prophylaxis Medication Administered or Ordered" NoVTEMedication
      where NoVTEMedication.MedicationStatusReason in "Medical Reason"
        and AnesthesiaProcedure.status = 'completed'
        and QICoreCommon."ToInterval"  ( AnesthesiaProcedure.performed ) ends 1 day after day of VTE."StartOfFirstICU" ( QualifyingEncounterICU )
        and date from ( NoVTEMedication.authoredOn ) during VTE."CalendarDayOfOrDayAfter" ( 
        end of QICoreCommon."ToInterval"  ( AnesthesiaProcedure.performed as Period ) )
      return QualifyingEncounterICU                        


define "No Mechanical VTE Prophylaxis Due to Medical Reason on Day of or Day After Procedure":
  from
        		"Encounter with ICU Location" QualifyingEncounterICU,
        		["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
            "No Mechanical VTE Proplylaxis Performed or Ordered" NoVTEDevice
        		where NoVTEDevice.requestStatusReason in "Medical Reason"
                and AnesthesiaProcedure.status = 'completed'
                and QICoreCommon."ToInterval" (AnesthesiaProcedure.performed ) ends 1 day after day of VTE."StartOfFirstICU"(QualifyingEncounterICU)
                and date from (NoVTEDevice.authoredOn) during VTE."CalendarDayOfOrDayAfter"(
        			         end of QICoreCommon."ToInterval" (AnesthesiaProcedure.performed))
        		return QualifyingEncounterICU

        

define "Encounter with No VTE Prophylaxis Due to Patient Refusal":
  "No VTE Prophlaxis Due to Patient Refusal From Day of Start of Hospitalization To Day After First ICU Stay"
        	union "No VTE Prophylaxis Due to Patient Refusal on Day of or Day After Procedure"


define "No VTE Prophylaxis Due to Patient Refusal From Day of Start of Hospitalization To Day After First ICU Stay":
  "Encounter with ICU Location" QualifyingEncounterICU
      with "No Mechanic or Pharmacological VTE Prophlaxis Due to Patient Refusal" PatientRefusal
        such that date from ( PatientRefusal.authoredOn ) during VTE.FromDayOfStartOfHospitalizationToDayAfterFirstICU ( QualifyingEncounterICU )

define "No VTE Prophylaxis Due to Patient Refusal on Day of or Day After Procedure":
  from
      "Encounter with ICU Location" QualifyingEncounterICU,
      ["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
      "No Mechanical or Pharmacological VTE Prophlaxis Due to Patient Refusal" PatientRefusal
      where QICoreCommon."ToInterval"  ( AnesthesiaProcedure.performed ) ends 1 day after day of VTE."StartOfFirstICU" ( QualifyingEncounterICU )
        and date from ( PatientRefusal.authoredOn ) during VTE."CalendarDayOfOrDayAfter" ( 
        end of QICoreCommon."ToInterval"  ( AnesthesiaProcedure.performed ) )
      return QualifyingEncounterICU

define "No Mechanical or Pharmacological VTE Prophylaxis Due to Patient Refusal":
  ( "No VTE Prophylaxis Medication Administered or Ordered" NoVTEMedication
        where NoVTEMedication.MedicationStatusReason in "Patient Refusal"
    )
      union ( "No Mechanical VTE Prophylaxis Performed or Ordered" NoVTEDevice
          where NoVTEDevice.requestStatusReason in "Patient Refusal"
      )


define "Denominator Exceptions":
  "Encounter with First ICU Location Stay Less Than 1 day"

define "Encounter with First ICU Location Stay Less Than 1 day":
  "Encounter with ICU Location" QualifyingEncounterICU
        	 where Global."LengthInDays"(VTE."FirstICULocationPeriod"(QualifyingEncounterICU)) < 1

