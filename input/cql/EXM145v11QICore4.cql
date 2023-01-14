library EXM145v11QICore4 version '11.1.000'

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include SupplementalDataElements version '3.0.000' called SDE
include QICoreCommon version '1.2.000' called Common
include AHAOverallQICore4 version '1.0.000' called AHA

codesystem "SNOMEDCT": 'http://snomed.info/sct' 

valueset "Allergy to Beta Blocker Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1177' 
valueset "Arrhythmia": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.366' 
valueset "Asthma": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.362' 
valueset "Atrioventricular Block": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.367' 
valueset "Beta Blocker Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1174' 
valueset "Beta Blocker Therapy for LVSD": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1184' 
valueset "Beta Blocker Therapy Ingredient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1493' 
valueset "Bradycardia": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.412' 
valueset "Cardiac Pacer": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1178.53' 
valueset "Cardiac Pacer in Situ": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.368' 
valueset "Cardiac Surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.371' 
valueset "Coronary Artery Disease No MI": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.369' 
valueset "Hypotension": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.370' 
valueset "Intolerance to Beta Blocker Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1178' 
valueset "Medical Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1007' 
valueset "Myocardial Infarction": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.403'  
valueset "Patient Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1008' 
valueset "System Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1009'

code "Substance with beta adrenergic receptor antagonist mechanism of action (substance)": '373254001' from "SNOMEDCT" display 'Substance with beta adrenergic receptor antagonist mechanism of action (substance)'

parameter "Measurement Period" Interval<DateTime> 
  default Interval[@2022-01-01T00:00:00.0, @2023-01-01T00:00:00.0)
  
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
  //curent problem with AgeInYearsAt required a modified approach - refer to https://github.com/cqframework/ecqm-content-qicore-2022/issues/6
  CalculateAgeInYearsAt(Patient.birthDate, date from start of "Measurement Period") >= 18 
    and Count (AHA."Qualifying Encounter During Measurement Period")>= 2
    and exists ( "Qualifying CAD Encounter" )

define "Denominator 1":   
  "Initial Population"
    and exists "Qualifying CAD Encounter and History of Moderate or Severe LVSD"

define "Denominator 2":
  "Initial Population"
    and exists "Qualifying CAD Encounter and Prior MI"

define "Numerator 1":
  "Has Beta Blocker Therapy for LVSD Ordered"
    or "Is Currently Taking Beta Blocker Therapy for LVSD"

define "Numerator 2":
  "Has Beta Blocker Therapy Ordered"
    or "Is Currently Taking Beta Blocker Therapy"

define "Denominator Exceptions 1":
  "Has Arrhythmia with Qualifying CAD Encounter and History of Moderate or Severe LVSD"
    or "Has Asthma with Qualifying CAD Encounter and History of Moderate or Severe LVSD"
    or "Has Bradycardia with Qualifying CAD Encounter and History of Moderate or Severe LVSD"
    or "Has Hypotension with Qualifying CAD Encounter and History of Moderate or Severe LVSD"
    or "Has Consecutive Heart Rates Less than 50 with Qualifying CAD Encounter and History of Moderate or Severe LVSD"
    or "Has Allergy or Intolerance to Beta Blocker Therapy Ingredient with Qualifying CAD Encounter and History of Moderate or Severe LVSD"
    or "Has Diagnosis of Allergy or Intolerance to Beta Blocker Therapy with Qualifying CAD Encounter and History of Moderate or Severe LVSD"
    or "Has Medical Patient or System Reason for Not Ordering Beta Blocker for LVSD"
    or "Has Atrioventricular Block with Qualifying CAD Encounter and History of Moderate or Severe LVSD without Cardiac Pacer"

define "Denominator Exceptions 2":
  "Has Arrhythmia with Qualifying CAD Encounter and Prior MI"
    or "Has Asthma with Qualifying CAD Encounter and Prior MI"
    or "Has Bradycardia with Qualifying CAD Encounter and Prior MI"
    or "Has Hypotension with Qualifying CAD Encounter and Prior MI"
    or "Has Consecutive Heart Rates Less than 50 with Qualifying CAD Encounter and Prior MI"
    or "Has Allergy or Intolerance to Beta Blocker Therapy Ingredient with Qualifying CAD Encounter and Prior MI"
    or "Has Diagnosis of Allergy or Intolerance to Beta Blocker Therapy with Qualifying CAD Encounter and Prior MI"
    or "Has Medical Patient or System Reason for Not Ordering Beta Blocker Therapy"
    or "Has Atrioventricular Block with Qualifying CAD Encounter and Prior MI without Cardiac Pacer"

