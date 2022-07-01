/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test22a_one_link_one_esat_new_notation';

INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test22a_one_link_one_esat_new_notation','{
	"dvpd_version": "1.0",
	"pipeline_name": "test22a_one_link_one_esat_new_notation",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"main_schema_name": "rvlt_test_jj",

	"fields": {
		       "F1_BK_AAA_VARCHAR": {"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_22a_aaa_hub"}]}
		 	  ,"F2_BK_BBB_DECIMAL": {"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_22a_bbb_hub"}]}
		 	  ,"F3_AAA_SP1_VARCHAR":{"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_22a_aaa_p1_sat"}]}
			  ,"F4_AAA_SP1_DECIMAL":{"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_22a_aaa_p1_sat"}]}
			  ,"F5__FIELD_NAME":	{"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_22a_aaa_p1_sat",
																									 "target_column_name":"F5_AAA_SP1_VARCHAR"}]}
			 },
	"data_vault_model": {
				"rtjj_22a_aaa_hub": 	{"stereotype": "hub","hub_key_column_name": "HK_rtjj_22a_aaa"}
				,"rtjj_22a_aaa_p1_sat": {"stereotype": "sat","satellite_parent_table": "rtjj_22a_aaa_HUB","diff_hash_column_name": "RH_rtjj_22a_aaa_P1_SAT"}
				,"rtkk_22a_bbb_hub": 	{"stereotype": "hub","schema_name": "rvlt_test_kk","hub_key_column_name": "HK_rtkk_22a_bbb"}
				,"rtjj_22a_aaa_bbb_lnk":{"stereotype": "lnk","link_key_column_name": "LK_rtjj_22a_aaa_bbb",
																				"link_parent_tables": ["rtjj_22a_aaa_hub","rtkk_22a_bbb_hub"]}
				,"rtjj_22a_aaa_bbb_esat":{"stereotype": "esat","satellite_parent_table": "rtjj_22a_aaa_bbb_lnk"}
	}
}
');

--select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test22a_one_link_one_esat');
