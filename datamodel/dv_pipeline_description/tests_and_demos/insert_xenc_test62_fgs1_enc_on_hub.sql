-- =====================================================================
-- Part of the Data Vault Pipeline Description Reference Implementation
--
-- Copyright 2023 Matthias Wegner mattywausb@gmail.com
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =====================================================================

/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test62_fgs1_enc_on_hub';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test62_fgs1_enc_on_hub','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "xenc_test62_fgs1_enc_on_hub",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_L1", 	  "field_type": "Varchar(20)",	"needs_encryption":true,"targets": [{"table_name": "rxecd_62_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["R111"]}]}
		      ,{"field_name": "F2_BK_AAA_L2", 	  "field_type": "Varchar(20)",	"needs_encryption":true,"targets": [{"table_name": "rxecd_62_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["R222"]}]}		 	  
		      ,{"field_name": "F3_BK_AAA_L3", 	  "field_type": "Varchar(20)",	"needs_encryption":true,"targets": [{"table_name": "rxecd_62_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["R333"]}]}		 	  
		      ,{"field_name": "F4_AAA_S1_COLA","field_type": "Varchar(20)",	"targets": [{"table_name": "rxecd_62_aaa_p1_sat"
																				 	,"relation_names":["R111"]}]}		 
		      ,{"field_name": "F5_AAA_S1_COLB","field_type": "Varchar(20)",	 "targets": [{"table_name": "rxecd_62_aaa_p1_sat"
																				 	,"relation_names":["R111"]}]}		 
		      ,{"field_name": "F6_AAA_S1_COLA_L2","field_type": "Varchar(20)",	"targets": [{"table_name": "rxecd_62_aaa_p1_sat"
																					,"column_name": "F4_AAA_S1_COLA"
																				 	,"relation_names":["R222"]}]}		 
		      ,{"field_name": "F7_AAA_S1_COLB_L2","field_type": "Varchar(20)",	 "targets": [{"table_name": "rxecd_62_aaa_p1_sat"
																					,"column_name": "F5_AAA_S1_COLB"
																				 	,"relation_names":["R222"]}]}		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rxecd_62_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rxecd_62_aaa"}
				,{"table_name": "rxecd_62_aaa_p1_sat",	"table_stereotype": "sat","satellite_parent_table": "rxecd_62_aaa_hub"
																			,"diff_hash_column_name": "RH_rxecd_62_aaa_p1_sat"}
				]
		}
		,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{"table_name": "rxeck_62_aaa_hub_ek",	"table_stereotype": "xenc_hub-ek", "xenc_content_table_name":"rxecd_62_aaa_hub"}
				]
		}
	]
}
');

select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test62_fgs1_enc_on_hub');
select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test62_fgs1_enc_on_hub');


