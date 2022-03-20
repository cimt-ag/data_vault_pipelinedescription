/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test80_hierarchical_link';
INSERT INTO dv_pipeline_description.dvpd_dictionary 
(pipeline_name, dvpd_json)
VALUES
('test80_hierarchical_link','{
 	"DVPD_Version": "1.0",
 	"pipeline_name": "test80_hierarchical_link",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 	"fields": [
		{"field_name": "FI_ID",			"technical_type": "Varchar(20)",  "field_position": "1", "uniqueness_groups": ["key"],
									        "targets": [{"table_name": "rtsta_80_kunde_hub"}]},
		{"field_name": "KUNDE_NR",			"technical_type": "DECIMAL(10,0)","field_position": "3","targets": [{"table_name": "rtsta_80_kunde_hub"	}]},
		{"field_name": "MASTER_KUNDE_NR",	"technical_type": "DECIMAL(10,0)","field_position": "4","targets": [{"table_name": "rtsta_80_kunde_hub",
																								 			"target_column_name": "KUNDE_NR",
																								 			"hierarchy_key_suffix": "master"}]}
	],
 	"data_vault_model": [
		{"schema_name": "rvlt_test_a",
 		"tables": [
			{"table_name": "rtsta_80_kunde_hub",				"stereotype": "hub","hub_key_column_name": "HK_rtsta_80_KUNDE"},
			{"table_name": "rtsta_80_kunde_kunde_master_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rtsta_80_KUNDE_KUNDE_MASTER",
 																				 "link_parent_tables": ["rtsta_80_kunde_hub"],
																				 "hierarchical_parents": [ {"table_name":"rtsta_80_kunde_hub",
																											"hierarchy_key_suffix": "master"}]},

 			{"table_name": "rtsta_80_kunde_kunde_master_esat",	"stereotype": "esat","satellite_parent_table": "rtsta_80_kunde_kunde_master_lnk",
																			 				"driving_hub_keys": ["HK_rtsta_80_KUNDE"]}
 			]
 		}
	]
 }');
 

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test80_hierarchical_link';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test80_hierarchical_link','{
	"dv_model_column": [
		["rvlt_test_jj","rtjj_22_aaa_bbb_esat",2,"parent_key","LK_RTJJ_22_AAA_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_22_aaa_bbb_lnk",2,"key","LK_RTJJ_22_AAA_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_22_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_22_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_22_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_22_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_22_aaa_hub",2,"key","HK_RTJJ_22_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_22_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"],
		["rvlt_test_jj","rtjj_22_aaa_p1_sat",2,"parent_key","HK_RTJJ_22_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_22_aaa_p1_sat",3,"diff_hash","RH_RTJJ_22_AAA_P1_SAT","CHAR(28)"],
		["rvlt_test_jj","rtjj_22_aaa_p1_sat",8,"content","F3_AAA_SP1_VARCHAR","VARCHAR(200)"],
		["rvlt_test_jj","rtjj_22_aaa_p1_sat",8,"content","F4_AAA_SP1_DECIMAL","DECIMAL(5,0)"],
		["rvlt_test_jj","rtjj_22_aaa_p1_sat",8,"content","F5_AAA_SP1_VARCHAR","VARCHAR(200)"],
		["rvlt_test_jj","rtjj_22_bbb_hub",2,"key","HK_RTJJ_22_BBB","CHAR(28)"],
		["rvlt_test_jj","rtjj_22_bbb_hub",8,"business_key","F2_BK_BBB_DECIMAL","DECIMAL(20,0)"]
],
 "stage_table_column": [
		["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
		["F2_BK_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_BK_BBB_DECIMAL","DECIMAL(20,0)",false],
		["F3_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F3_AAA_SP1_VARCHAR","VARCHAR(200)",false],
		["F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",8,"F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",false],
		["F5_XXX_BAD_NAME_XXX","VARCHAR(200)",8,"F5_XXX_BAD_NAME_XXX","VARCHAR(200)",false],
		["HK_RTJJ_22_AAA","CHAR(28)",2,null,null,false],
		["HK_RTJJ_22_BBB","CHAR(28)",2,null,null,false],
		["LK_RTJJ_22_AAA_BBB","CHAR(28)",2,null,null,false],
		["RH_RTJJ_22_AAA_P1_SAT","CHAR(28)",3,null,null,false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTSTA_80_KUNDE","FI_ID",0,0],
         ["_A_","HK_RTSTA_80_KUNDE","KUNDE_NR",0,0],
         ["_A_","LK_RTSTA_80_KUNDE_KUNDE_MASTER","FI_ID",0,0],
         ["_A_","LK_RTSTA_80_KUNDE_KUNDE_MASTER","KUNDE_NR",0,0],
         ["_A_","LK_RTSTA_80_KUNDE_KUNDE_MASTER","MASTER_KUNDE_NR",0,0],
         ["_MASTER","HK_RTSTA_80_KUNDE__MASTER","MASTER_KUNDE_NR",0,0]
  ]    }'); 