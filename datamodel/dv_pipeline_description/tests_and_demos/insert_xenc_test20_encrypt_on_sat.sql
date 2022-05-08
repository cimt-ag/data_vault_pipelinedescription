
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test20_encrypt_on_sat';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test20_encrypt_on_sat','{
	"dvpd_version": "1.0",
	"pipeline_name": "xenc_test20_encrypt_on_sat",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_ENCRYPT_ME", 	"field_type": "Varchar(20)"
														,"targets": [{"table_name": "rxecd_20_aaa_hub"}]}
		 	  ,{"field_name": "F2_AAA_SP1_VARCHAR"	,		"field_type": "VARCHAR(200)"
														,"targets": [{"table_name": "rxecd_20_aaa_sat"}]}
		 	  ,{"field_name": "F3_AAA_SP1_ENCRYPT_ME",	"field_type": "VARCHAR(200)", "needs_encryption":true
														,"targets": [{"table_name": "rxecd_20_aaa_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_xenc_data", 
		 "tables": [
				{"table_name": "rxecd_20_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rxecd_20_aaa"}
				,{"table_name": "rxecd_20_aaa_sat",		"stereotype": "sat","satellite_parent_table": "rxecd_20_aaa_hub","diff_hash_column_name": "RH_rxecd_20_aaa_sat"}
				]
		}
		,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{"table_name": "rxeck_20_aaa_sat_ek",	"stereotype": "xenc_sat-ek", "xenc_content_table_name":"rxecd_20_aaa_sat"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test20_encrypt_on_sat');
select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test20_encrypt_on_sat');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'xenc_test20_encrypt_on_sat';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('xenc_test20_encrypt_on_sat','{
	"dv_model_column": [
		["rvlt_test_jj","rxecd_20_aaa_bbb_lnk",2,"key","LK_rxecd_20_AAA_BBB","CHAR(28)"],
		["rvlt_test_jj","rxecd_20_aaa_bbb_lnk",3,"parent_key","HK_rxecd_20_AAA","CHAR(28)"],
		["rvlt_test_jj","rxecd_20_aaa_bbb_lnk",3,"parent_key","HK_rxecd_20_BBB","CHAR(28)"],
		["rvlt_test_jj","rxecd_20_aaa_bbb_sat",2,"parent_key","LK_rxecd_20_AAA_BBB","CHAR(28)"],
		["rvlt_test_jj","rxecd_20_aaa_bbb_sat",3,"diff_hash","RH_rxecd_20_AAA_BBB_SAT","CHAR(28)"],
		["rvlt_test_jj","rxecd_20_aaa_bbb_sat",8,"content","F3_AAA_SP1_VARCHAR","VARCHAR(200)"],
		["rvlt_test_jj","rxecd_20_aaa_bbb_sat",8,"content","F4_AAA_SP1_DECIMAL","DECIMAL(5,0)"],
		["rvlt_test_jj","rxecd_20_aaa_bbb_sat",8,"content","F5_AAA_SP1_VARCHAR","VARCHAR(200)"],
		["rvlt_test_jj","rxecd_20_aaa_hub",2,"key","HK_rxecd_20_AAA","CHAR(28)"],
		["rvlt_test_jj","rxecd_20_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"],
		["rvlt_test_jj","rxecd_20_bbb_hub",2,"key","HK_rxecd_20_BBB","CHAR(28)"],
		["rvlt_test_jj","rxecd_20_bbb_hub",8,"business_key","F2_BK_BBB_DECIMAL","DECIMAL(20,0)"]
],
  "process_column_mapping": [
         ["rxecd_20_aaa_bbb_lnk","_A_","LK_rxecd_20_AAA_BBB","LK_rxecd_20_AAA_BBB",null],
         ["rxecd_20_aaa_bbb_lnk","_A_","HK_rxecd_20_AAA","HK_rxecd_20_AAA",null],
         ["rxecd_20_aaa_bbb_lnk","_A_","HK_rxecd_20_BBB","HK_rxecd_20_BBB",null],
         ["rxecd_20_aaa_bbb_sat","_A_","LK_rxecd_20_AAA_BBB","LK_rxecd_20_AAA_BBB",null],
         ["rxecd_20_aaa_bbb_sat","_A_","RH_rxecd_20_AAA_BBB_SAT","RH_rxecd_20_AAA_BBB_SAT",null],
         ["rxecd_20_aaa_bbb_sat","_A_","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR"],
         ["rxecd_20_aaa_bbb_sat","_A_","F4_AAA_SP1_DECIMAL","F4_AAA_SP1_DECIMAL","F4_AAA_SP1_DECIMAL"],
         ["rxecd_20_aaa_bbb_sat","_A_","F5_AAA_SP1_VARCHAR","F5__FIELD_NAME","F5__FIELD_NAME"],
         ["rxecd_20_aaa_hub","_A_","HK_rxecd_20_AAA","HK_rxecd_20_AAA",null],
         ["rxecd_20_aaa_hub","_A_","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR"],
         ["rxecd_20_bbb_hub","_A_","HK_rxecd_20_BBB","HK_rxecd_20_BBB",null],
         ["rxecd_20_bbb_hub","_A_","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL"]
 ],
"stage_table_column": [
		["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
		["F2_BK_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_BK_BBB_DECIMAL","DECIMAL(20,0)",false],
		["F3_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F3_AAA_SP1_VARCHAR","VARCHAR(200)",false],
		["F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",8,"F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",false],
		["F5__FIELD_NAME","VARCHAR(200)",8,"F5__FIELD_NAME","VARCHAR(200)",false],
		["HK_rxecd_20_AAA","CHAR(28)",2,null,null,false],
		["HK_rxecd_20_BBB","CHAR(28)",2,null,null,false],
		["LK_rxecd_20_AAA_BBB","CHAR(28)",2,null,null,false],
		["RH_rxecd_20_AAA_BBB_SAT","CHAR(28)",3,null,null,false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_rxecd_20_AAA","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","HK_rxecd_20_BBB","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","LK_rxecd_20_AAA_BBB","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","LK_rxecd_20_AAA_BBB","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","RH_rxecd_20_AAA_BBB_SAT","F3_AAA_SP1_VARCHAR",0,0],
         ["_A_","RH_rxecd_20_AAA_BBB_SAT","F4_AAA_SP1_DECIMAL",0,0],
         ["_A_","RH_rxecd_20_AAA_BBB_SAT","F5__FIELD_NAME",0,0]
  ]    }');                                                                                                             