define "Coronary Artery Disease Encounter":
   AHA."Qualifying Encounter During Measurement Period"  QualifyingEncounter
    with ["Condition": "Coronary Artery Disease No MI"] CoronaryArteryDisease
      such that CoronaryArteryDisease.toPrevalenceInterval() overlaps QualifyingEncounter.period
        and CoronaryArteryDisease.isConfirmedActiveDiagnosis()

define "Has Allergy or Intolerance to Beta Blocker Therapy Ingredient with Qualifying CAD Encounter and History of Moderate or Severe LVSD":
  exists ( ( ["AllergyIntolerance": "Beta Blocker Therapy Ingredient"]
            union ["AllergyIntolerance": "Substance with beta adrenergic receptor antagonist mechanism of action (substance)"] ) BetaBlockerAllergyIntolerance
            where BetaBlockerAllergyIntolerance.isActiveAllergyBeforeOrDuringEncounter("Qualifying CAD Encounter and History of Moderate or Severe LVSD")
         )

define "Has Allergy or Intolerance to Beta Blocker Therapy Ingredient with Qualifying CAD Encounter and Prior MI":
  exists ( 
          ( ["AllergyIntolerance": "Beta Blocker Therapy Ingredient"]
              union ["AllergyIntolerance": "Substance with beta adrenergic receptor antagonist mechanism of action (substance)"] ) BetaBlockerAllergyIntolerance
            where BetaBlockerAllergyIntolerance.isActiveAllergyBeforeOrDuringEncounter( "Qualifying CAD Encounter and Prior MI" )
          )

define "Has Arrhythmia with Qualifying CAD Encounter and History of Moderate or Severe LVSD":
  exists ( 
            ["Condition": "Arrhythmia"] Arrhythmia
              where Arrhythmia.overlapsEncounter("Qualifying CAD Encounter and History of Moderate or Severe LVSD")
          )

define "Has Arrhythmia with Qualifying CAD Encounter and Prior MI":
  exists ( 
            ["Condition": "Arrhythmia"] Arrhythmia
              where Arrhythmia.overlapsEncounter("Qualifying CAD Encounter and Prior MI")
          )

define "Has Asthma with Qualifying CAD Encounter and History of Moderate or Severe LVSD":
  exists ( 
            ["Condition": "Asthma"] Asthma
              where Asthma.overlapsEncounter("Qualifying CAD Encounter and History of Moderate or Severe LVSD")
          )

define "Has Asthma with Qualifying CAD Encounter and Prior MI":
  exists ( 
            ["Condition": "Asthma"] Asthma
              where Asthma.overlapsEncounter("Qualifying CAD Encounter and Prior MI")
          )

define "Has Atrioventricular Block with Qualifying CAD Encounter and History of Moderate or Severe LVSD":
  exists ( 
            ["Condition": "Atrioventricular Block"] AtrioventricularBlock
              where AtrioventricularBlock.overlapsEncounter("Qualifying CAD Encounter and History of Moderate or Severe LVSD")
          )

define "Has Atrioventricular Block with Qualifying CAD Encounter and History of Moderate or Severe LVSD without Cardiac Pacer":
  "Has Atrioventricular Block with Qualifying CAD Encounter and History of Moderate or Severe LVSD"
    and not "Has Diagnosis of Cardiac Pacer in Situ with Qualifying CAD Encounter and History of Moderate or Severe LVSD"
    and not "Has Cardiac Pacer Device Implanted with Qualifying CAD Encounter and History of Moderate or Severe LVSD"

define "Has Atrioventricular Block with Qualifying CAD Encounter and Prior MI":
  exists ( 
            ["Condition": "Atrioventricular Block"] AtrioventricularBlock
              where AtrioventricularBlock.overlapsEncounter("Qualifying CAD Encounter and Prior MI") 
          )

define "Has Atrioventricular Block with Qualifying CAD Encounter and Prior MI without Cardiac Pacer":
  "Has Atrioventricular Block with Qualifying CAD Encounter and Prior MI"
    and not "Has Diagnosis of Cardiac Pacer in Situ with Qualifying CAD Encounter and Prior MI"
    and not "Has Cardiac Pacer Device Implanted with Qualifying CAD Encounter and Prior MI"

