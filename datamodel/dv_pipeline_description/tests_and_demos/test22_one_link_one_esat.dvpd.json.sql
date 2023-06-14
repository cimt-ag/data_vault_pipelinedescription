{
	"dvpd_version": "1.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test22_one_link_one_esat",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 	"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_22_aaa_hub"}]}
		 	  ,{"field_name": "F2_BK_BBB_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtkk_22_bbb_hub"}]}
		 	  ,{"field_name": "F3_AAA_SP1_VARCHAR",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_22_aaa_p1_sat"}]}
			  ,{"field_name": "F4_AAA_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_22_aaa_p1_sat"}]}
			  ,{"field_name": "F5__FIELD_NAME",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_22_aaa_p1_sat",
																									 "target_column_name":"F5_AAA_SP1_VARCHAR"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_22_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_22_aaa"}
				,{"table_name": "rtjj_22_aaa_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_22_aaa_HUB","diff_hash_column_name": "RH_rtjj_22_aaa_P1_SAT"}
				,{"table_name": "rtjj_22_aaa_bbb_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rtjj_22_aaa_bbb",
																				"link_parent_tables": ["rtjj_22_aaa_hub","rtkk_22_bbb_hub"]}
				,{"table_name": "rtjj_22_aaa_bbb_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_22_aaa_bbb_lnk"}
				]
		},
		{"schema_name": "rvlt_test_kk", 
		 "tables": [
				{"table_name": "rtkk_22_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtkk_22_bbb"}
		]
	}]
}