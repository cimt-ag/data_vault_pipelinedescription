
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test22_encrypt_on_all_stereotypes';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test22_encrypt_on_all_stereotypes','{
	"dvpd_version": "1.0",
	"pipeline_name": "xenc_test22_encrypt_on_all_stereotypes",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_ENCRYPT_ME", 	"field_type": "Varchar(20)", "needs_encryption":true
														,"targets": [{"table_name": "rxecd_22_aaa_hub"}]}
		 	  ,{"field_name": "F2_BK_BBB_DECIMAL",		"field_type": "Decimal(20,0)"
														,"targets": [{"table_name": "rxecd_22_bbb_hub"}]}
		 	  ,{"field_name": "F3_AAA_SP1_VARCHAR"	,		"field_type": "VARCHAR(200)"
														,"targets": [{"table_name": "rxecd_22_aaa_sat"}]}
		 	  ,{"field_name": "F4_AAA_SP1_ENCRYPT_ME",	"field_type": "VARCHAR(200)", "needs_encryption":true
														,"targets": [{"table_name": "rxecd_22_aaa_sat"}]}
		 	  ,{"field_name": "F5_DC_AAA_BBB_ENCRYPT_ME",	"field_type": "Decimal(20,0)",	"needs_encryption":true
														,"targets": [{"table_name": "rxecd_22_aaa_bbb_lnk"}]}
			  ,{"field_name": "F6_AAA_BBB_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)"
														,"targets": [{"table_name": "rxecd_22_aaa_bbb_sat"}]}
			  ,{"field_name": "F7_AAA_BBB_SP1_ENCRYPT_ME",	"field_type": "DECIMAL(5,0)", "needs_encryption":true
														,"targets": [{"table_name": "rxecd_22_aaa_bbb_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_xenc_data", 
		 "tables": [
				{"table_name": "rxecd_22_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rxecd_22_aaa"}
				,{"table_name": "rxecd_22_aaa_sat",		"stereotype": "sat","satellite_parent_table": "rxecd_22_aaa_hub","diff_hash_column_name": "RH_rxecd_22_aaa_sat"}
				,{"table_name": "rxecd_22_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rxecd_22_bbb"}
				,{"table_name": "rxecd_22_aaa_bbb_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rxecd_22_aaa_bbb",
																			"link_parent_tables": ["rxecd_22_aaa_hub","rxecd_22_bbb_hub"]}
				,{"table_name": "rxecd_22_aaa_bbb_sat",	"stereotype": "sat","satellite_parent_table": "rxecd_22_aaa_bbb_lnk","diff_hash_column_name": "RH_rxecd_22_aaa_bbb_sat"}
				]
		}
		,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{"table_name": "rxeck_22_aaa_hub_ek",		"stereotype": "xenc_hub-ek", "xenc_content_table_name":"rxecd_22_aaa_hub"}
				,{"table_name": "rxeck_22_aaa_sat_ek",	"stereotype": "xenc_sat-ek", "xenc_content_table_name":"rxecd_22_aaa_sat"}
				,{"table_name": "rxeck_22_aaa_bbb_lnk_ek",	"stereotype": "xenc_lnk-ek", "xenc_content_table_name":"rxecd_22_aaa_bbb_lnk"}
				,{"table_name": "rxeck_22_aaa_bbb_sat_ek",	"stereotype": "xenc_sat-ek", "xenc_content_table_name":"rxecd_22_aaa_bbb_sat"}
				]
		}
	]
}

');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test22_encrypt_on_all_stereotypes');
select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test22_encrypt_on_all_stereotypes');