define "Has Beta Blocker Therapy for LVSD Ordered":
  exists ( 
            ["MedicationRequest": "Beta Blocker Therapy for LVSD"] BetaBlockerForLVSDOrdered
              with "Qualifying CAD Encounter and History of Moderate or Severe LVSD" CADEncounterModerateOrSevereLVSD
                such that BetaBlockerForLVSDOrdered.authoredOn during CADEncounterModerateOrSevereLVSD.period
              where BetaBlockerForLVSDOrdered.status in {'active', 'completed'}
                and BetaBlockerForLVSDOrdered.intent = 'order'
            )

define "Has Beta Blocker Therapy Ordered":
  exists ( 
            ["MedicationRequest": "Beta Blocker Therapy"] BetaBlockerOrdered
              with "Qualifying CAD Encounter and Prior MI" CADEncounterMI
                such that BetaBlockerOrdered.authoredOn during CADEncounterMI.period
              where BetaBlockerOrdered.status in {'active', 'completed'}
                  and BetaBlockerOrdered.intent = 'order'
             )

define "Has Bradycardia with Qualifying CAD Encounter and History of Moderate or Severe LVSD":
  exists ( 
            ["Condition": "Bradycardia"] Bradycardia
              with "Qualifying CAD Encounter and History of Moderate or Severe LVSD" CADEncounterModerateOrSevereLVSD
                such that Bradycardia.toPrevalenceInterval() overlaps CADEncounterModerateOrSevereLVSD.period
              where Bradycardia.isConfirmedActiveDiagnosis()
          )

define "Has Bradycardia with Qualifying CAD Encounter and Prior MI":
  exists ( 
            ["Condition": "Bradycardia"] Bradycardia
              with "Qualifying CAD Encounter and Prior MI" CADEncounterMI
                such that Bradycardia.toPrevalenceInterval() overlaps CADEncounterMI.period
              where Bradycardia.isConfirmedActiveDiagnosis()
          )

define "Has Cardiac Pacer Device Implanted with Qualifying CAD Encounter and Prior MI":
  exists ( 
            ["Procedure": "Cardiac Pacer"] ImplantedCardiacPacer
              with "Qualifying CAD Encounter and Prior MI" CADEncounterMI
                such that ImplantedCardiacPacer.performed.toInterval() overlaps after CADEncounterMI.period
                  or ImplantedCardiacPacer.performed.toInterval() before end of CADEncounterMI.period
              where ImplantedCardiacPacer.isCompleted()
     )

define "Has Cardiac Pacer Device Implanted with Qualifying CAD Encounter and History of Moderate or Severe LVSD":
  exists ( ["Procedure": "Cardiac Pacer"] ImplantedCardiacPacer
            with "Qualifying CAD Encounter and History of Moderate or Severe LVSD" CADEncounterModerateOrSevereLVSD
              such that ImplantedCardiacPacer.performed.toInterval() overlaps after CADEncounterModerateOrSevereLVSD.period
                or ImplantedCardiacPacer.performed.toInterval() before end of CADEncounterModerateOrSevereLVSD.period
            where ImplantedCardiacPacer.isCompleted()
          )

define "Has Consecutive Heart Rates Less than 50 with Qualifying CAD Encounter and History of Moderate or Severe LVSD":
  "Has Consecutive Heart Rates Less than 50 with Qualifying CAD Encounter"("Qualifying CAD Encounter and History of Moderate or Severe LVSD")

define "Has Consecutive Heart Rates Less than 50 with Qualifying CAD Encounter and Prior MI":
  "Has Consecutive Heart Rates Less than 50 with Qualifying CAD Encounter"("Qualifying CAD Encounter and Prior MI")

define function "Has Consecutive Heart Rates Less than 50 with Qualifying CAD Encounter"(Encounters List<Encounter>):
    exists ( 
            from
              ["observation-heartrate"] HeartRate,
              Encounters CADEncounter
              let PriorHeartRate: 
                Last ( ["observation-heartrate"] MostRecentPriorHeartRate
                    where MostRecentPriorHeartRate.effective.toInterval() during CADEncounter.period
                        and MostRecentPriorHeartRate.isCompleted()
                        and MostRecentPriorHeartRate.effective.toInterval() before HeartRate.effective.toInterval()
                    sort by start of effective.toInterval()
                    )
              where HeartRate.effective.toInterval() during CADEncounter.period
                and HeartRate.isCompleted()
                and HeartRate.value < 50 '/min'
                and PriorHeartRate.value < 50 '/min'
              return HeartRate
          )

