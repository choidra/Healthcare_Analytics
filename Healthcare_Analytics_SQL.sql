--Creating table for patient data (data imported from csv)
CREATE TABLE patient_data(
'encounter_ID' INT PRIMARY KEY,
'patient_nbr' INT,
'race' VARCHAR(50),
'gender' VARCHAR(50),
'age' VARCHAR(70),
'weight' VARCHAR(70),
'payer_code' VARCHAR (10) ) ;


--Creating table for admission data (data imported from csv)
CREATE TABLE admission_data(
'encounter_ID' INT PRIMARY KEY,
'admission_type_id' INT,
'time_in_hospital' INT,
'num_lab_procedures' INT,
'num_procedures' INT,
'num_medications' INT,
'number_diagnoses' INT,
'medical_specialty' VARCHAR (100),
'change' VARCHAR(5),
'diabetesMed' VARCHAR(5),
'readmitted' VARCHAR(5),
FOREIGN KEY ('encounter_ID') REFERENCES patient_data('encounter_ID') ) ;


--Calculating the total number of patient encounters
SELECT COUNT(encounter_ID) as "Total Patient Encounters"
FROM patient_data pd ;


--Identifying top 10 most frequent diagnoses by medical specialty
SELECT medical_specialty , COUNT(encounter_ID) as "number_of_occurances"
FROM admission_data ad
GROUP BY medical_specialty 
ORDER BY COUNT(encounter_ID) DESC
LIMIT 10 ;


--Calclating average length of hospital stay for top 10 most frequest diagnoses by medical specialty
SELECT medical_specialty , ROUND(AVG(time_in_hospital), 0) as "average_days_spent_in_hospital"
FROM admission_data ad 
GROUP BY medical_specialty 
ORDER BY ROUND(AVG(time_in_hospital), 0) DESC
LIMIT 10 ;


--Calculating average length of hospital stay for each admission type
SELECT admission_type_id , ROUND(AVG(time_in_hospital), 0) as "average_days_spent_in_hospital"
FROM admission_data ad
GROUP BY ad.admission_type_id
ORDER BY ROUND(AVG(time_in_hospital), 0) DESC ;


--Calucating total number of readmissions and the percentage of total encounters they represent
WITH count_readmissions AS(
SELECT COUNT(encounter_ID) as "number_of_readmissions"
FROM admission_data ad 
WHERE readmitted IS NOT "NO"
)
SELECT (SELECT * FROM count_readmissions) as "number_of_readmissions",
		COUNT(encounter_ID) as "total_admissions",
		ROUND(((CAST((SELECT * FROM count_readmissions) AS FLOAT) / COUNT(encounter_ID)) * 100), 2) as "percentage_of_readmissions"
FROM admission_data ad ;


--Calculating age distribution of patients
SELECT age as "age_range", COUNT(encounter_ID) as "number_of_patients"
FROM patient_data pd
GROUP BY age ;


--Calculating average number of medications prescribed for patients in each age group
SELECT pd.age as "age_range", ROUND(AVG(ad.num_medications), 2) as "average_number_of_medications_prescribed"
FROM patient_data pd 
INNER JOIN admission_data ad ON pd.encounter_ID = ad.encounter_ID
GROUP BY pd.age ;


--Identifying most common procedure types among patient encounters
SELECT medical_specialty as "procedure_type", COUNT (encounter_ID) as "patient_encounters"
FROM admission_data ad 
WHERE medical_specialty  LIKE "%Surgery%"
GROUP BY medical_specialty
ORDER BY COUNT (encounter_ID) DESC
LIMIT 10 ;


--Identifying distribution of readmission rates across different payer codes
SELECT  DISTINCT pd.payer_code, ad.readmitted as "readmission_rates", COUNT(ad.encounter_ID) as "patient encounters"
FROM patient_data pd 
INNER JOIN admission_data ad ON pd.encounter_ID = ad.encounter_ID
GROUP BY pd.payer_code, ad.readmitted ;


