
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test04_check_hub_specifics';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test04_check_hub_specifics','{
	"dvpd_version": "1.0",
	"pipeline_name": "test04_check_hub_specifics",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		 	  {"field_name": "F5_BK_BBB_VARCHAR",		"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_04_bbb_xxx_same_hk_hub"}]}
  		 	  ,{"field_name": "F6_BK_CCC_VARCHAR",		"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_04_ccc_xxx_same_hk_hub"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_04_aaa_xxx_no_bk_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_04_aaa"}
				,{"table_name": "rtjj_04_bbb_xxx_same_hk_hub",		"stereotype": "hub","hub_key_column_name": "HK_XXX_SAME_HK"}
				,{"table_name": "rtjj_04_ccc_xxx_same_hk_hub",		"stereotype": "hub","hub_key_column_name": "HK_XXX_SAME_HK"}
				]
		}
	]
}
');

select DVPD_LOAD_PIPELINE_TO_RAW('test04_check_hub_specifics');