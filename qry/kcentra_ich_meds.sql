WITH PATIENTS AS (
	SELECT DISTINCT
		ENCOUNTER.ENCNTR_ID,
		ENCOUNTER.ARRIVE_DT_TM
	FROM
		CLINICAL_EVENT,
		DIAGNOSIS,
		ENCOUNTER,
		NOMENCLATURE
	WHERE
		CLINICAL_EVENT.EVENT_CD = 926562948 -- prothrombin complex
		AND CLINICAL_EVENT.VALID_UNTIL_DT_TM > DATE '2099-12-31' 
		AND CLINICAL_EVENT.EVENT_END_DT_TM BETWEEN DATE '2015-09-01' AND DATE '2019-07-01'
		AND (
			CLINICAL_EVENT.ENCNTR_ID = ENCOUNTER.ENCNTR_ID
			AND ENCOUNTER.ACTIVE_IND = 1
			AND ENCOUNTER.LOC_FACILITY_CD IN (3310, 3796) -- HH HERMANN, HC Childrens
		)
		AND (
			CLINICAL_EVENT.ENCNTR_ID = DIAGNOSIS.ENCNTR_ID
			AND DIAGNOSIS.ACTIVE_IND = 1
			AND DIAGNOSIS.DIAG_TYPE_CD = 26244 -- Final
		)
		AND (
			DIAGNOSIS.NOMENCLATURE_ID = NOMENCLATURE.NOMENCLATURE_ID
			AND NOMENCLATURE.ACTIVE_IND = 1
			AND REGEXP_INSTR(NOMENCLATURE.SOURCE_IDENTIFIER, 'I61|I62') > 0
		)

	UNION

	SELECT DISTINCT
		ENCOUNTER.ENCNTR_ID,
		ENCOUNTER.ARRIVE_DT_TM
	FROM
		CLINICAL_EVENT,
		DIAGNOSIS,
		ENCOUNTER,
		NOMENCLATURE
	WHERE
		CLINICAL_EVENT.EVENT_CD = 926562948 -- prothrombin complex
		AND CLINICAL_EVENT.VALID_UNTIL_DT_TM > DATE '2099-12-31' 
		AND CLINICAL_EVENT.EVENT_END_DT_TM BETWEEN DATE '2013-05-01' AND DATE '2015-11-01'
		AND (
			CLINICAL_EVENT.ENCNTR_ID = ENCOUNTER.ENCNTR_ID
			AND ENCOUNTER.ACTIVE_IND = 1
			AND ENCOUNTER.LOC_FACILITY_CD IN (3310, 3796) -- HH HERMANN, HC Childrens
		)
		AND (
			CLINICAL_EVENT.ENCNTR_ID = DIAGNOSIS.ENCNTR_ID
			AND DIAGNOSIS.ACTIVE_IND = 1
			AND DIAGNOSIS.DIAG_TYPE_CD = 26244 -- Final
		)
		AND (
			DIAGNOSIS.NOMENCLATURE_ID = NOMENCLATURE.NOMENCLATURE_ID
			AND NOMENCLATURE.ACTIVE_IND = 1
			AND REGEXP_INSTR(NOMENCLATURE.SOURCE_IDENTIFIER, '431|432.9') > 0
		)
)

SELECT DISTINCT
	ENCNTR_ALIAS.ALIAS AS FIN,
	pi_from_gmt(CLINICAL_EVENT.EVENT_END_DT_TM, (pi_time_zone(1, @Variable('BOUSER')))) AS MED_DATETIME,
	(CLINICAL_EVENT.EVENT_END_DT_TM - PATIENTS.ARRIVE_DT_TM) * 24 AS HRS_ARRIVAL,
	pi_get_cv_display(CLINICAL_EVENT.EVENT_CD) AS MEDICATION,
	CE_MED_RESULT.ADMIN_DOSAGE AS DOSE,
	pi_get_cv_display(CE_MED_RESULT.DOSAGE_UNIT_CD) AS DOSE_UNIT,
	pi_get_cv_display(CE_MED_RESULT.ADMIN_ROUTE_CD) AS ROUTE	
FROM
	CE_MED_RESULT,
	CLINICAL_EVENT,
	ENCNTR_ALIAS,
	PATIENTS
WHERE
	PATIENTS.ENCNTR_ID = CLINICAL_EVENT.ENCNTR_ID
	AND CLINICAL_EVENT.EVENT_CD IN (926562948, 37557833) -- (prothrombin complex, phytonadione)
	AND CLINICAL_EVENT.VALID_UNTIL_DT_TM > DATE '2099-12-31' 
	AND (
		CLINICAL_EVENT.EVENT_ID = CE_MED_RESULT.EVENT_ID
		AND CE_MED_RESULT.ADMIN_DOSAGE > 0
	)
	AND (
		PATIENTS.ENCNTR_ID = ENCNTR_ALIAS.ENCNTR_ID
		AND ENCNTR_ALIAS.ACTIVE_IND = 1
		AND ENCNTR_ALIAS.END_EFFECTIVE_DT_TM > SYSDATE
		AND ENCNTR_ALIAS.ENCNTR_ALIAS_TYPE_CD = 619 -- FIN NBR
	)
