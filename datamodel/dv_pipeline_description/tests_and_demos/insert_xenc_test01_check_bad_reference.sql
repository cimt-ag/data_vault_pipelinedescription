
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test01_check_bad_reference';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test01_check_bad_reference','{
	"dvpd_version": "1.0",
	"pipeline_name": "xenc_test01_check_bad_reference",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_ENCRYPT_ME", 	"field_type": "Varchar(20)", "needs_encryption":true
														,"targets": [{"table_name": "rxecd_01_aaa_hub"}]}
		 	  ,{"field_name": "F2_AAA_SP1_VARCHAR"	,		"field_type": "VARCHAR(200)"
														,"targets": [{"table_name": "rxecd_01_aaa_sat"}]}
		 	  ,{"field_name": "F3_AAA_SP1_VARCHAR",	"field_type": "VARCHAR(200)"
														,"targets": [{"table_name": "rxecd_01_aaa_no_encrpytion_sat"}]}
		 	  ,{"field_name": "F4_AAA_SP2_ENCRYPT_ME",	"field_type": "VARCHAR(200)", "needs_encryption":true
														,"targets": [{"table_name": "rxecd_01_aaa_p2_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_xenc_data", 
		 "tables": [
				{"table_name": "rxecd_01_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rxecd_01_aaa"}
				,{"table_name": "rxecd_01_aaa_no_encrpytion_sat",		"stereotype": "sat","satellite_parent_table": "rxecd_01_aaa_hub","diff_hash_column_name": "RH_rxecd_01_aaa_no_encrpytion_sat"}
				,{"table_name": "rxecd_01_aaa_p2_sat",		"stereotype": "sat","satellite_parent_table": "rxecd_01_aaa_hub","diff_hash_column_name": "RH_rxecd_01_aaa_p2_sat"}
				]
		}
		,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{"table_name": "rxeck_01_bad_reference_ek",	"stereotype": "xenc_sat-ek", "xenc_content_table_name":"rxecd_xxxnot_existingxxx"}
				,{"table_name": "rxeck_01_no_encryption_ref_ek",	"stereotype": "xenc_sat-ek", "xenc_content_table_name":"rxecd_01_aaa_no_encrpytion_sat"}
				,{"table_name": "rxeck_01_1of2_ek",	"stereotype": "xenc_sat-ek", "xenc_content_table_name":"rxecd_01_aaa_p2_sat"}
				,{"table_name": "rxeck_01_2of2_ek",	"stereotype": "xenc_sat-ek", "xenc_content_table_name":"rxecd_01_aaa_p2_sat"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test01_check_bad_reference');
select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test01_check_bad_reference');
