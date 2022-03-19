/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test05_one_link_one_esat';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test05_one_link_one_esat','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test05_one_link_one_esat",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 	"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_05_aaa_hub"}]}
		 	  ,{"field_name": "F2_BK_BBB_DECIMAL",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_05_bbb_hub"}]}
		 	  ,{"field_name": "F3_AAA_SP1_VARCHAR",	"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_05_aaa_p1_sat"}]}
			  ,{"field_name": "F4_AAA_SP1_DECIMAL",	"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_05_aaa_p1_sat"}]}
			  ,{"field_name": "F5_XXX_BAD_NAME_XXX",	"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_05_aaa_p1_sat",
																									 "target_column_name":"F5_AAA_SP1_VARCHAR"}]}
		 	  ,{"field_name": "F6_BK_CCC_DECIMAL",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_05_ccc_hub"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_05_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_05_aaa"}
				,{"table_name": "rtjj_05_aaa_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_05_aaa_HUB","diff_hash_column_name": "RH_rtjj_05_aaa_P1_SAT"}
				,{"table_name": "rtjj_05_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_05_bbb"}
				,{"table_name": "rtjj_05_ccc_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_05_bbb"}
				,{"table_name": "rtjj_05_aaa_bbb_XXX_with_same_lk_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rtjj_05_XXX_same_LK",
																				"link_parent_tables": ["rvlt_test_jj","rtjj_05_aaa_hub","rtjj_05_bbb_hub"]}
				,{"table_name": "rtjj_05_aaa_bbb_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_05_aaa_bbb_XXX_with_same_lk_lnk"}
				,{"table_name": "rtjj_05_aaa_ccc_XXX_with_same_lk_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rtjj_05_XXX_same_LK",
																				"link_parent_tables": ["rvlt_test_jj","rtjj_05_aaa_hub","rtjj_05_ccc_hub"]}
				,{"table_name": "rtjj_05_aaa_ccc_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_05_aaa_ccc_XXX_with_same_lk_lnk"}
				]
		}
	]
}
');

                                                                   

