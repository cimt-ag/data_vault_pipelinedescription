
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test00_bad_properties';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test00_bad_properties','{
	"dvpd_version": "1.0",
	"pipeline_name": "xenc_test00_bad_properties",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_ENCRYPT_ME", 	"field_type": "Varchar(20)", "needs_encryption":true
														,"targets": [{"table_name": "rxecd_00_aaa_hub"}]}
		 	  ,{"field_name": "F2_AAA_SP1_VARCHAR"	,		"field_type": "VARCHAR(200)"
														,"targets": [{"table_name": "rxecd_00_aaa_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_xenc_data", 
		 "tables": [
				{"table_name": "rxecd_00_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rxecd_00_aaa"}
				,{"table_name": "rxecd_00_aaa_sat",		"stereotype": "sat","satellite_parent_table": "rxecd_00_aaa_hub","diff_hash_column_name": "RH_rxecd_00_aaa_sat"}
				]
		}
		,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{	"stereotype": "xenc_sat-ek", "xenc_content_table_name":"rxecd_xxxnot_existingxxx"}
				,{"table_name": "rxecd_00_content_not_declared_ek",	"stereotype": "xenc_sat-ek"}
				,{"table_name": "rxecd_00_bad_stereotype",	"stereotype": "xenc_baaad"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test00_bad_properties');
select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test00_bad_properties');
