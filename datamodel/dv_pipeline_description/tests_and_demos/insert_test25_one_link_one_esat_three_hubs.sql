/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test25_one_link_one_esat_three_hubs';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test25_one_link_one_esat_three_hubs','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test25_one_link_one_esat_three_hubs",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 	"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_25_aaa_hub"}]}
		 	  ,{"field_name": "F2_BK_BBB_DECIMAL",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_25_bbb_hub"}]}
		 	  ,{"field_name": "F3_BK_CCC_DECIMAL",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_25_ccc_hub"}]}
		 	  ,{"field_name": "F4_AAA_SP1_VARCHAR",	"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_25_aaa_p1_sat"}]}
			  ,{"field_name": "F5_AAA_SP1_DECIMAL",	"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_25_aaa_p1_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_25_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_25_aaa"}
				,{"table_name": "rtjj_25_aaa_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_25_aaa_HUB","diff_hash_column_name": "RH_rtjj_25_aaa_P1_SAT"}
				,{"table_name": "rtjj_25_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_25_bbb"}
				,{"table_name": "rtjj_25_ccc_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_25_ccc"}
				,{"table_name": "rtjj_25_aaa_bbb_ccc_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rtjj_25_aaa_bbb_ccc",
																				"link_parent_tables": ["rtjj_25_aaa_hub","rtjj_25_bbb_hub","rtjj_25_ccc_hub"]}
				,{"table_name": "rtjj_25_aaa_bbb_ccc_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_25_aaa_bbb_ccc_lnk"}
				]
		}
	]
}
');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test25_one_link_one_esat_three_hubs';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test25_one_link_one_esat_three_hubs','{
	"dv_model_column": [
		["rvlt_test_jj","rtjj_25_aaa_bbb_ccc_esat",2,"parent_key","LK_RTJJ_25_AAA_BBB_CCC","CHAR(28)"],
		["rvlt_test_jj","rtjj_25_aaa_bbb_ccc_lnk",2,"key","LK_RTJJ_25_AAA_BBB_CCC","CHAR(28)"],
		["rvlt_test_jj","rtjj_25_aaa_bbb_ccc_lnk",3,"parent_key","HK_RTJJ_25_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_25_aaa_bbb_ccc_lnk",3,"parent_key","HK_RTJJ_25_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_25_aaa_bbb_ccc_lnk",3,"parent_key","HK_RTJJ_25_CCC","CHAR(28)"],
		["rvlt_test_jj","rtjj_25_aaa_hub",2,"key","HK_RTJJ_25_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_25_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"],
		["rvlt_test_jj","rtjj_25_aaa_p1_sat",2,"parent_key","HK_RTJJ_25_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_25_aaa_p1_sat",3,"diff_hash","RH_RTJJ_25_AAA_P1_SAT","CHAR(28)"],
		["rvlt_test_jj","rtjj_25_aaa_p1_sat",8,"content","F4_AAA_SP1_VARCHAR","VARCHAR(200)"],
		["rvlt_test_jj","rtjj_25_aaa_p1_sat",8,"content","F5_AAA_SP1_DECIMAL","DECIMAL(5,0)"],
		["rvlt_test_jj","rtjj_25_bbb_hub",2,"key","HK_RTJJ_25_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_25_bbb_hub",8,"business_key","F2_BK_BBB_DECIMAL","DECIMAL(20,0)"],
		["rvlt_test_jj","rtjj_25_ccc_hub",2,"key","HK_RTJJ_25_CCC","CHAR(28)"],
		["rvlt_test_jj","rtjj_25_ccc_hub",8,"business_key","F3_BK_CCC_DECIMAL","DECIMAL(20,0)"]
],
 "stage_table_column": [
		["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
		["F2_BK_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_BK_BBB_DECIMAL","DECIMAL(20,0)",false],
		["F3_BK_CCC_DECIMAL","DECIMAL(20,0)",8,"F3_BK_CCC_DECIMAL","DECIMAL(20,0)",false],
		["F4_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F4_AAA_SP1_VARCHAR","VARCHAR(200)",false],
		["F5_AAA_SP1_DECIMAL","DECIMAL(5,0)",8,"F5_AAA_SP1_DECIMAL","DECIMAL(5,0)",false],
		["HK_RTJJ_25_AAA","CHAR(28)",2,null,null,false],
		["HK_RTJJ_25_BBB","CHAR(28)",2,null,null,false],
		["HK_RTJJ_25_CCC","CHAR(28)",2,null,null,false],
		["LK_RTJJ_25_AAA_BBB_CCC","CHAR(28)",2,null,null,false],
		["RH_RTJJ_25_AAA_P1_SAT","CHAR(28)",3,null,null,false]
]
}');                                                                                                              

