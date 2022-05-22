/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test76_fg_enc_on_lsat_and_hub';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test76_fg_enc_on_lsat_and_hub','{
	"dvpd_version": "1.0",
	"pipeline_name": "xenc_test76_fg_enc_on_lsat_and_hub",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_L1", 		"field_type": "Varchar(20)", "needs_encryption":true,	"targets": [{"table_name": "rxecd_76_aaa_hub"
																					,"target_column_name": "BK_AAA_EC"
																				 	,"field_groups":["fg1"]}]}
		      ,{"field_name": "F2_BK_AAA_L2", 		"field_type": "Varchar(20)", "needs_encryption":true,	"targets": [{"table_name": "rxecd_76_aaa_hub"
																					,"target_column_name": "BK_AAA_EC"
																				 	,"field_groups":["fg2"]}]}		 	  
		      ,{"field_name": "F3_BK_BBB", 		"field_type": "Varchar(20)",  "needs_encryption":true,	"targets": [{"table_name": "rxecd_76_bbb_hub"}]}		 
		      ,{"field_name": "F4_AAA_BBB_S1_COLA_L1","field_type": "Varchar(20)", "needs_encryption":true
											,	"targets": [{"table_name": "rxecd_76_aaa_bbb_sat","target_column_name": "F4_AAA_BBB_S1_COLA_EC","field_groups":["fg1"]}]}		 
		      ,{"field_name": "F4_AAA_BBB_S1_COLA_L2","field_type": "Varchar(20)", "needs_encryption":true
											,	"targets": [{"table_name": "rxecd_76_aaa_bbb_sat","target_column_name": "F4_AAA_BBB_S1_COLA_EC","field_groups":["fg2"]}]}		 
		      ,{"field_name": "F5_AAA_BBB_S1_COLB","field_type": "Varchar(20)",	"targets": [{"table_name": "rxecd_76_aaa_bbb_sat","field_groups":["fg1"]}]}		 		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_xenc_data", 
		 "tables": [
				{"table_name": "rxecd_76_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rxecd_76_aaa"}
				,{"table_name": "rxecd_76_aaa_bbb_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rxecd_76_aaa_bbb",
																				"link_parent_tables": ["rxecd_76_aaa_hub","rxecd_76_bbb_hub"]}
				,{"table_name": "rxecd_76_aaa_bbb_sat",	"stereotype": "sat","satellite_parent_table": "rxecd_76_aaa_bbb_lnk"
																				,"diff_hash_column_name": "RH_rxecd_76_aaa_bbb_sat"}
				,{"table_name": "rxecd_76_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rxecd_76_bbb"}
				]
		}
	,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{"table_name": "rxeck_76_aaa_hub_ek",	"stereotype": "xenc_hub-ek", "xenc_content_table_name":"rxecd_76_aaa_hub"}
				,{"table_name": "rxeck_76_aaa_bbb_sat_ek",	"stereotype": "xenc_sat-ek", "xenc_content_table_name":"rxecd_76_aaa_bbb_sat"}
				,{"table_name": "rxeck_76_bbb_hub_ek",	"stereotype": "xenc_hub-ek", "xenc_content_table_name":"rxecd_76_bbb_hub"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test76_fg_enc_on_lsat_and_hub');
select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test76_fg_enc_on_lsat_and_hub');

-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'xenc_test76_fg_enc_on_lsat_and_hub';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('xenc_test76_fg_enc_on_lsat_and_hub','{
 "dv_model_column": [
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_lnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_lnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_lnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_lnk",2,"key","LK_RXECD_76_AAA_BBB","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_lnk",3,"parent_key","HK_RXECD_76_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_lnk",3,"parent_key","HK_RXECD_76_BBB","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_sat",2,"parent_key","LK_RXECD_76_AAA_BBB","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_sat",3,"diff_hash","RH_RXECD_76_AAA_BBB_SAT","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_sat",6,"xenc_encryption_key_index","EKI_RXECD_76_AAA_BBB_SAT","INT8"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_sat",8,"content","F4_AAA_BBB_S1_COLA_EC","VARCHAR(20)"],
      ["rvlt_xenc_data","rxecd_76_aaa_bbb_sat",8,"content","F5_AAA_BBB_S1_COLB","VARCHAR(20)"],
      ["rvlt_xenc_data","rxecd_76_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_76_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_76_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_76_aaa_hub",2,"key","HK_RXECD_76_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_76_aaa_hub",8,"business_key","BK_AAA_EC","VARCHAR(20)"],
      ["rvlt_xenc_data","rxecd_76_bbb_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_76_bbb_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_76_bbb_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_76_bbb_hub",2,"key","HK_RXECD_76_BBB","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_76_bbb_hub",8,"business_key","F3_BK_BBB","VARCHAR(20)"],
      ["rvlt_xenc_keys","rxeck_76_aaa_bbb_sat_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_76_aaa_bbb_sat_ek",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_xenc_keys","rxeck_76_aaa_bbb_sat_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_76_aaa_bbb_sat_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_76_aaa_bbb_sat_ek",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_76_aaa_bbb_sat_ek",2,"key","LK_RXECD_76_AAA_BBB","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_76_aaa_bbb_sat_ek",3,"diff_hash","RH_RXECD_76_AAA_BBB_SAT","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_76_aaa_bbb_sat_ek",5,"xenc_encryption_key","EK_RXECD_76_AAA_BBB_SAT","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_76_aaa_bbb_sat_ek",6,"xenc_encryption_key_index","EKI_RXECD_76_AAA_BBB_SAT","INT8"],
      ["rvlt_xenc_keys","rxeck_76_aaa_hub_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_76_aaa_hub_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_76_aaa_hub_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_76_aaa_hub_ek",2,"key","HK_RXECD_76_AAA","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_76_aaa_hub_ek",5,"xenc_encryption_key","EK_RXECD_76_AAA_HUB","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_76_aaa_hub_ek",7,"xenc_bk_hash","BKH_RXECK_76_AAA_HUB_EK","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_76_aaa_hub_ek",7,"xenc_bk_salted_hash","BKH_RXECK_76_AAA_HUB_EK_ST","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_76_bbb_hub_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_76_bbb_hub_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_76_bbb_hub_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_76_bbb_hub_ek",2,"key","HK_RXECD_76_BBB","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_76_bbb_hub_ek",5,"xenc_encryption_key","EK_RXECD_76_BBB_HUB","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_76_bbb_hub_ek",7,"xenc_bk_hash","BKH_RXECK_76_BBB_HUB_EK","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_76_bbb_hub_ek",7,"xenc_bk_salted_hash","BKH_RXECK_76_BBB_HUB_EK_ST","CHAR(28)"]
 ],
 "process_column_mapping": [
         ["rxecd_76_aaa_bbb_lnk","_FG1","LK_RXECD_76_AAA_BBB","LK_RXECD_76_AAA_BBB_FG1",null],
         ["rxecd_76_aaa_bbb_lnk","_FG1","HK_RXECD_76_AAA","HK_RXECD_76_AAA_FG1",null],
         ["rxecd_76_aaa_bbb_lnk","_FG1","HK_RXECD_76_BBB","HK_RXECD_76_BBB",null],
         ["rxecd_76_aaa_bbb_lnk","_FG2","LK_RXECD_76_AAA_BBB","LK_RXECD_76_AAA_BBB_FG2",null],
         ["rxecd_76_aaa_bbb_lnk","_FG2","HK_RXECD_76_AAA","HK_RXECD_76_AAA_FG2",null],
         ["rxecd_76_aaa_bbb_lnk","_FG2","HK_RXECD_76_BBB","HK_RXECD_76_BBB",null],
         ["rxecd_76_aaa_bbb_sat","_FG1","LK_RXECD_76_AAA_BBB","LK_RXECD_76_AAA_BBB_FG1",null],
         ["rxecd_76_aaa_bbb_sat","_FG1","RH_RXECD_76_AAA_BBB_SAT","RH_RXECD_76_AAA_BBB_SAT_FG1",null],
         ["rxecd_76_aaa_bbb_sat","_FG1","EKI_RXECD_76_AAA_BBB_SAT","EKI_RXECD_76_AAA_BBB_SAT_FG1",null],
         ["rxecd_76_aaa_bbb_sat","_FG1","F4_AAA_BBB_S1_COLA_EC","F4_AAA_BBB_S1_COLA_L1","F4_AAA_BBB_S1_COLA_L1"],
         ["rxecd_76_aaa_bbb_sat","_FG1","F5_AAA_BBB_S1_COLB","F5_AAA_BBB_S1_COLB","F5_AAA_BBB_S1_COLB"],
         ["rxecd_76_aaa_bbb_sat","_FG2","LK_RXECD_76_AAA_BBB","LK_RXECD_76_AAA_BBB_FG2",null],
         ["rxecd_76_aaa_bbb_sat","_FG2","RH_RXECD_76_AAA_BBB_SAT","RH_RXECD_76_AAA_BBB_SAT_FG2",null],
         ["rxecd_76_aaa_bbb_sat","_FG2","EKI_RXECD_76_AAA_BBB_SAT","EKI_RXECD_76_AAA_BBB_SAT_FG2",null],
         ["rxecd_76_aaa_bbb_sat","_FG2","F4_AAA_BBB_S1_COLA_EC","F4_AAA_BBB_S1_COLA_L2","F4_AAA_BBB_S1_COLA_L2"],
         ["rxecd_76_aaa_hub","_FG1","HK_RXECD_76_AAA","HK_RXECD_76_AAA_FG1",null],
         ["rxecd_76_aaa_hub","_FG1","BK_AAA_EC","F1_BK_AAA_L1","F1_BK_AAA_L1"],
         ["rxecd_76_aaa_hub","_FG2","HK_RXECD_76_AAA","HK_RXECD_76_AAA_FG2",null],
         ["rxecd_76_aaa_hub","_FG2","BK_AAA_EC","F2_BK_AAA_L2","F2_BK_AAA_L2"],
         ["rxecd_76_bbb_hub","_A_","HK_RXECD_76_BBB","HK_RXECD_76_BBB",null],
         ["rxecd_76_bbb_hub","_A_","F3_BK_BBB","F3_BK_BBB","F3_BK_BBB"]
 ],
 "stage_table_column": [
         ["HK_RXECD_76_AAA_FG1","CHAR(28)",2,null,null,false],
         ["HK_RXECD_76_AAA_FG2","CHAR(28)",2,null,null,false],
         ["HK_RXECD_76_BBB","CHAR(28)",2,null,null,false],
         ["LK_RXECD_76_AAA_BBB_FG1","CHAR(28)",2,null,null,false],
         ["LK_RXECD_76_AAA_BBB_FG2","CHAR(28)",2,null,null,false],
         ["RH_RXECD_76_AAA_BBB_SAT_FG1","CHAR(28)",3,null,null,false],
         ["RH_RXECD_76_AAA_BBB_SAT_FG2","CHAR(28)",3,null,null,false],
         ["EKI_RXECD_76_AAA_BBB_SAT_FG1","INT8",6,null,null,false],
         ["EKI_RXECD_76_AAA_BBB_SAT_FG2","INT8",6,null,null,false],
         ["F1_BK_AAA_L1","VARCHAR(20)",8,"F1_BK_AAA_L1","VARCHAR(20)",true],
         ["F2_BK_AAA_L2","VARCHAR(20)",8,"F2_BK_AAA_L2","VARCHAR(20)",true],
         ["F3_BK_BBB","VARCHAR(20)",8,"F3_BK_BBB","VARCHAR(20)",true],
         ["F4_AAA_BBB_S1_COLA_L1","VARCHAR(20)",8,"F4_AAA_BBB_S1_COLA_L1","VARCHAR(20)",true],
         ["F4_AAA_BBB_S1_COLA_L2","VARCHAR(20)",8,"F4_AAA_BBB_S1_COLA_L2","VARCHAR(20)",true],
         ["F5_AAA_BBB_S1_COLB","VARCHAR(20)",8,"F5_AAA_BBB_S1_COLB","VARCHAR(20)",false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RXECD_76_BBB","F3_BK_BBB",0,0],
         ["_FG1","HK_RXECD_76_AAA_FG1","F1_BK_AAA_L1",0,0],
         ["_FG1","LK_RXECD_76_AAA_BBB_FG1","F1_BK_AAA_L1",0,0],
         ["_FG1","LK_RXECD_76_AAA_BBB_FG1","F3_BK_BBB",0,0],
         ["_FG1","RH_RXECD_76_AAA_BBB_SAT_FG1","F4_AAA_BBB_S1_COLA_L1",0,0],
         ["_FG1","RH_RXECD_76_AAA_BBB_SAT_FG1","F5_AAA_BBB_S1_COLB",0,0],
         ["_FG2","HK_RXECD_76_AAA_FG2","F2_BK_AAA_L2",0,0],
         ["_FG2","LK_RXECD_76_AAA_BBB_FG2","F2_BK_AAA_L2",0,0],
         ["_FG2","LK_RXECD_76_AAA_BBB_FG2","F3_BK_BBB",0,0],
         ["_FG2","RH_RXECD_76_AAA_BBB_SAT_FG2","F4_AAA_BBB_S1_COLA_L2",0,0]
 ],
 "xenc_process_column_mapping": [
         ["rxeck_76_aaa_bbb_sat_ek","_FG1","LK_RXECD_76_AAA_BBB","CHAR(28)","key","LK_RXECD_76_AAA_BBB_FG1","LK_RXECD_76_AAA_BBB_FG1","rxecd_76_aaa_bbb_sat"],
         ["rxeck_76_aaa_bbb_sat_ek","_FG1","RH_RXECD_76_AAA_BBB_SAT","CHAR(28)","diff_hash","RH_RXECD_76_AAA_BBB_SAT_FG1","RH_RXECD_76_AAA_BBB_SAT_FG1","rxecd_76_aaa_bbb_sat"],
         ["rxeck_76_aaa_bbb_sat_ek","_FG1","EK_RXECD_76_AAA_BBB_SAT","CHAR(28)","xenc_encryption_key","EK_RXECD_76_AAA_BBB_SAT_FG1",null,null],
         ["rxeck_76_aaa_bbb_sat_ek","_FG1","EKI_RXECD_76_AAA_BBB_SAT","INT8","xenc_encryption_key_index","EKI_RXECD_76_AAA_BBB_SAT",null,null],
         ["rxeck_76_aaa_bbb_sat_ek","_FG2","LK_RXECD_76_AAA_BBB","CHAR(28)","key","LK_RXECD_76_AAA_BBB_FG2","LK_RXECD_76_AAA_BBB_FG2","rxecd_76_aaa_bbb_sat"],
         ["rxeck_76_aaa_bbb_sat_ek","_FG2","RH_RXECD_76_AAA_BBB_SAT","CHAR(28)","diff_hash","RH_RXECD_76_AAA_BBB_SAT_FG2","RH_RXECD_76_AAA_BBB_SAT_FG2","rxecd_76_aaa_bbb_sat"],
         ["rxeck_76_aaa_bbb_sat_ek","_FG2","EK_RXECD_76_AAA_BBB_SAT","CHAR(28)","xenc_encryption_key","EK_RXECD_76_AAA_BBB_SAT_FG2",null,null],
         ["rxeck_76_aaa_bbb_sat_ek","_FG2","EKI_RXECD_76_AAA_BBB_SAT","INT8","xenc_encryption_key_index","EKI_RXECD_76_AAA_BBB_SAT",null,null],
         ["rxeck_76_aaa_hub_ek","_FG1","HK_RXECD_76_AAA","CHAR(28)","key","HK_RXECD_76_AAA_FG1","HK_RXECD_76_AAA_FG1","rxecd_76_aaa_hub"],
         ["rxeck_76_aaa_hub_ek","_FG1","EK_RXECD_76_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_76_AAA_HUB_FG1",null,null],
         ["rxeck_76_aaa_hub_ek","_FG1","BKH_RXECK_76_AAA_HUB_EK","CHAR(28)","xenc_bk_hash","BKH_RXECK_76_AAA_HUB_EK_FG1","HK_RXECD_76_AAA_FG1","rxecd_76_aaa_hub"],
         ["rxeck_76_aaa_hub_ek","_FG1","BKH_RXECK_76_AAA_HUB_EK_ST","CHAR(28)","xenc_bk_salted_hash","BKH_RXECK_76_AAA_HUB_EK_ST_FG1","HK_RXECD_76_AAA_FG1","rxecd_76_aaa_hub"],
         ["rxeck_76_aaa_hub_ek","_FG2","HK_RXECD_76_AAA","CHAR(28)","key","HK_RXECD_76_AAA_FG2","HK_RXECD_76_AAA_FG2","rxecd_76_aaa_hub"],
         ["rxeck_76_aaa_hub_ek","_FG2","EK_RXECD_76_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_76_AAA_HUB_FG2",null,null],
         ["rxeck_76_aaa_hub_ek","_FG2","BKH_RXECK_76_AAA_HUB_EK","CHAR(28)","xenc_bk_hash","BKH_RXECK_76_AAA_HUB_EK_FG2","HK_RXECD_76_AAA_FG2","rxecd_76_aaa_hub"],
         ["rxeck_76_aaa_hub_ek","_FG2","BKH_RXECK_76_AAA_HUB_EK_ST","CHAR(28)","xenc_bk_salted_hash","BKH_RXECK_76_AAA_HUB_EK_ST_FG2","HK_RXECD_76_AAA_FG2","rxecd_76_aaa_hub"],
         ["rxeck_76_bbb_hub_ek","_A_","HK_RXECD_76_BBB","CHAR(28)","key","HK_RXECD_76_BBB","HK_RXECD_76_BBB","rxecd_76_bbb_hub"],
         ["rxeck_76_bbb_hub_ek","_A_","EK_RXECD_76_BBB_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_76_BBB_HUB",null,null],
         ["rxeck_76_bbb_hub_ek","_A_","BKH_RXECK_76_BBB_HUB_EK","CHAR(28)","xenc_bk_hash","BKH_RXECK_76_BBB_HUB_EK","HK_RXECD_76_BBB","rxecd_76_bbb_hub"],
         ["rxeck_76_bbb_hub_ek","_A_","BKH_RXECK_76_BBB_HUB_EK_ST","CHAR(28)","xenc_bk_salted_hash","BKH_RXECK_76_BBB_HUB_EK_ST","HK_RXECD_76_BBB","rxecd_76_bbb_hub"]
 ],
 "xenc_process_field_to_encryption_key_mapping": [
         ["_A_","F3_BK_BBB","F3_BK_BBB","EK_RXECD_76_BBB_HUB",1],
         ["_FG1","F1_BK_AAA_L1","F1_BK_AAA_L1","EK_RXECD_76_AAA_HUB_FG1",1],
         ["_FG1","F4_AAA_BBB_S1_COLA_L1","F4_AAA_BBB_S1_COLA_L1","EK_RXECD_76_AAA_BBB_SAT_FG1",1],
         ["_FG2","F2_BK_AAA_L2","F2_BK_AAA_L2","EK_RXECD_76_AAA_HUB_FG2",1],
         ["_FG2","F4_AAA_BBB_S1_COLA_L2","F4_AAA_BBB_S1_COLA_L2","EK_RXECD_76_AAA_BBB_SAT_FG2",1]
  ]    }');