-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'xenc_test62_fgs1_enc_on_hub';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('xenc_test62_fgs1_enc_on_hub','{
 "dv_model_column": [
      ["rvlt_test_jj","rxecd_62_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rxecd_62_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rxecd_62_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rxecd_62_aaa_hub",2,"key","HK_RXECD_62_AAA","CHAR(28)"],
      ["rvlt_test_jj","rxecd_62_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"],
      ["rvlt_test_jj","rxecd_62_aaa_p1_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rxecd_62_aaa_p1_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rxecd_62_aaa_p1_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rxecd_62_aaa_p1_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rxecd_62_aaa_p1_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rxecd_62_aaa_p1_sat",2,"parent_key","HK_RXECD_62_AAA","CHAR(28)"],
      ["rvlt_test_jj","rxecd_62_aaa_p1_sat",3,"diff_hash","RH_RXECD_62_AAA_P1_SAT","CHAR(28)"],
      ["rvlt_test_jj","rxecd_62_aaa_p1_sat",8,"content","F4_AAA_S1_COLA","VARCHAR(20)"],
      ["rvlt_test_jj","rxecd_62_aaa_p1_sat",8,"content","F5_AAA_S1_COLB","VARCHAR(20)"],
      ["rvlt_xenc_keys","rxeck_62_aaa_hub_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_62_aaa_hub_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_62_aaa_hub_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_62_aaa_hub_ek",2,"key","HK_RXECD_62_AAA","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_62_aaa_hub_ek",5,"xenc_encryption_key","EK_RXECD_62_AAA_HUB","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_62_aaa_hub_ek",7,"xenc_bk_hash","BKH_RXECK_62_AAA_HUB_EK","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_62_aaa_hub_ek",7,"xenc_bk_salted_hash","BKH_RXECK_62_AAA_HUB_EK_ST","CHAR(28)"]
 ],
 "process_column_mapping": [
         ["rxecd_62_aaa_hub","R111","HK_RXECD_62_AAA","HK_RXECD_62_AAA_R111",null],
         ["rxecd_62_aaa_hub","R111","BK_AAA","F1_BK_AAA_L1","F1_BK_AAA_L1"],
         ["rxecd_62_aaa_hub","R222","HK_RXECD_62_AAA","HK_RXECD_62_AAA_R222",null],
         ["rxecd_62_aaa_hub","R222","BK_AAA","F2_BK_AAA_L2","F2_BK_AAA_L2"],
         ["rxecd_62_aaa_hub","R333","HK_RXECD_62_AAA","HK_RXECD_62_AAA_R333",null],
         ["rxecd_62_aaa_hub","R333","BK_AAA","F3_BK_AAA_L3","F3_BK_AAA_L3"],
         ["rxecd_62_aaa_p1_sat","R111","HK_RXECD_62_AAA","HK_RXECD_62_AAA_R111",null],
         ["rxecd_62_aaa_p1_sat","R111","RH_RXECD_62_AAA_P1_SAT","RH_RXECD_62_AAA_P1_SAT_R111",null],
         ["rxecd_62_aaa_p1_sat","R111","F4_AAA_S1_COLA","F4_AAA_S1_COLA","F4_AAA_S1_COLA"],
         ["rxecd_62_aaa_p1_sat","R111","F5_AAA_S1_COLB","F5_AAA_S1_COLB","F5_AAA_S1_COLB"],
         ["rxecd_62_aaa_p1_sat","R222","HK_RXECD_62_AAA","HK_RXECD_62_AAA_R222",null],
         ["rxecd_62_aaa_p1_sat","R222","RH_RXECD_62_AAA_P1_SAT","RH_RXECD_62_AAA_P1_SAT_R222",null],
         ["rxecd_62_aaa_p1_sat","R222","F4_AAA_S1_COLA","F6_AAA_S1_COLA_L2","F6_AAA_S1_COLA_L2"],
         ["rxecd_62_aaa_p1_sat","R222","F5_AAA_S1_COLB","F7_AAA_S1_COLB_L2","F7_AAA_S1_COLB_L2"]
 ],
 "stage_table_column": [
         ["HK_RXECD_62_AAA_R111","CHAR(28)",2,null,null,false],
         ["HK_RXECD_62_AAA_R222","CHAR(28)",2,null,null,false],
         ["HK_RXECD_62_AAA_R333","CHAR(28)",2,null,null,false],
         ["RH_RXECD_62_AAA_P1_SAT_R111","CHAR(28)",3,null,null,false],
         ["RH_RXECD_62_AAA_P1_SAT_R222","CHAR(28)",3,null,null,false],
         ["F1_BK_AAA_L1","VARCHAR(20)",8,"F1_BK_AAA_L1","VARCHAR(20)",true],
         ["F2_BK_AAA_L2","VARCHAR(20)",8,"F2_BK_AAA_L2","VARCHAR(20)",true],
         ["F3_BK_AAA_L3","VARCHAR(20)",8,"F3_BK_AAA_L3","VARCHAR(20)",true],
         ["F4_AAA_S1_COLA","VARCHAR(20)",8,"F4_AAA_S1_COLA","VARCHAR(20)",false],
         ["F5_AAA_S1_COLB","VARCHAR(20)",8,"F5_AAA_S1_COLB","VARCHAR(20)",false],
         ["F6_AAA_S1_COLA_L2","VARCHAR(20)",8,"F6_AAA_S1_COLA_L2","VARCHAR(20)",false],
         ["F7_AAA_S1_COLB_L2","VARCHAR(20)",8,"F7_AAA_S1_COLB_L2","VARCHAR(20)",false]
 ],
 "stage_hash_input_field": [
         ["R111","HK_RXECD_62_AAA_R111","F1_BK_AAA_L1",0,0],
         ["R111","RH_RXECD_62_AAA_P1_SAT_R111","F4_AAA_S1_COLA",0,0],
         ["R111","RH_RXECD_62_AAA_P1_SAT_R111","F5_AAA_S1_COLB",0,0],
         ["R222","HK_RXECD_62_AAA_R222","F2_BK_AAA_L2",0,0],
         ["R222","RH_RXECD_62_AAA_P1_SAT_R222","F6_AAA_S1_COLA_L2",0,0],
         ["R222","RH_RXECD_62_AAA_P1_SAT_R222","F7_AAA_S1_COLB_L2",0,0],
         ["R333","HK_RXECD_62_AAA_R333","F3_BK_AAA_L3",0,0]
 ],
 "xenc_process_column_mapping": [
         ["rxeck_62_aaa_hub_ek","R111","HK_RXECD_62_AAA","CHAR(28)","key","HK_RXECD_62_AAA_R111","HK_RXECD_62_AAA_R111","rxecd_62_aaa_hub"],
         ["rxeck_62_aaa_hub_ek","R111","EK_RXECD_62_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_62_AAA_HUB_R111",null,null],
         ["rxeck_62_aaa_hub_ek","R111","BKH_RXECK_62_AAA_HUB_EK","CHAR(28)","xenc_bk_hash","BKH_RXECK_62_AAA_HUB_EK_R111","HK_RXECD_62_AAA_R111","rxecd_62_aaa_hub"],
         ["rxeck_62_aaa_hub_ek","R111","BKH_RXECK_62_AAA_HUB_EK_ST","CHAR(28)","xenc_bk_salted_hash","BKH_RXECK_62_AAA_HUB_EK_ST_R111","HK_RXECD_62_AAA_R111","rxecd_62_aaa_hub"],
         ["rxeck_62_aaa_hub_ek","R222","HK_RXECD_62_AAA","CHAR(28)","key","HK_RXECD_62_AAA_R222","HK_RXECD_62_AAA_R222","rxecd_62_aaa_hub"],
         ["rxeck_62_aaa_hub_ek","R222","EK_RXECD_62_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_62_AAA_HUB_R222",null,null],
         ["rxeck_62_aaa_hub_ek","R222","BKH_RXECK_62_AAA_HUB_EK","CHAR(28)","xenc_bk_hash","BKH_RXECK_62_AAA_HUB_EK_R222","HK_RXECD_62_AAA_R222","rxecd_62_aaa_hub"],
         ["rxeck_62_aaa_hub_ek","R222","BKH_RXECK_62_AAA_HUB_EK_ST","CHAR(28)","xenc_bk_salted_hash","BKH_RXECK_62_AAA_HUB_EK_ST_R222","HK_RXECD_62_AAA_R222","rxecd_62_aaa_hub"],
         ["rxeck_62_aaa_hub_ek","R333","HK_RXECD_62_AAA","CHAR(28)","key","HK_RXECD_62_AAA_R333","HK_RXECD_62_AAA_R333","rxecd_62_aaa_hub"],
         ["rxeck_62_aaa_hub_ek","R333","EK_RXECD_62_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_62_AAA_HUB_R333",null,null],
         ["rxeck_62_aaa_hub_ek","R333","BKH_RXECK_62_AAA_HUB_EK","CHAR(28)","xenc_bk_hash","BKH_RXECK_62_AAA_HUB_EK_R333","HK_RXECD_62_AAA_R333","rxecd_62_aaa_hub"],
         ["rxeck_62_aaa_hub_ek","R333","BKH_RXECK_62_AAA_HUB_EK_ST","CHAR(28)","xenc_bk_salted_hash","BKH_RXECK_62_AAA_HUB_EK_ST_R333","HK_RXECD_62_AAA_R333","rxecd_62_aaa_hub"]
 ],
 "xenc_process_field_to_encryption_key_mapping": [
         ["R111","F1_BK_AAA_L1","F1_BK_AAA_L1","EK_RXECD_62_AAA_HUB_R111",1],
         ["R222","F2_BK_AAA_L2","F2_BK_AAA_L2","EK_RXECD_62_AAA_HUB_R222",1],
         ["R333","F3_BK_AAA_L3","F3_BK_AAA_L3","EK_RXECD_62_AAA_HUB_R333",1]
  ]    }');