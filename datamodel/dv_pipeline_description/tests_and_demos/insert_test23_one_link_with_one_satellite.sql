
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test23_one_link_with_one_satellite';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test23_one_link_with_one_satellite','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test23_one_link_with_one_satellite",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 	"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_23_aaa_hub"}]}
		 	  ,{"field_name": "F2_BK_BBB_DECIMAL",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_23_bbb_hub"}]}
		 	  ,{"field_name": "F3_AAA_SP1_VARCHAR",	"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_23_aaa_bbb_sat"}]}
			  ,{"field_name": "F4_AAA_SP1_DECIMAL",	"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_23_aaa_bbb_sat"}]}
			  ,{"field_name": "F5_XXX_BAD_NAME_XXX",	"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_23_aaa_bbb_sat",
																									 "target_column_name":"F5_AAA_SP1_VARCHAR"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_23_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_23_aaa"}
				,{"table_name": "rtjj_23_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_23_bbb"}
				,{"table_name": "rtjj_23_aaa_bbb_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rtjj_23_aaa_bbb",
																				"link_parent_tables": ["rtjj_23_aaa_hub","rtjj_23_bbb_hub"]}
				,{"table_name": "rtjj_23_aaa_bbb_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_23_aaa_bbb_lnk","diff_hash_column_name": "RH_rtjj_23_aaa_bbb_sat"}
				]
		}
	]
}
');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test23_one_link_with_one_satellite';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test23_one_link_with_one_satellite','{
	"dv_model_column": [
		["rvlt_test_jj","rtjj_23_aaa_bbb_lnk",2,"key","LK_RTJJ_23_AAA_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_23_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_23_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_23_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_23_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_23_aaa_bbb_sat",2,"parent_key","LK_RTJJ_23_AAA_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_23_aaa_bbb_sat",3,"diff_hash","RH_RTJJ_23_AAA_BBB_SAT","CHAR(28)"],
		["rvlt_test_jj","rtjj_23_aaa_bbb_sat",8,"content","F3_AAA_SP1_VARCHAR","VARCHAR(200)"],
		["rvlt_test_jj","rtjj_23_aaa_bbb_sat",8,"content","F4_AAA_SP1_DECIMAL","DECIMAL(5,0)"],
		["rvlt_test_jj","rtjj_23_aaa_bbb_sat",8,"content","F5_AAA_SP1_VARCHAR","VARCHAR(200)"],
		["rvlt_test_jj","rtjj_23_aaa_hub",2,"key","HK_RTJJ_23_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_23_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"],
		["rvlt_test_jj","rtjj_23_bbb_hub",2,"key","HK_RTJJ_23_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_23_bbb_hub",8,"business_key","F2_BK_BBB_DECIMAL","DECIMAL(20,0)"]
],
 "stage_table_column": [
		["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
		["F2_BK_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_BK_BBB_DECIMAL","DECIMAL(20,0)",false],
		["F3_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F3_AAA_SP1_VARCHAR","VARCHAR(200)",false],
		["F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",8,"F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",false],
		["F5_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F5_XXX_BAD_NAME_XXX","VARCHAR(200)",false],
		["HK_RTJJ_23_AAA","CHAR(28)",2,null,null,false],
		["HK_RTJJ_23_BBB","CHAR(28)",2,null,null,false],
		["LK_RTJJ_23_AAA_BBB","CHAR(28)",2,null,null,false],
		["RH_RTJJ_23_AAA_BBB_SAT","CHAR(28)",3,null,null,false]
]
}');                                                                                                              

