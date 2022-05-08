
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test21_encrypt_on_hub';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test21_encrypt_on_hub','{
	"dvpd_version": "1.0",
	"pipeline_name": "xenc_test21_encrypt_on_hub",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_ENCRYPT_ME", 	"field_type": "Varchar(20)", "needs_encryption":true
														,"targets": [{"table_name": "rxecd_21_aaa_hub"}]}
		 	  ,{"field_name": "F2_BK_BBB_DECIMAL",		"field_type": "Decimal(20,0)"
														,"targets": [{"table_name": "rxecd_21_bbb_hub"}]}
		 	  ,{"field_name": "F3_AAA_SP1_VARCHAR"	,		"field_type": "VARCHAR(200)"
														,"targets": [{"table_name": "rxecd_21_aaa_sat"}]}
		 	  ,{"field_name": "F4_AAA_SP1_VARCHAR",	"field_type": "VARCHAR(200)"
														,"targets": [{"table_name": "rxecd_21_aaa_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_xenc_data", 
		 "tables": [
				{"table_name": "rxecd_21_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rxecd_21_aaa"}
				,{"table_name": "rxecd_21_aaa_sat",		"stereotype": "sat","satellite_parent_table": "rxecd_21_aaa_hub","diff_hash_column_name": "RH_rxecd_21_aaa_sat"}
				,{"table_name": "rxecd_21_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rxecd_21_bbb"}
				,{"table_name": "rxecd_21_aaa_bbb_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rxecd_21_aaa_bbb",
																			"link_parent_tables": ["rxecd_21_aaa_hub","rxecd_21_bbb_hub"]}
				]
		}
		,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{"table_name": "rxeck_21_aaa_hub_ek",		"stereotype": "xenc_hub-ek", "xenc_content_table_name":"rxecd_21_aaa_hub"}
				]
		}
	]
}

');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test21_encrypt_on_hub');
select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test21_encrypt_on_hub');

