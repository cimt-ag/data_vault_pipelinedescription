
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

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'xenc_test22_encrypt_on_all_stereotypes';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('xenc_test22_encrypt_on_all_stereotypes','{
 "dv_model_column": [
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_lnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_lnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_lnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_lnk",2,"key","LK_RXECD_22_AAA_BBB","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_lnk",3,"parent_key","HK_RXECD_22_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_lnk",3,"parent_key","HK_RXECD_22_BBB","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_lnk",8,"dependent_child_key","F5_DC_AAA_BBB_ENCRYPT_ME","DECIMAL(20,0)"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_sat",2,"parent_key","LK_RXECD_22_AAA_BBB","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_sat",3,"diff_hash","RH_RXECD_22_AAA_BBB_SAT","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_sat",6,"xenc_encryption_key_index","EKI_RXECD_22_AAA_BBB_SAT","INT8"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_sat",8,"content","F6_AAA_BBB_SP1_DECIMAL","DECIMAL(5,0)"],
      ["rvlt_xenc_data","rxecd_22_aaa_bbb_sat",8,"content","F7_AAA_BBB_SP1_ENCRYPT_ME","DECIMAL(5,0)"],
      ["rvlt_xenc_data","rxecd_22_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_22_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_22_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_22_aaa_hub",2,"key","HK_RXECD_22_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_22_aaa_hub",8,"business_key","F1_BK_AAA_ENCRYPT_ME","VARCHAR(20)"],
      ["rvlt_xenc_data","rxecd_22_aaa_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_22_aaa_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_xenc_data","rxecd_22_aaa_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_22_aaa_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_22_aaa_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_22_aaa_sat",2,"parent_key","HK_RXECD_22_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_22_aaa_sat",3,"diff_hash","RH_RXECD_22_AAA_SAT","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_22_aaa_sat",6,"xenc_encryption_key_index","EKI_RXECD_22_AAA_SAT","INT8"],
      ["rvlt_xenc_data","rxecd_22_aaa_sat",8,"content","F3_AAA_SP1_VARCHAR","VARCHAR(200)"],
      ["rvlt_xenc_data","rxecd_22_aaa_sat",8,"content","F4_AAA_SP1_ENCRYPT_ME","VARCHAR(200)"],
      ["rvlt_xenc_data","rxecd_22_bbb_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_22_bbb_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_22_bbb_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_22_bbb_hub",2,"key","HK_RXECD_22_BBB","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_22_bbb_hub",8,"business_key","F2_BK_BBB_DECIMAL","DECIMAL(20,0)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_lnk_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_lnk_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_lnk_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_lnk_ek",2,"key","LK_RXECD_22_AAA_BBB","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_lnk_ek",5,"xenc_encryption_key","EK_RXECD_22_AAA_BBB_LNK","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_lnk_ek",7,"xenc_dc_hash","DCH_RXECK_22_AAA_BBB_LNK_EK","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_lnk_ek",7,"xenc_dc_salted_hash","DCH_RXECK_22_AAA_BBB_LNK_EK_ST","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_sat_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_sat_ek",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_sat_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_sat_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_sat_ek",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_sat_ek",2,"key","LK_RXECD_22_AAA_BBB","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_sat_ek",3,"diff_hash","RH_RXECD_22_AAA_BBB_SAT","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_sat_ek",5,"xenc_encryption_key","EK_RXECD_22_AAA_BBB_SAT","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_bbb_sat_ek",6,"xenc_encryption_key_index","EKI_RXECD_22_AAA_BBB_SAT","INT8"],
      ["rvlt_xenc_keys","rxeck_22_aaa_hub_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_22_aaa_hub_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_22_aaa_hub_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_hub_ek",2,"key","HK_RXECD_22_AAA","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_hub_ek",5,"xenc_encryption_key","EK_RXECD_22_AAA_HUB","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_hub_ek",7,"xenc_bk_hash","BKH_RXECK_22_AAA_HUB_EK","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_hub_ek",7,"xenc_bk_salted_hash","BKH_RXECK_22_AAA_HUB_EK_ST","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_sat_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_22_aaa_sat_ek",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_xenc_keys","rxeck_22_aaa_sat_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_22_aaa_sat_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_sat_ek",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_22_aaa_sat_ek",2,"key","HK_RXECD_22_AAA","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_sat_ek",3,"diff_hash","RH_RXECD_22_AAA_SAT","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_sat_ek",5,"xenc_encryption_key","EK_RXECD_22_AAA_SAT","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_22_aaa_sat_ek",6,"xenc_encryption_key_index","EKI_RXECD_22_AAA_SAT","INT8"]
 ],
 "process_column_mapping": [
         ["rxecd_22_aaa_bbb_lnk","_A_","LK_RXECD_22_AAA_BBB","LK_RXECD_22_AAA_BBB",null],
         ["rxecd_22_aaa_bbb_lnk","_A_","HK_RXECD_22_AAA","HK_RXECD_22_AAA",null],
         ["rxecd_22_aaa_bbb_lnk","_A_","HK_RXECD_22_BBB","HK_RXECD_22_BBB",null],
         ["rxecd_22_aaa_bbb_lnk","_A_","F5_DC_AAA_BBB_ENCRYPT_ME","F5_DC_AAA_BBB_ENCRYPT_ME","F5_DC_AAA_BBB_ENCRYPT_ME"],
         ["rxecd_22_aaa_bbb_sat","_A_","LK_RXECD_22_AAA_BBB","LK_RXECD_22_AAA_BBB",null],
         ["rxecd_22_aaa_bbb_sat","_A_","RH_RXECD_22_AAA_BBB_SAT","RH_RXECD_22_AAA_BBB_SAT",null],
         ["rxecd_22_aaa_bbb_sat","_A_","EKI_RXECD_22_AAA_BBB_SAT","EKI_RXECD_22_AAA_BBB_SAT",null],
         ["rxecd_22_aaa_bbb_sat","_A_","F6_AAA_BBB_SP1_DECIMAL","F6_AAA_BBB_SP1_DECIMAL","F6_AAA_BBB_SP1_DECIMAL"],
         ["rxecd_22_aaa_bbb_sat","_A_","F7_AAA_BBB_SP1_ENCRYPT_ME","F7_AAA_BBB_SP1_ENCRYPT_ME","F7_AAA_BBB_SP1_ENCRYPT_ME"],
         ["rxecd_22_aaa_hub","_A_","HK_RXECD_22_AAA","HK_RXECD_22_AAA",null],
         ["rxecd_22_aaa_hub","_A_","F1_BK_AAA_ENCRYPT_ME","F1_BK_AAA_ENCRYPT_ME","F1_BK_AAA_ENCRYPT_ME"],
         ["rxecd_22_aaa_sat","_A_","HK_RXECD_22_AAA","HK_RXECD_22_AAA",null],
         ["rxecd_22_aaa_sat","_A_","RH_RXECD_22_AAA_SAT","RH_RXECD_22_AAA_SAT",null],
         ["rxecd_22_aaa_sat","_A_","EKI_RXECD_22_AAA_SAT","EKI_RXECD_22_AAA_SAT",null],
         ["rxecd_22_aaa_sat","_A_","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR"],
         ["rxecd_22_aaa_sat","_A_","F4_AAA_SP1_ENCRYPT_ME","F4_AAA_SP1_ENCRYPT_ME","F4_AAA_SP1_ENCRYPT_ME"],
         ["rxecd_22_bbb_hub","_A_","HK_RXECD_22_BBB","HK_RXECD_22_BBB",null],
         ["rxecd_22_bbb_hub","_A_","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL"]
 ],
 "stage_table_column": [
         ["HK_RXECD_22_AAA","CHAR(28)",2,null,null,false],
         ["HK_RXECD_22_BBB","CHAR(28)",2,null,null,false],
         ["LK_RXECD_22_AAA_BBB","CHAR(28)",2,null,null,false],
         ["RH_RXECD_22_AAA_BBB_SAT","CHAR(28)",3,null,null,false],
         ["RH_RXECD_22_AAA_SAT","CHAR(28)",3,null,null,false],
         ["EKI_RXECD_22_AAA_BBB_SAT","INT8",6,null,null,false],
         ["EKI_RXECD_22_AAA_SAT","INT8",6,null,null,false],
         ["F1_BK_AAA_ENCRYPT_ME","VARCHAR(20)",8,"F1_BK_AAA_ENCRYPT_ME","VARCHAR(20)",false],
         ["F2_BK_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_BK_BBB_DECIMAL","DECIMAL(20,0)",false],
         ["F3_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F3_AAA_SP1_VARCHAR","VARCHAR(200)",false],
         ["F4_AAA_SP1_ENCRYPT_ME","VARCHAR(200)",8,"F4_AAA_SP1_ENCRYPT_ME","VARCHAR(200)",false],
         ["F5_DC_AAA_BBB_ENCRYPT_ME","DECIMAL(20,0)",8,"F5_DC_AAA_BBB_ENCRYPT_ME","DECIMAL(20,0)",false],
         ["F6_AAA_BBB_SP1_DECIMAL","DECIMAL(5,0)",8,"F6_AAA_BBB_SP1_DECIMAL","DECIMAL(5,0)",false],
         ["F7_AAA_BBB_SP1_ENCRYPT_ME","DECIMAL(5,0)",8,"F7_AAA_BBB_SP1_ENCRYPT_ME","DECIMAL(5,0)",false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RXECD_22_AAA","F1_BK_AAA_ENCRYPT_ME",0,0],
         ["_A_","HK_RXECD_22_BBB","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","LK_RXECD_22_AAA_BBB","F1_BK_AAA_ENCRYPT_ME",0,0],
         ["_A_","LK_RXECD_22_AAA_BBB","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","LK_RXECD_22_AAA_BBB","F5_DC_AAA_BBB_ENCRYPT_ME",0,0],
         ["_A_","RH_RXECD_22_AAA_BBB_SAT","F6_AAA_BBB_SP1_DECIMAL",0,0],
         ["_A_","RH_RXECD_22_AAA_BBB_SAT","F7_AAA_BBB_SP1_ENCRYPT_ME",0,0],
         ["_A_","RH_RXECD_22_AAA_SAT","F3_AAA_SP1_VARCHAR",0,0],
         ["_A_","RH_RXECD_22_AAA_SAT","F4_AAA_SP1_ENCRYPT_ME",0,0]
 ],
 "xenc_process_column_mapping": [
         ["rxeck_22_aaa_bbb_lnk_ek","_A_","LK_RXECD_22_AAA_BBB","CHAR(28)","key","LK_RXECD_22_AAA_BBB","LK_RXECD_22_AAA_BBB","rxecd_22_aaa_bbb_lnk"],
         ["rxeck_22_aaa_bbb_lnk_ek","_A_","EK_RXECD_22_AAA_BBB_LNK","CHAR(28)","xenc_encryption_key","EK_RXECD_22_AAA_BBB_LNK",null,null],
         ["rxeck_22_aaa_bbb_lnk_ek","_A_","DCH_RXECK_22_AAA_BBB_LNK_EK","CHAR(28)","xenc_dc_hash","DCH_RXECK_22_AAA_BBB_LNK_EK","LK_RXECD_22_AAA_BBB","rxecd_22_aaa_bbb_lnk"],
         ["rxeck_22_aaa_bbb_lnk_ek","_A_","DCH_RXECK_22_AAA_BBB_LNK_EK_ST","CHAR(28)","xenc_dc_salted_hash","DCH_RXECK_22_AAA_BBB_LNK_EK_ST","LK_RXECD_22_AAA_BBB","rxecd_22_aaa_bbb_lnk"],
         ["rxeck_22_aaa_bbb_sat_ek","_A_","LK_RXECD_22_AAA_BBB","CHAR(28)","key","LK_RXECD_22_AAA_BBB","LK_RXECD_22_AAA_BBB","rxecd_22_aaa_bbb_sat"],
         ["rxeck_22_aaa_bbb_sat_ek","_A_","RH_RXECD_22_AAA_BBB_SAT","CHAR(28)","diff_hash","RH_RXECD_22_AAA_BBB_SAT","RH_RXECD_22_AAA_BBB_SAT","rxecd_22_aaa_bbb_sat"],
         ["rxeck_22_aaa_bbb_sat_ek","_A_","EK_RXECD_22_AAA_BBB_SAT","CHAR(28)","xenc_encryption_key","EK_RXECD_22_AAA_BBB_SAT",null,null],
         ["rxeck_22_aaa_bbb_sat_ek","_A_","EKI_RXECD_22_AAA_BBB_SAT","INT8","xenc_encryption_key_index","EKI_RXECD_22_AAA_BBB_SAT",null,null],
         ["rxeck_22_aaa_hub_ek","_A_","HK_RXECD_22_AAA","CHAR(28)","key","HK_RXECD_22_AAA","HK_RXECD_22_AAA","rxecd_22_aaa_hub"],
         ["rxeck_22_aaa_hub_ek","_A_","EK_RXECD_22_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_22_AAA_HUB",null,null],
         ["rxeck_22_aaa_hub_ek","_A_","BKH_RXECK_22_AAA_HUB_EK","CHAR(28)","xenc_bk_hash","BKH_RXECK_22_AAA_HUB_EK","HK_RXECD_22_AAA","rxecd_22_aaa_hub"],
         ["rxeck_22_aaa_hub_ek","_A_","BKH_RXECK_22_AAA_HUB_EK_ST","CHAR(28)","xenc_bk_salted_hash","BKH_RXECK_22_AAA_HUB_EK_ST","HK_RXECD_22_AAA","rxecd_22_aaa_hub"],
         ["rxeck_22_aaa_sat_ek","_A_","HK_RXECD_22_AAA","CHAR(28)","key","HK_RXECD_22_AAA","HK_RXECD_22_AAA","rxecd_22_aaa_sat"],
         ["rxeck_22_aaa_sat_ek","_A_","RH_RXECD_22_AAA_SAT","CHAR(28)","diff_hash","RH_RXECD_22_AAA_SAT","RH_RXECD_22_AAA_SAT","rxecd_22_aaa_sat"],
         ["rxeck_22_aaa_sat_ek","_A_","EK_RXECD_22_AAA_SAT","CHAR(28)","xenc_encryption_key","EK_RXECD_22_AAA_SAT",null,null],
         ["rxeck_22_aaa_sat_ek","_A_","EKI_RXECD_22_AAA_SAT","INT8","xenc_encryption_key_index","EKI_RXECD_22_AAA_SAT",null,null]
  ]    }');