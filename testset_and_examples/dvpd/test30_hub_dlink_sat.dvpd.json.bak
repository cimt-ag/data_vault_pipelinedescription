{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test30_hub_dlink_sat",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_30_aaa_hub"}]},
		 	  {"field_name": "F2_BK_AAA_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_30_aaa_hub"}]},
		 	  {"field_name": "F3_DC_AAA_DDD_VARCHAR",		"field_type": "DATE",			"targets": [{"table_name": "rtjj_30_aaa_ddd_dlnk"}]},
			  {"field_name": "F4_AAA_DDD_SP1_DECIMAL",		"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_30_aaa_ddd_p1_sat"}]},
			  {"field_name": "F5_AAA_DDD_SP1_DECIMAL",		"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_30_aaa_ddd_p1_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_30_aaa_hub",		"table_stereotype": "hub",			"hub_key_column_name": "HK_rtjj_30_aaa"},
				{"table_name": "rtjj_30_aaa_ddd_dlnk",		"table_stereotype": "lnk",	"link_key_column_name": "LK_rtjj_30_aaa_ddd",
																 				"link_parent_tables":["rtjj_30_aaa_hub"]},
				{"table_name": "rtjj_30_aaa_ddd_p1_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_30_aaa_ddd_dlnk","diff_hash_column_name": "RH_rtjj_30_aaa_ddd_p1_sat"}
				]
		}
	]
}
