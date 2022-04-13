DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test25_one_link_one_esat_three_hubs';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test25_one_link_one_esat_three_hubs','{
	"dvpd_version": "1.0",
	"pipeline_name": "test25_one_link_one_esat_three_hubs",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 	"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_25_aaa_hub"}]}
		 	  ,{"field_name": "F2_BK_BBB_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_25_bbb_hub"}]}
		 	  ,{"field_name": "F3_BK_CCC_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_25_ccc_hub"}]}
		 	  ,{"field_name": "F4_AAA_SP1_VARCHAR",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_25_aaa_p1_sat"}]}
			  ,{"field_name": "F5_AAA_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_25_aaa_p1_sat"}]}
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

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test25_one_link_one_esat_three_hubs');

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
 "process_column_mapping": [
         ["rtjj_25_aaa_bbb_ccc_esat","_A_","LK_RTJJ_25_AAA_BBB_CCC","LK_RTJJ_25_AAA_BBB_CCC",null],
         ["rtjj_25_aaa_bbb_ccc_lnk","_A_","LK_RTJJ_25_AAA_BBB_CCC","LK_RTJJ_25_AAA_BBB_CCC",null],
         ["rtjj_25_aaa_bbb_ccc_lnk","_A_","HK_RTJJ_25_AAA","HK_RTJJ_25_AAA",null],
         ["rtjj_25_aaa_bbb_ccc_lnk","_A_","HK_RTJJ_25_BBB","HK_RTJJ_25_BBB",null],
         ["rtjj_25_aaa_bbb_ccc_lnk","_A_","HK_RTJJ_25_CCC","HK_RTJJ_25_CCC",null],
         ["rtjj_25_aaa_hub","_A_","HK_RTJJ_25_AAA","HK_RTJJ_25_AAA",null],
         ["rtjj_25_aaa_hub","_A_","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR"],
         ["rtjj_25_aaa_p1_sat","_A_","HK_RTJJ_25_AAA","HK_RTJJ_25_AAA",null],
         ["rtjj_25_aaa_p1_sat","_A_","RH_RTJJ_25_AAA_P1_SAT","RH_RTJJ_25_AAA_P1_SAT",null],
         ["rtjj_25_aaa_p1_sat","_A_","F4_AAA_SP1_VARCHAR","F4_AAA_SP1_VARCHAR","F4_AAA_SP1_VARCHAR"],
         ["rtjj_25_aaa_p1_sat","_A_","F5_AAA_SP1_DECIMAL","F5_AAA_SP1_DECIMAL","F5_AAA_SP1_DECIMAL"],
         ["rtjj_25_bbb_hub","_A_","HK_RTJJ_25_BBB","HK_RTJJ_25_BBB",null],
         ["rtjj_25_bbb_hub","_A_","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL"],
         ["rtjj_25_ccc_hub","_A_","HK_RTJJ_25_CCC","HK_RTJJ_25_CCC",null],
         ["rtjj_25_ccc_hub","_A_","F3_BK_CCC_DECIMAL","F3_BK_CCC_DECIMAL","F3_BK_CCC_DECIMAL"]
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
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_25_AAA","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","HK_RTJJ_25_BBB","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","HK_RTJJ_25_CCC","F3_BK_CCC_DECIMAL",0,0],
         ["_A_","LK_RTJJ_25_AAA_BBB_CCC","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","LK_RTJJ_25_AAA_BBB_CCC","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","LK_RTJJ_25_AAA_BBB_CCC","F3_BK_CCC_DECIMAL",0,0],
         ["_A_","RH_RTJJ_25_AAA_P1_SAT","F4_AAA_SP1_VARCHAR",0,0],
         ["_A_","RH_RTJJ_25_AAA_P1_SAT","F5_AAA_SP1_DECIMAL",0,0]
  ]    }');
