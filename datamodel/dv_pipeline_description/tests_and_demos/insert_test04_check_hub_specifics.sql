
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test04_check_hub_specifics';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test04_check_hub_specifics','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test04_check_hub_specifics",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		 	  {"field_name": "F1_AAA_SP1_VARCHAR",		"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_04_aaa_p1_sat"}]},
			  {"field_name": "F2_AAA_SP1_DECIMAL",	"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_04_aaa_p1_sat"}]},
			  {"field_name": "F3_XXX_BAD_NAME_XXX",	"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_04_aaa_p1_sat",
																									 "target_column_name":"F3_AAA_SP1_VARCHAR"}]},
			  {"field_name": "F4_AAA_SP1_TIMESTAMP_XRH",	"technical_type": "TIMESTAMP",		"targets": [{"table_name": "rtjj_04_aaa_p1_sat","exclude_from_diff_hash": "true"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_04_aaa_xxxx_no_bk_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_04_aaa"},
				{"table_name": "rtjj_04_aaa_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_04_aaa_xxxx_no_bk_hub","diff_hash_column_name": "RH_rtjj_04_aaa_P1_SAT"}
				]
		}
	]
}
');
