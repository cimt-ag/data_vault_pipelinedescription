/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test50_double_esat_field_group';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES('test50_double_esat_field_group', '{
	"dvpd_version": "1.0",
	"pipeline_name": "test50_double_esat_field_group",
	"record_source_name_expression":"dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		{"field_name": "F1_BK_1",			"technical_type": "Varchar(20)",  "field_position": "1", "uniqueness_groups": ["key"],
								"targets": [{"table_name": "rtjj_50_aaa_hub"},
									        {"table_name": "rtkk_50_bbb_hub"}]}

 		,{"field_name": "F2_BK_AAA_XXBADNAMEXX",	"technical_type": "Decimal(10,0)", "field_position": "2","uniqueness_groups": ["key"],
								"targets": [{"table_name": "rtjj_50_aaa_hub","target_column_name": "F2_BK_AAA_2"}]}

		,{"field_name": "F3_AAA_SP1",	"technical_type": "Varchar(20)",	"field_position": "6",
								"targets": [{"table_name": "rtjj_50_aaa_p1_sat"}]}
 		
		,{"field_name": "F4_AAA_SP1",	"technical_type": "DECIMAL(12,2)",	"field_position": "7",	
								"targets": [{"table_name": "rtjj_50_aaa_p1_sat"}]}

		,{"field_name": "F5_AAA_SP1",		"technical_type": "VARCHAR(10)",	"field_position": "8",	
								"targets": [{"table_name": "rtjj_50_aaa_p1_sat"}]}

		,{"field_name": "F6_AAA_SP1_EXCLUDED_FROM_DIFF",	"technical_type": "TIMESTAMP",		"field_position": "9",	
								"targets": [{"table_name": "rtjj_50_aaa_p1_sat","exclude_from_diff_hash": "true"}]}

		,{"field_name": "F7_BK_BBB_2_L1",		"technical_type": "DECIMAL(10,0)", "field_position": "3",
								"targets": [{"table_name": "rtkk_50_bbb_hub","target_column_name": "F7_BK_BBB_2","field_groups": ["fg1"]}]}

		,{"field_name": "F8_BK_BBB_2_L2",	"technical_type": "DECIMAL(10,0)",	"field_position": "4",
								"targets": [{"table_name": "rtkk_50_bbb_hub","target_column_name": "F7_BK_BBB_2","field_groups": ["fg2"]}]}

		,{"field_name": "F9_BBB_SP1_L1",		"technical_type": "VARCHAR(200)", "field_position": "5",
								"targets": [{"table_name": "rtkk_50_bbb_p1_sat","field_groups": ["fg1"]}]}

	],
	"data_vault_model": [{
		"schema_name": "rvlt_test_jj",
			"tables": [
				{"table_name": "rtjj_50_aaa_hub",	"stereotype": "hub","hub_key_column_name": "HK_rtjj_50_aaa"}
 				,{"table_name": "rtjj_50_aaa_p1_sat","stereotype": "sat","satellite_parent_table": "rtjj_50_aaa_hub","diff_hash_column_name": "RH_rtjj_50_aaa_p1_sat"}
				,{"table_name": "rtjj_50_aaa_rtjkk_bbb_lnk","stereotype": "lnk","link_key_column_name": "LK_rtjj_50_aaa_rtjkk_bbb"
																	,	"link_parent_tables": ["rtjj_50_aaa_hub","rtkk_50_bbb_hub"]}
				,{"table_name": "rtjj_50_aaa_rtjkk_bbb_g1_esat","stereotype": "esat","satellite_parent_table": "rtjj_50_aaa_rtjkk_bbb_lnk",
																		"tracked_field_groups": ["fg1"],
																		"driving_hub_keys": ["HK_rtjj_50_aaa"]}
				,{"table_name": "rtjj_50_aaa_rtjkk_bbb_g2_esat","stereotype": "esat","satellite_parent_table": "rtjj_50_aaa_rtjkk_bbb_lnk",
																		"tracked_field_groups": ["fg2"],
																		"driving_hub_keys": ["HK_rtjj_50_aaa"]}
			]
		},
		{"schema_name": "rvlt_test_kk",
			"tables": [
				{"table_name": "rtkk_50_bbb_hub",		 "stereotype": "hub","hub_key_column_name": "HK_rtkk_50_bbb","tracked_field_groups": ["fg1","fg2"]}
				,{"table_name": "rtkk_50_bbb_p1_sat",	 "stereotype": "sat","satellite_parent_table": "rtkk_50_bbb_hub"
																		,"diff_hash_column_name": "rh_rtkk_50_bbb_p1_sat"}
			]
		}
	]
}');