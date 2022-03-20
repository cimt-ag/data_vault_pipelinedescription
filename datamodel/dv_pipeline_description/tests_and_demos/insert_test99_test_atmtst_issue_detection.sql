
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test99_test_atmtst_issue_detection';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test99_test_atmtst_issue_detection','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test99_test_atmtst_issue_detection",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		 	  	{"field_name": "F1_BK_AAA_DECIMAL",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_99_AAA_HUB"}]}
		 	  	,{"field_name": "F2_AAA_XXX_BAD_FIELD_IN_RESULT_DECIMAL",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_99_aaa_p1_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_99_AAA_HUB",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_99_AAA_HUB"}
				,{"table_name": "rtjj_99_aaa_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_99_AAA_HUB","diff_hash_column_name": "RH_rtjj_99_aaa_p1_sat"}
				]
		}
	]
}
');


DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test99_test_atmtst_issue_detection';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test99_test_atmtst_issue_detection','{
	"dv_model_column": [
	["rvlt_test_jj","rtjj_99_aaa_hub",2,"key","HK_RTJJ_99_AAA_HUB","CHAR(28)"],
	["rvlt_test_jj","rtjj_99_aaa_hub",8,"business_key","F1_BK_AAA_DECIMAL","DECIMAL(20,0)"],
	["rvlt_test_jj","rtjj_99_aaa_p1_sat",2,"parent_key","HK_RTJJ_99_AAA_HUB","CHAR(28)"],
	["rvlt_test_jj","rtjj_99_aaa_p1_sat",3,"diff_hash","RH_RTJJ_99_AAA_P1_SAT","CHAR(28)"],
	["rvlt_test_jj","rtjj_99_aaa_p1_sat",8,"content","F2_AAA_XXX_BAD_FIELD_IN_REF_DECIMAL","DECIMAL(20,0)"]
],
 "stage_table_column": [
		["F1_BK_AAA_DECIMAL","DECIMAL(20,0)",8,"F1_BK_AAA_DECIMAL","DECIMAL(20,0)",false],
		["F2_AAA_XXX_BAD_COLUMN_IN_REF_DECIMAL","DECIMAL(20,0)",8,"F2_AAA_XXX_BAD_FIELD_IN_REF_DECIMAL","DECIMAL(20,0)",false],
		["HK_RTJJ_99_AAA_HUB","CHAR(28)",2,null,null,false],
		["RH_RTJJ_99_AAA_P1_SAT","CHAR(28)",3,null,null,false]
],
"stage_hash_input_field": [                                                          
        ["_A_","HK_RTJJ_99_AAA_HUB","F1_BK_AAA_DECIMAL",0,0],                        
        ["_A_","RH_RTJJ_99_AAA_P1_SAT","XXX BAD FIELD IN REF TRIGGER XXX",0,0]
]
}');                                                                                                              
