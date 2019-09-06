SELECT DISTINCT
	ENCOUNTER.ENCNTR_ID
FROM
	CLINICAL_EVENT,
    DIAGNOSIS,
	ENCOUNTER,
	NOMENCLATURE
WHERE
	CLINICAL_EVENT.EVENT_CD = 926562948
	AND CLINICAL_EVENT.VALID_UNTIL_DT_TM > DATE '2099-12-31' 
	AND CLINICAL_EVENT.EVENT_END_DT_TM BETWEEN DATE '2015-09-01' AND DATE '2019-07-01'
	AND (
		CLINICAL_EVENT.ENCNTR_ID = ENCOUNTER.ENCNTR_ID
		AND CLINICAL_EVENT.PERSON_ID = ENCOUNTER.PERSON_ID
		AND ENCOUNTER.ACTIVE_IND = 1
		AND ENCOUNTER.LOC_FACILITY_CD IN (3310, 3796)
	)
	AND (
	    CLINICAL_EVENT.ENCNTR_ID = DIAGNOSIS.ENCNTR_ID
        AND DIAGNOSIS.ACTIVE_IND = 1
        AND DIAGNOSIS.DIAG_TYPE_CD = 26244
	)
    AND (
        DIAGNOSIS.NOMENCLATURE_ID = NOMENCLATURE.NOMENCLATURE_ID
        AND NOMENCLATURE.ACTIVE_IND = 1
        AND REGEXP_INSTR(NOMENCLATURE.SOURCE_IDENTIFIER, 'I61|I62') > 0
    )

UNION

SELECT DISTINCT
	ENCOUNTER.ENCNTR_ID
FROM
	CLINICAL_EVENT,
    DIAGNOSIS,
	ENCOUNTER,
	NOMENCLATURE
WHERE
	CLINICAL_EVENT.EVENT_CD = 926562948
	AND CLINICAL_EVENT.VALID_UNTIL_DT_TM > DATE '2099-12-31' 
	AND CLINICAL_EVENT.EVENT_END_DT_TM BETWEEN DATE '2013-05-01' AND DATE '2015-11-01'
	AND (
		CLINICAL_EVENT.ENCNTR_ID = ENCOUNTER.ENCNTR_ID
		AND CLINICAL_EVENT.PERSON_ID = ENCOUNTER.PERSON_ID
		AND ENCOUNTER.ACTIVE_IND = 1
		AND ENCOUNTER.LOC_FACILITY_CD IN (3310, 3796, 3821, 3822, 3823)
	)
	AND (
	    CLINICAL_EVENT.ENCNTR_ID = DIAGNOSIS.ENCNTR_ID
        AND DIAGNOSIS.ACTIVE_IND = 1
        AND DIAGNOSIS.DIAG_TYPE_CD = 26244
	)
    AND (
        DIAGNOSIS.NOMENCLATURE_ID = NOMENCLATURE.NOMENCLATURE_ID
        AND NOMENCLATURE.ACTIVE_IND = 1
        AND REGEXP_INSTR(NOMENCLATURE.SOURCE_IDENTIFIER, '431|432.9') > 0
    )
