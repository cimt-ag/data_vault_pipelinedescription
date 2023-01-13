
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test33_simple_hub_msat';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test33_simple_hub_msat','{
	"dvpd_version": "1.0",
	"pipeline_name": "test33_simple_hub_msat",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_33_aaa_hub"}]},
		 	  {"field_name": "F2_BK_AAA_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_33_aaa_hub"}]},
		 	  {"field_name": "F3_AAA_SP1_VARCHAR",		"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_33_aaa_p1_msat"}]},
			  {"field_name": "F4_AAA_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_33_aaa_p1_msat"}]},
			  {"field_name": "F5__FIELD_NAME",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_33_aaa_p1_msat",
																									 "target_column_name":"F5_AAA_SP1_VARCHAR"}]},
			  {"field_name": "F6_AAA_SP1_TIMESTAMP_XRH",	"field_type": "TIMESTAMP",		"targets": [{"table_name": "rtjj_33_aaa_p1_msat","exclude_from_diff_hash": "true"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_33_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_33_aaa"},
				{"table_name": "rtjj_33_aaa_p1_msat",	"stereotype": "sat","satellite_parent_table": "rtjj_33_aaa_HUB"
															,"is_multiactive":true,"diff_hash_column_name": "gH_rtjj_33_aaa_p1_msat"}
				]
		}
	]
}
');
select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test33_simple_hub_msat');


DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test33_simple_hub_msat';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test33_simple_hub_msat','{
	"dv_model_column": [
			["rvlt_test_jj","rtjj_33_aaa_hub"	,2,	"key",				"HK_RTJJ_33_AAA"	,"CHAR(28)"]
			,["rvlt_test_jj","rtjj_33_aaa_hub"	,8,	"business_key",		"F1_BK_AAA_VARCHAR"	,"VARCHAR(20)"]
			,["rvlt_test_jj","rtjj_33_aaa_hub"	,8,	"business_key",		"F2_BK_AAA_DECIMAL"	,"DECIMAL(20,0)"]
			,["rvlt_test_jj","rtjj_33_aaa_p1_msat",	2,	"parent_key",	"HK_RTJJ_33_AAA"	,"CHAR(28)"]
			,["rvlt_test_jj","rtjj_33_aaa_p1_msat",	3,	"diff_hash",	"GH_RTJJ_33_AAA_P1_MSAT"	,"CHAR(28)"]
			,["rvlt_test_jj","rtjj_33_aaa_p1_msat",	8,	"content",		"F3_AAA_SP1_VARCHAR"	,"VARCHAR(200)"]
			,["rvlt_test_jj","rtjj_33_aaa_p1_msat",	8,	"content",		"F4_AAA_SP1_DECIMAL"	,"DECIMAL(5,0)"]
			,["rvlt_test_jj","rtjj_33_aaa_p1_msat",	8,	"content",		"F5_AAA_SP1_VARCHAR"	,"VARCHAR(200)"]
			,["rvlt_test_jj","rtjj_33_aaa_p1_msat",	8,	"content_untracked",	"F6_AAA_SP1_TIMESTAMP_XRH",	"TIMESTAMP"]
],
 "process_column_mapping": [
         ["rtjj_33_aaa_hub","_A_","HK_RTJJ_33_AAA","HK_RTJJ_33_AAA",null],
         ["rtjj_33_aaa_hub","_A_","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR"],
         ["rtjj_33_aaa_hub","_A_","F2_BK_AAA_DECIMAL","F2_BK_AAA_DECIMAL","F2_BK_AAA_DECIMAL"],
         ["rtjj_33_aaa_p1_msat","_A_","HK_RTJJ_33_AAA","HK_RTJJ_33_AAA",null],
         ["rtjj_33_aaa_p1_msat","_A_","GH_RTJJ_33_AAA_P1_MSAT","GH_RTJJ_33_AAA_P1_MSAT",null],
         ["rtjj_33_aaa_p1_msat","_A_","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR"],
         ["rtjj_33_aaa_p1_msat","_A_","F4_AAA_SP1_DECIMAL","F4_AAA_SP1_DECIMAL","F4_AAA_SP1_DECIMAL"],
         ["rtjj_33_aaa_p1_msat","_A_","F5_AAA_SP1_VARCHAR","F5__FIELD_NAME","F5__FIELD_NAME"],
         ["rtjj_33_aaa_p1_msat","_A_","F6_AAA_SP1_TIMESTAMP_XRH","F6_AAA_SP1_TIMESTAMP_XRH","F6_AAA_SP1_TIMESTAMP_XRH"]
 ],
 "stage_table_column": [
		["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
		["F2_BK_AAA_DECIMAL","DECIMAL(20,0)",8,"F2_BK_AAA_DECIMAL","DECIMAL(20,0)",false],
		["F3_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F3_AAA_SP1_VARCHAR","VARCHAR(200)",false],
		["F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",8,"F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",false],
		["F5__FIELD_NAME","VARCHAR(200)",8,"F5__FIELD_NAME","VARCHAR(200)",false],
		["F6_AAA_SP1_TIMESTAMP_XRH","TIMESTAMP",8,"F6_AAA_SP1_TIMESTAMP_XRH","TIMESTAMP",false],
		["HK_RTJJ_33_AAA","CHAR(28)",2,null,null,false],
		["GH_RTJJ_33_AAA_P1_MSAT","CHAR(28)",3,null,null,false]
],
"stage_hash_input_field": [                                       
        ["_A_","HK_RTJJ_33_AAA","F1_BK_AAA_VARCHAR",0,0],         
        ["_A_","HK_RTJJ_33_AAA","F2_BK_AAA_DECIMAL",0,0],         
        ["_A_","GH_RTJJ_33_AAA_P1_MSAT","F3_AAA_SP1_VARCHAR",0,0], 
        ["_A_","GH_RTJJ_33_AAA_P1_MSAT","F4_AAA_SP1_DECIMAL",0,0], 
        ["_A_","GH_RTJJ_33_AAA_P1_MSAT","F5__FIELD_NAME",0,0]
]
}');                                                                                                              

