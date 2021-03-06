WITH PATIENTS AS (
	SELECT DISTINCT
		ENCOUNTER.ENCNTR_ID,
		ENCOUNTER.PERSON_ID,
		ENCNTR_ALIAS.ALIAS,
		ENCOUNTER.DISCH_DT_TM
	FROM
		ENCNTR_ALIAS,
		ENCOUNTER
	WHERE
	    ENCNTR_ALIAS.ALIAS IN @prompt('Enter value(s) for Alias','A',,Multi,Free,Persistent,,User:0)
		AND ENCNTR_ALIAS.ENCNTR_ALIAS_TYPE_CD = 619 -- FIN NBR
		AND ENCNTR_ALIAS.ENCNTR_ID = ENCOUNTER.ENCNTR_ID
)

SELECT DISTINCT
	PATIENTS.ALIAS AS FIN,
	pi_get_cv_display(ORDERS.CATALOG_CD) AS HOME_MED
FROM
	ORDERS,
	PATIENTS
WHERE
	PATIENTS.PERSON_ID = ORDERS.PERSON_ID
	AND PATIENTS.ENCNTR_ID = ORDERS.ENCNTR_ID
	AND ORDERS.CATALOG_CD IN (
		9902731, -- warfarin
		642177882, -- rivaroxaban
		894197557, -- apixaban
		1466817855 -- edoxaban
	) 
	AND ORDERS.CATALOG_TYPE_CD = 1363 -- Pharmacy
	AND ORDERS.ACTIVITY_TYPE_CD = 378 -- Pharmacy
	AND ORDERS.ORIG_ORD_AS_FLAG = 2 -- Recorded / Home Meds