define "Has Diagnosis of Allergy or Intolerance to Beta Blocker Therapy with Qualifying CAD Encounter and Prior MI":
  exists ( 
            ( ["Condition": "Allergy to Beta Blocker Therapy"]
                union ["Condition": "Intolerance to Beta Blocker Therapy"] ) BetaBlockerAllergyOrIntoleranceDiagnosis
              where BetaBlockerAllergyOrIntoleranceDiagnosis.overlapsAfterEncounter("Qualifying CAD Encounter and Prior MI")
       )

define "Has Diagnosis of Allergy or Intolerance to Beta Blocker Therapy with Qualifying CAD Encounter and History of Moderate or Severe LVSD":
  exists ( 
            ( ["Condition": "Allergy to Beta Blocker Therapy"]
              union ["Condition": "Intolerance to Beta Blocker Therapy"] ) BetaBlockerAllergyOrIntoleranceDiagnosis
                where BetaBlockerAllergyOrIntoleranceDiagnosis.overlapsAfterEncounter("Qualifying CAD Encounter and History of Moderate or Severe LVSD")
          )

define "Has Diagnosis of Cardiac Pacer in Situ with Qualifying CAD Encounter and Prior MI":
  exists ( 
            ["Condition": "Cardiac Pacer in Situ"] CardiacPacerDiagnosis
              where CardiacPacerDiagnosis.overlapsAfterEncounter("Qualifying CAD Encounter and Prior MI")
          )

define "Has Diagnosis of Cardiac Pacer in Situ with Qualifying CAD Encounter and History of Moderate or Severe LVSD":
  exists ( 
            ["Condition": "Cardiac Pacer in Situ"] CardiacPacerDiagnosis
              where CardiacPacerDiagnosis.overlapsAfterEncounter("Qualifying CAD Encounter and History of Moderate or Severe LVSD")
          )

define "Has Hypotension with Qualifying CAD Encounter and History of Moderate or Severe LVSD":
  exists ( 
            ["Condition": "Hypotension"] Hypotension
              where Hypotension.overlapsAfterEncounter("Qualifying CAD Encounter and History of Moderate or Severe LVSD")
          )

define "Has Hypotension with Qualifying CAD Encounter and Prior MI":
  exists ( 
            ["Condition": "Hypotension"] Hypotension
              where Hypotension.overlapsAfterEncounter("Qualifying CAD Encounter and Prior MI")
          )

/*This definition currently throws an error when evaluated in VS Code 
refer to https://github.com/cqframework/vscode-cql/issues/14 */ 
define "Has Medical Patient or System Reason for Not Ordering Beta Blocker for LVSD":
  exists ( 
            ["MedicationNotRequested"] NoBetaBlockerOrdered
            //currently no primary code path in model info for MedicationNotRequested
            //refer to https://github.com/cqframework/clinical_quality_language/issues/789
              where NoBetaBlockerOrdered.medication in "Beta Blocker Therapy for LVSD" 
                and NoBetaBlockerOrdered.isNotOrderedDuringEncounter("Qualifying CAD Encounter and History of Moderate or Severe LVSD")
          )

/*This definition currently throws an error when evaluated in VS Code 
refer to https://github.com/cqframework/vscode-cql/issues/14 */ 
define "Has Medical Patient or System Reason for Not Ordering Beta Blocker Therapy":
  exists ( 
            ["MedicationNotRequested"] NoBetaBlockerOrdered
            //currently no primary code path in model info for MedicationNotRequested
            //refer to https://github.com/cqframework/clinical_quality_language/issues/789
              where NoBetaBlockerOrdered.medication in "Beta Blocker Therapy" 
                and NoBetaBlockerOrdered.isNotOrderedDuringEncounter("Qualifying CAD Encounter and Prior MI") 
          )

define "History of Cardiac Surgery":
  AHA."Qualifying Encounter During Measurement Period" QualifyingEncounter
    with ["Procedure": "Cardiac Surgery"] CardiacSurgery
        such that CardiacSurgery.performed.toInterval() starts before end of QualifyingEncounter.period
          and CardiacSurgery.isCompleted()

