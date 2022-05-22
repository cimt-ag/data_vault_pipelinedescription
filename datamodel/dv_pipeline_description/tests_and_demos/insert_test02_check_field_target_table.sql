
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test02_check_field_target_table';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test02_check_field_target_table','{
	"dvpd_version": "1.0",
	"pipeline_name": "test02_check_field_target_table",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      	{"field_name": "F1_XXX_MAPPED_TO_UNKNOWN_TABLE", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_02_XXX_UNKNOWN_HUB"}]}
		 	  ,	{"field_name": "F2_BK_BBB_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_02_BBB_HUB"}]}
		 	  ,	{"field_name": "F3_BK_BBB_NOT_CONSISTENT",	"field_type": "different",	"targets": [{"table_name": "rtjj_02_BBB_HUB", "target_column_name":"F2_BK_BBB_DECIMAL"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_02_BBB_HUB",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_02_BBB_HUB"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test02_check_field_target_table');