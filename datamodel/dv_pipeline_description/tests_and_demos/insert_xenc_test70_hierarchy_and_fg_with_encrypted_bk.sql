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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test70_hierarchy_and_fg_with_encrypted_bk';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test70_hierarchy_and_fg_with_encrypted_bk','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "xenc_test70_hierarchy_and_fg_with_encrypted_bk",
	"record_source_name_expression":"dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 
	"fields": [
		      {"field_name": "F1_BK_AAA_L1", 		"field_type": "Varchar(20)",	"needs_encryption":true
																					,"targets": [{"table_name": "rxecd_70_aaa_hub"
																					,"column_name": "BK_AAA"}]}
		      ,{"field_name": "F2_BK_AAA_L2", 		"field_type": "Varchar(20)",	"needs_encryption":true
																					,	"targets": [{"table_name": "rxecd_70_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["R222"]}]}		 	  
		      ,{"field_name": "F3_BK_AAA_H1_L1", 		"field_type": "Varchar(20)",	"needs_encryption":true
																					,	"targets": [{"table_name": "rxecd_70_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["HRCHY1"]}]}		  
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_xenc_data", 
		 "tables": [
				{"table_name": "rxecd_70_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rxecd_70_aaa"}
				,{"table_name": "rxecd_70_aaa_hierarchy_hlnk",	"table_stereotype": "lnk" ,"link_key_column_name": "LK_rxecd_70_aaa_hierarchy"
																			,"link_parent_tables": [{"table_name":"rxecd_70_aaa_hub"}
																									,{"table_name":"rxecd_70_aaa_hub","relation_name": "HRCHY1"}]}
				,{"table_name": "rxecd_70_aaa_hierarchy_esat",	"table_stereotype": "sat","satellite_parent_table": "rxecd_70_aaa_hierarchy_hlnk"}

				]
		}
		,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{"table_name": "rxeck_70_aaa_hub_ek",	"table_stereotype": "xenc_hub-ek", "xenc_content_table_name":"rxecd_70_aaa_hub"}
				]
		}
 ]
}');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test70_hierarchy_and_fg_with_encrypted_bk');
select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test70_hierarchy_and_fg_with_encrypted_bk');


-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'xenc_test70_hierarchy_and_fg_with_encrypted_bk';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('xenc_test70_hierarchy_and_fg_with_encrypted_bk','{
 "dv_model_column": [
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_esat",2,"parent_key","LK_RXECD_70_AAA_HIERARCHY","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_hlnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_hlnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_hlnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_hlnk",2,"key","LK_RXECD_70_AAA_HIERARCHY","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_hlnk",3,"parent_key","HK_RXECD_70_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hierarchy_hlnk",4,"parent_key","HK_RXECD_70_AAA_HRCHY1","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_70_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_70_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hub",2,"key","HK_RXECD_70_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_70_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",2,"key","HK_RXECD_70_AAA","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",5,"xenc_encryption_key","EK_RXECD_70_AAA_HUB","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",7,"xenc_bk_hash","BKH_RXECK_70_AAA_HUB_EK","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_70_aaa_hub_ek",7,"xenc_bk_salted_hash","BKH_RXECK_70_AAA_HUB_EK_ST","CHAR(28)"]
 ],
 "process_column_mapping": [
         ["rxecd_70_aaa_hierarchy_esat","/","LK_RXECD_70_AAA_HIERARCHY","LK_RXECD_70_AAA_HIERARCHY",null],
         ["rxecd_70_aaa_hierarchy_hlnk","/","LK_RXECD_70_AAA_HIERARCHY","LK_RXECD_70_AAA_HIERARCHY",null],
         ["rxecd_70_aaa_hierarchy_hlnk","/","HK_RXECD_70_AAA","HK_RXECD_70_AAA",null],
         ["rxecd_70_aaa_hierarchy_hlnk","/","HK_RXECD_70_AAA_HRCHY1","HK_RXECD_70_AAA_HRCHY1",null],
         ["rxecd_70_aaa_hub","/","HK_RXECD_70_AAA","HK_RXECD_70_AAA",null],
         ["rxecd_70_aaa_hub","/","BK_AAA","F1_BK_AAA_L1","F1_BK_AAA_L1"],
         ["rxecd_70_aaa_hub","R222","HK_RXECD_70_AAA","HK_RXECD_70_AAA_R222",null],
         ["rxecd_70_aaa_hub","R222","BK_AAA","F2_BK_AAA_L2","F2_BK_AAA_L2"],
         ["rxecd_70_aaa_hub","HRCHY1","HK_RXECD_70_AAA","HK_RXECD_70_AAA_HRCHY1",null],
         ["rxecd_70_aaa_hub","HRCHY1","BK_AAA","F3_BK_AAA_H1_L1","F3_BK_AAA_H1_L1"]
 ],
 "stage_table_column": [
         ["HK_RXECD_70_AAA","CHAR(28)",2,null,null,false],
         ["HK_RXECD_70_AAA_R222","CHAR(28)",2,null,null,false],
         ["HK_RXECD_70_AAA_HRCHY1","CHAR(28)",2,null,null,false],
         ["LK_RXECD_70_AAA_HIERARCHY","CHAR(28)",2,null,null,false],
         ["F1_BK_AAA_L1","VARCHAR(20)",8,"F1_BK_AAA_L1","VARCHAR(20)",true],
         ["F2_BK_AAA_L2","VARCHAR(20)",8,"F2_BK_AAA_L2","VARCHAR(20)",true],
         ["F3_BK_AAA_H1_L1","VARCHAR(20)",8,"F3_BK_AAA_H1_L1","VARCHAR(20)",true]
 ],
 "stage_hash_input_field": [
         ["/","HK_RXECD_70_AAA","F1_BK_AAA_L1",0,0],
         ["/","LK_RXECD_70_AAA_HIERARCHY","F1_BK_AAA_L1",0,0],
         ["/","LK_RXECD_70_AAA_HIERARCHY","F3_BK_AAA_H1_L1",0,0],
         ["R222","HK_RXECD_70_AAA_R222","F2_BK_AAA_L2",0,0],
         ["HRCHY1","HK_RXECD_70_AAA_HRCHY1","F3_BK_AAA_H1_L1",0,0]
 ],
 "xenc_process_column_mapping": [
         ["rxeck_70_aaa_hub_ek","/","HK_RXECD_70_AAA","CHAR(28)","key","HK_RXECD_70_AAA","HK_RXECD_70_AAA","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","/","EK_RXECD_70_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_70_AAA_HUB",null,null],
         ["rxeck_70_aaa_hub_ek","/","BKH_RXECK_70_AAA_HUB_EK","CHAR(28)","xenc_bk_hash","BKH_RXECK_70_AAA_HUB_EK","HK_RXECD_70_AAA","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","/","BKH_RXECK_70_AAA_HUB_EK_ST","CHAR(28)","xenc_bk_salted_hash","BKH_RXECK_70_AAA_HUB_EK_ST","HK_RXECD_70_AAA","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","R222","HK_RXECD_70_AAA","CHAR(28)","key","HK_RXECD_70_AAA_R222","HK_RXECD_70_AAA_R222","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","R222","EK_RXECD_70_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_70_AAA_HUB_R222",null,null],
         ["rxeck_70_aaa_hub_ek","R222","BKH_RXECK_70_AAA_HUB_EK","CHAR(28)","xenc_bk_hash","BKH_RXECK_70_AAA_HUB_EK_R222","HK_RXECD_70_AAA_R222","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","R222","BKH_RXECK_70_AAA_HUB_EK_ST","CHAR(28)","xenc_bk_salted_hash","BKH_RXECK_70_AAA_HUB_EK_ST_R222","HK_RXECD_70_AAA_R222","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","HRCHY1","HK_RXECD_70_AAA","CHAR(28)","key","HK_RXECD_70_AAA_HRCHY1","HK_RXECD_70_AAA_HRCHY1","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","HRCHY1","EK_RXECD_70_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_70_AAA_HUB_HRCHY1",null,null],
         ["rxeck_70_aaa_hub_ek","HRCHY1","BKH_RXECK_70_AAA_HUB_EK","CHAR(28)","xenc_bk_hash","BKH_RXECK_70_AAA_HUB_EK_HRCHY1","HK_RXECD_70_AAA_HRCHY1","rxecd_70_aaa_hub"],
         ["rxeck_70_aaa_hub_ek","HRCHY1","BKH_RXECK_70_AAA_HUB_EK_ST","CHAR(28)","xenc_bk_salted_hash","BKH_RXECK_70_AAA_HUB_EK_ST_HRCHY1","HK_RXECD_70_AAA_HRCHY1","rxecd_70_aaa_hub"]
 ],
 "xenc_process_field_to_encryption_key_mapping": [
         ["/","F1_BK_AAA_L1","F1_BK_AAA_L1","EK_RXECD_70_AAA_HUB",1],
         ["R222","F2_BK_AAA_L2","F2_BK_AAA_L2","EK_RXECD_70_AAA_HUB_R222",1],
         ["HRCHY1","F3_BK_AAA_H1_L1","F3_BK_AAA_H1_L1","EK_RXECD_70_AAA_HUB_HRCHY1",1]
  ]    }');