define "Is Currently Taking Beta Blocker Therapy":
  exists ( 
            ["MedicationRequest": "Beta Blocker Therapy"] ActiveBetaBlocker
              with "Qualifying CAD Encounter and Prior MI" CADEncounterMI
              such that exists(ActiveBetaBlocker.dosageInstruction.timing T
                                  where T.repeat.bounds.toInterval() overlaps after CADEncounterMI.period )
              where ActiveBetaBlocker.status in { 'active', 'completed', 'finished' }            
                )

define "Is Currently Taking Beta Blocker Therapy for LVSD":
  exists ( 
            ["MedicationRequest": "Beta Blocker Therapy for LVSD"] ActiveBetaBlockerForLVSD
              with "Qualifying CAD Encounter and History of Moderate or Severe LVSD" CADEncounterModerateOrSevereLVSD
                such that exists(ActiveBetaBlockerForLVSD.dosageInstruction.timing T
                                  where T.repeat.bounds.toInterval() overlaps after CADEncounterModerateOrSevereLVSD.period )
              where ActiveBetaBlockerForLVSD.status in { 'active', 'completed', 'finished' }            
          )

define "Qualifying CAD Encounter":
  "Coronary Artery Disease Encounter"
    union "History of Cardiac Surgery"

define "Qualifying CAD Encounter and History of Moderate or Severe LVSD":
  ( "Qualifying CAD Encounter" EncounterWithCADProxy
      with AHA."Moderate or Severe LVSD Observations" LVSDObservations
        such that LVSDObservations.effective.toInterval() starts before end of EncounterWithCADProxy.period 
    )
  union 
  ( "Qualifying CAD Encounter" EncounterWithCADProxy
      with AHA."Moderate or Severe LVSD Conditions" LVSDObservations
        such that LVSDObservations.toPrevalenceInterval() starts before end of EncounterWithCADProxy.period 
    )

define "Qualifying CAD Encounter and Prior MI":
  "Qualifying CAD Encounter" EncounterWithCADProxy
    with ["Condition": "Myocardial Infarction"] MyocardialInfarction
      such that MyocardialInfarction.toPrevalenceInterval() starts 3 years or less before day of start of EncounterWithCADProxy.period
        and MyocardialInfarction.isConfirmedActiveDiagnosis()
    where not ( exists ( AHA."Moderate or Severe LVSD Observations" )
      or exists (AHA."Moderate or Severe LVSD Conditions") )

define fluent function isActiveAllergyBeforeOrDuringEncounter(Allergy AllergyIntolerance, Encounters List<Encounter>):
  exists ( Encounters encounter
            where ( Allergy.onset.toInterval() before encounter.period
                or Allergy.onset.toInterval() during encounter.period )
              and Allergy.clinicalStatus ~ Common."allergy-active"
              and Allergy.verificationStatus ~ Common."allergy-confirmed"
          )

define fluent function overlapsEncounter(Diagnosis Condition, Encounters List<Encounter>): 
  exists ( Encounters encounter
            where Diagnosis.toPrevalenceInterval() overlaps encounter.period
              and Diagnosis.isConfirmedActiveDiagnosis()
          )

define fluent function overlapsAfterEncounter(Diagnosis Condition, Encounters List<Encounter>): 
  exists ( Encounters encounter
            where Diagnosis.toPrevalenceInterval() overlaps after encounter.period
              and Diagnosis.isConfirmedActiveDiagnosis()
          )

define fluent function isCompleted(Element Choice<"observation-heartrate", MedicationNotRequested, Procedure>):
  case 
    when Element is "observation-heartrate" then 
      Element.status in {'final', 'amended', 'corrected'}
    when (Element is Procedure) or (Element is MedicationNotRequested) then 
      Element.status = 'completed'
    else false
  end

define fluent function isNotOrderedDuringEncounter(MedicationNotOrdered MedicationNotRequested, Encounters List<Encounter>):
  exists ( Encounters encounter
            where MedicationNotOrdered.authoredOn during encounter.period
              and ( MedicationNotOrdered.reasonCode in "Medical Reason"
                or MedicationNotOrdered.reasonCode in "Patient Reason"
                or MedicationNotOrdered.reasonCode in "System Reason" ) 
          )