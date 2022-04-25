
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test01_check_model_relations';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test01_check_model_relations','{
	"dvpd_version": "1.0",
	"pipeline_name": "test01_check_model_relations",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      	{"field_name": "F1_BK_AAA_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_01_AAA_HUB"}]}
		 	  ,	{"field_name": "F2_BK_BBB_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_01_BBB_HUB"}]}
			  ,	{"field_name": "F3_CCC_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_01_CCC_XXX_SAT_WITH_UNKNOWN_PARENT"}]}
		      , {"field_name": "F4_DC_FFF_GGG_XXX_DLINK_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_01_AAA_CCC_XXX_DLINK_WITH_UNKNOWN_PARENT"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_01_AAA_HUB",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_01_AAA_HUB"}
			,	{"table_name": "rtjj_01_BBB_HUB",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_01_BBB_HUB"}
			,	{"table_name": "rtjj_01_CCC_XXX_SAT_WITH_UNKNOWN_PARENT",	"stereotype": "sat","satellite_parent_table":"rtjj_01_CCC_XXX_UNKNOWN_HUB","diff_hash_column_name": "rh_rtjj_01_CCC_XXX_SAT_WITH_UNKNOWN_PARENT"}
			,	{"table_name": "rtjj_01_AAA_CCC_XXX_LINK_WITH_UNKNOWN_PARENT", "stereotype": "lnk",	"link_key_column_name": "LK_rtjj_01_AAA_CCC_XXX_LINK_WITH_UNKNOWN_PARENT",
																									"link_parent_tables":["rvlt_test_jj","rtjj_01_AAA_HUB","rtjj_01_CCC_XXX_UNKNOWN_HUB"]}
			,	{"table_name": "rtjj_01_AAA_CCC_XXX_DLINK_WITH_UNKNOWN_PARENT", "stereotype": "lnk","link_key_column_name": "rtjj_01_AAA_CCC_XXX_DLINK_WITH_UNKNOWN_PARENT",
																									"link_parent_tables":["rvlt_test_jj","rtjj_01_AAA_HUB","rtjj_01_CCC_XXX_UNKNOWN_HUB"]}
			,	{"table_name": "rtjj_01_BBB_CCC_XXX_ESAT_WITH_UNKNOWN_PARENT", "stereotype": "esat","satellite_parent_table":"rtjj_01_CCC_XXX_UNKNOWN_HUB"}
			,	{"table_name": "rtjj_01_AAA_EEE_DONT_USE_AS_PARENT",	"stereotype": "sat","satellite_parent_table":"rtjj_01_AAA_HUB","diff_hash_column_name": "rh_rtjj_01_AAA_EEE_DONT_USE_AS_PARENT"}
			,	{"table_name": "rtjj_01_FFF_XXX_SAT_WITH_BAD_PARENT",	"stereotype": "sat","satellite_parent_table":"rtjj_01_AAA_EEE_DONT_USE_AS_PARENT","diff_hash_column_name": "rh_rtjj_01_FFF_XXX_SAT_WITH_BAD_PARENT"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test01_check_model_relations');