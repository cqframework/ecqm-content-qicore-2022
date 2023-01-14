library Immunization version '1.0.0'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include QICoreCommon version '1.2.000' called QICoreCommon
include CQMCommon version '1.0.000' called CQMCommon

context Patient

define function "Diagnosis on or before Latest Possible Vaccination Date"(Diagnosis List<Condition>, LastVaccineDate System.Date):
  Diagnosis ExclusionDiagnosis
    where ( start of QICoreCommon."ToPrevalenceInterval" ( ExclusionDiagnosis ) ) on or before LastVaccineDate

define function "Administered Date"(Vaccination Choice<Immunization, Procedure>):
  case
    when Vaccination is Immunization then start of ( QICoreCommon."ToInterval" ( ( Vaccination as Immunization ).occurrence ) )
    when Vaccination is Procedure then 
    end of ( QICoreCommon."ToInterval" ( ( Vaccination as Procedure ).performed ) ) 
    else null 
  end

// Use if the vaccinations follow the 14-day rule

define function "Meets Required Vaccination Threshold with 14-Day Rule"(VaccinationList List<Choice<Immunization, Procedure>>, VaccinationPeriod Interval<Date>, MinimumThreshold Integer):
  exists ( VaccinationList Vaccine1
      let VaccineDate1: "Administered Date"(Vaccine1)
      where ( MinimumThreshold = 1
          and ( VaccineDate1 ) during VaccinationPeriod
      )
        or ( MinimumThreshold = 2
            and exists ( VaccinationList Vaccine2
                let VaccineDate2: "Administered Date"(Vaccine2)
                where ( VaccineDate1 ) during VaccinationPeriod
                  and VaccineDate2 during VaccinationPeriod
                  and VaccineDate1 14 days or more before VaccineDate2
            )
        )
        or ( MinimumThreshold = 3
            and exists ( from
                VaccinationList Vaccine2,
                VaccinationList Vaccine3
                let VaccineDate2: "Administered Date"(Vaccine2),
                VaccineDate3: "Administered Date"(Vaccine3)
                where VaccineDate1 during VaccinationPeriod
                  and VaccineDate2 during VaccinationPeriod
                  and VaccineDate3 during VaccinationPeriod
                  and VaccineDate1 14 days or more before VaccineDate2
                  and VaccineDate2 14 days or more before VaccineDate3
                return Vaccine1
            )
        )
        or ( MinimumThreshold = 4
            and exists ( from
                VaccinationList Vaccine2,
                VaccinationList Vaccine3,
                VaccinationList Vaccine4
                let VaccineDate2: "Administered Date"(Vaccine2),
                VaccineDate3: "Administered Date"(Vaccine3),
                VaccineDate4: "Administered Date"(Vaccine4)
                where VaccineDate1 during VaccinationPeriod
                  and VaccineDate2 during VaccinationPeriod
                  and VaccineDate3 during VaccinationPeriod
                  and VaccineDate4 during VaccinationPeriod
                  and VaccineDate1 14 days or more before VaccineDate2
                  and VaccineDate2 14 days or more before VaccineDate3
                  and VaccineDate3 14 days or more before VaccineDate4
                return Vaccine1
            )
        )
  )

// Use if the 14-day rule is not needed

define function "Meets Required Vaccination Threshold"(VaccinationList List<Choice<Immunization, Procedure>>, VaccinationPeriod Interval<Date>, MinimumThreshold Integer):
  Count(Distinct(VaccinationList Vaccine
        let vaccinationDate: "Administered Date"(Vaccine)
        where vaccinationDate during VaccinationPeriod
        return {
          i: Vaccine.id,
          code: if Vaccine is Immunization then(Vaccine as Immunization).vaccineCode 
            else if Vaccine is Procedure then(Vaccine as Procedure).code 
            else null,
          vaccinationDate: vaccinationDate
        }
    ).vaccinationDate
  )>= MinimumThreshold

// Use if there is something other than 14 days needed between vaccinations

define function "Meets Required Threshold with Variable Days Apart"(VaccinationList List<Choice<Immunization, Procedure>>, VaccinationPeriod Interval<Date>, MinimumThreshold Integer, DaysBetween Integer):
  exists ( VaccinationList Vaccine1
      let VaccineDate1: "Administered Date"(Vaccine1)
      where ( MinimumThreshold = 2
          and exists ( VaccinationList Vaccine2
              let VaccineDate2: "Administered Date"(Vaccine2)
              where VaccineDate1 during VaccinationPeriod
                and VaccineDate2 during VaccinationPeriod
                and days between VaccineDate1 and VaccineDate2 >= DaysBetween
          )
      )
  )
