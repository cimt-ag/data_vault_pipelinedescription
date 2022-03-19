
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test00_check_stereotype_and_parameters';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test00_check_stereotype_and_parameters','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test00_check_stereotype_and_parameters",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      	{"field_name": "F1_BK_AAA_VARCHAR", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_00_AAA_XXX_BAD_STEREOTYPE"}]}
		 	  ,	{"field_name": "F2_BK_BBB_DECIMAL",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_00_BBB_XXX_HUB_WITHOUT_HUB_KEY_COLUMN"}]}
			  ,	{"field_name": "F3_CCC_SP1_DECIMAL",	"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_00_CCC_XXX_SAT_WITHOUT_PARENT_DECLARATION"}]}
		      , {"field_name": "F4_BK_FFF_VARCHAR", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_00_FFF_HUB"}]}
		      , {"field_name": "F5_BK_GGG_VARCHAR", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_00_GGG_HUB"}]}
		      , {"field_name": "F6_DC_FFF_GGG_XXX_DLINK_VARCHAR", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_00_FFF_GGG_XXX_DLNK_WITHOUT_LINK_KEY_COLUMN"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_00_AAA_XXX_BAD_STEREOTYPE",		"stereotype": "xx","hub_key_column_name": "HK_rtjj_00_AAA_XXX_BAD_STEREOTYPE"}
			,	{"table_name": "rtjj_00_BBB_XXX_HUB_WITHOUT_HUB_KEY_COLUMN",		"stereotype": "hub"}
			,	{"table_name": "rtjj_00_CCC_XXX_SAT_WITHOUT_PARENT_DECLARATION",	"stereotype": "sat","diff_hash_column_name": "rtjj_00_XX_SAT_WITHOUT_PARENT"}
			,	{"table_name": "rtjj_00_DDD_EEE_XXX_LNK_WITHOUT_PARENT_DECLARATION", "stereotype": "lnk","link_key_column_name": "LK_rtjj_00_DDD_EEE_XXX_LINK_WITHOUT_PARENT_DECLARATION"}
			,	{"table_name": "rtjj_00_FFF_HUB",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_00_FFF_HUB"}
			,	{"table_name": "rtjj_00_GGG_HUB",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_00_GGG_HUB"}
			,	{"table_name": "rtjj_00_FFF_GGG_XXX_LNK_WITHOUT_LINK_KEY_COLUMN", "stereotype": "lnk","link_parent_tables":["rvlt_test_jj","rtjj_00_FFF_HUB","rtjj_00_GGG_HUB"]}
			,	{"table_name": "rtjj_00_FFF_GGG_XXX_DLNK_WITHOUT_LINK_KEY_COLUMN", "stereotype": "lnk","link_parent_tables":["rvlt_test_jj","rtjj_00_FFF_HUB","rtjj_00_GGG_HUB"]}
			,	{"table_name": "rtjj_00_FFF_GGG_LNK", "stereotype": "lnk","link_key_column_name": "LK_rtjj_00_FFF_GGG","link_parent_tables":["rvlt_test_jj","rtjj_00_FFF_HUB","rtjj_00_GGG_HUB"]}
			,	{"table_name": "rtjj_00_FFF_GGG_XXX_ESAT_WITHOUT_PARENT", "stereotype": "esat"}
				]
		}
	]
}
');