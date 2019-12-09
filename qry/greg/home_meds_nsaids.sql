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
		9902669, -- ibuprofen
		9902706, -- naproxen
		9902745, -- fenoprofen
		9902754, -- ketoprofen
		9902773, -- sulindac
		9902807, -- indomethacin
		9902918, -- tolmetin
		9903671, -- diflunisal
		9903830, -- flurbiprofen
		9903944, -- ketOROLAC
		9903981, -- meclofenamate
		9903990, -- mefenamic acid
		9904094, -- nabumetone
		9904231, -- piroxicam
		9905730, -- diclofenac
		9905736, -- etodolac
		9905740, -- oxaprozin
		9912787, -- diclofenac-misoprostol
		9913582, -- meloxicam
		118568480, -- lansoprazole-naproxen
		527377928, -- esomeprazole-naproxen
		686906165 -- famotidine-ibuprofen
	) 
	AND ORDERS.CATALOG_TYPE_CD = 1363 -- Pharmacy
	AND ORDERS.ACTIVITY_TYPE_CD = 378 -- Pharmacy
	AND ORDERS.ORIG_ORD_AS_FLAG = 2 -- Recorded / Home Meds
