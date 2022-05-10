/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test61_fgs1_enc_on_sat';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test61_fgs1_enc_on_sat','{
	"dvpd_version": "1.0",
	"pipeline_name": "xenc_test61_fgs1_enc_on_sat",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_L1", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rxecd_61_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg1"]}]}
		      ,{"field_name": "F2_BK_AAA_L2", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rxecd_61_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg2"]}]}		 	  
		      ,{"field_name": "F3_BK_AAA_L3", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rxecd_61_aaa_hub"
																					,"target_column_name": "BK_AAA"
																				 	,"field_groups":["fg3"]}]}		 	  
		      ,{"field_name": "F4_AAA_S1_COLA","field_type": "Varchar(20)",	"targets": [{"table_name": "rxecd_61_aaa_p1_sat"
																				 	,"field_groups":["fg1"]}]}		 
		      ,{"field_name": "F5_AAA_S1_COLB","field_type": "Varchar(20)",	"needs_encryption":true, "targets": [{"table_name": "rxecd_61_aaa_p1_sat"
																				 	,"field_groups":["fg1"]}]}		 
		      ,{"field_name": "F6_AAA_S1_COLA_L2","field_type": "Varchar(20)",	"targets": [{"table_name": "rxecd_61_aaa_p1_sat"
																					,"target_column_name": "F4_AAA_S1_COLA"
																				 	,"field_groups":["fg2"]}]}		 
		      ,{"field_name": "F7_AAA_S1_COLB_L2","field_type": "Varchar(20)",	"needs_encryption":true, "targets": [{"table_name": "rxecd_61_aaa_p1_sat"
																					,"target_column_name": "F5_AAA_S1_COLB"
																				 	,"field_groups":["fg2"]}]}		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rxecd_61_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rxecd_61_aaa"}
				,{"table_name": "rxecd_61_aaa_p1_sat",	"stereotype": "sat","satellite_parent_table": "rxecd_61_aaa_hub"
																			,"diff_hash_column_name": "RH_rxecd_61_aaa_p1_sat"}
				]
		}
		,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{"table_name": "rxeck_61_aaa_sat_ek",	"stereotype": "xenc_sat-ek", "xenc_content_table_name":"rxecd_61_aaa_p1_sat"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test61_fgs1_enc_on_sat');
select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test61_fgs1_enc_on_sat');



select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test61_fgs1_enc_on_sat');
select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test61_fgs1_enc_on_sat');

