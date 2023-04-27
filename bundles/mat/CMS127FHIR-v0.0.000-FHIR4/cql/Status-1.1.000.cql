library Status version '1.1.000'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include FHIRCommon version '4.1.000' called FHIRCommon

codesystem "ObservationCategoryCodes": 'http://terminology.hl7.org/CodeSystem/observation-category'
codesystem "ConditionClinicalStatusCodes": 'http://terminology.hl7.org/CodeSystem/condition-clinical'

code "laboratory": 'laboratory' from "ObservationCategoryCodes" display 'laboratory'
code "exam": 'exam' from "ObservationCategoryCodes" display 'exam'
code "survey": 'survey' from "ObservationCategoryCodes" display 'survey'
code "vital-signs": 'vital-signs' from "ObservationCategoryCodes" display 'vital-signs'
code "active": 'active' from "ConditionClinicalStatusCodes"

context Patient

define function "Active Condition"(Condition List<Condition>):
  Condition C
    where C.clinicalStatus ~ "active"

define function "Finished Encounter"(Enc List<Encounter>):
  Enc E
    where E.status ~ 'finished'

define function "Finished or Ongoing Encounter"(Enc List<Encounter>):
  Enc E
    where E.status in { 'finished', 'in-progress' }

define function "Completed Immunization"(Immunization List<Immunization>):
  Immunization I
    where I.status ~ 'completed'

define function "Dispensed Medication"(Med List<MedicationDispense>):
  Med M
    where M.status ~ 'completed'

define function "Initial or Final Observation"(Obs List<Observation>):
  Obs O
    where O.status in { 'preliminary', 'final', 'amended', 'corrected' }

define function "Final Observation"(Obs List<Observation>):
  Obs O
    where O.status in {'final', 'amended', 'corrected' }

define function "Final Lab Observation"(Obs List<Observation>):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
      and exists ( O.category ObservationCategory
          where ( ObservationCategory ) ~ "laboratory"
      )

define function "Final Exam Observation"(Obs List<Observation>):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
      and exists ( O.category ObservationCategory
          where ( ObservationCategory ) ~ "exam"
      )

define function "Final Survey Observation"(Obs List<Observation>):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
      and exists ( O.category ObservationCategory
          where ( ObservationCategory ) ~ "survey"
      )

define function "BloodPressure"(Obs List<"QICore.observation-bp">):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
      
define function "BodyHeight"(Obs List<"QICore.observation-bodyheight">):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
      
define function "BodyWeight"(Obs List<"QICore.observation-bodyweight">):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
      
define function "BMI"(Obs List<"QICore.observation-bmi">):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }

define function "Completed Procedure"(Proc List<Procedure>):
  Proc P
    where P.status ~ 'completed'

define function "Completed or Ongoing Service Request"(ServiceRequest List<ServiceRequest>):
  ServiceRequest S
    where S.status in { 'active', 'completed' }
      and S.intent = 'order'

define function "Completed or Ongoing Device Request"(DeviceRequest List<DeviceRequest>):
  DeviceRequest D
    where D.status in { 'active', 'completed' }
      and D.intent = 'order'

define function "Active Medication"(MedicationRequest List<MedicationRequest>):
  MedicationRequest M
    where M.status = 'active'
      and M.intent = 'order'
      or M.intent = 'plan'

define function "Active or Completed Medication Request"(MedicationRequest List<MedicationRequest>):
  MedicationRequest M
    where M.status in { 'active', 'completed' }
      and M.intent = 'order'