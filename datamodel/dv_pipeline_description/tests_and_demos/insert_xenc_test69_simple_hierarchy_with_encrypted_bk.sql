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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test69_simple_hierarchy_with_encrypted_bk';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test69_simple_hierarchy_with_encrypted_bk','{
	"dvpd_version": "1.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "xenc_test69_simple_hierarchy_with_encrypted_bk",
	"record_source_name_expression":"dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 
	"fields": [
		      {"field_name": "F1_BK_AAA", 		"field_type": "Varchar(20)", "needs_encryption":true,	"targets": [{"table_name": "rxecd_69_aaa_hub"
																					,"column_name": "BK_AAA"}]}
		      ,{"field_name": "F2_BK_AAA_H1", 		"field_type": "Varchar(20)",	"needs_encryption":true, "targets": [{"table_name": "rxecd_69_aaa_hub"
																					,"column_name": "BK_AAA"
																					,"recursion_name": "HRCHY1"}]}		  
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_xenc_data", 
		 "tables": [
				{"table_name": "rxecd_69_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rxecd_69_aaa"}
				,{"table_name": "rxecd_69_aaa_hierarchy_hlnk",	"table_stereotype": "lnk" ,"link_key_column_name": "LK_rxecd_69_aaa_hierarchy"
																			,"link_parent_tables": ["rxecd_69_aaa_hub"]
																			,"recursive_parents": [ {"table_name":"rxecd_69_aaa_hub"
																										,"recursion_name": "HRCHY1"}]}
				,{"table_name": "rxecd_69_aaa_hierarchy_esat",	"table_stereotype": "sat","satellite_parent_table": "rxecd_69_aaa_hierarchy_hlnk"
																				,"driving_keys": ["HK_rxecd_69_aaa_HRCHY1"]}

				]
		}
		,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{"table_name": "rxeck_69_aaa_hub_ek",	"table_stereotype": "xenc_hub-ek", "xenc_content_table_name":"rxecd_69_aaa_hub"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test69_simple_hierarchy_with_encrypted_bk');
select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test69_simple_hierarchy_with_encrypted_bk');

-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'xenc_test69_simple_hierarchy_with_encrypted_bk';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('xenc_test69_simple_hierarchy_with_encrypted_bk','{
 "dv_model_column": [
      ["rvlt_xenc_data","rxecd_69_aaa_hierarchy_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_69_aaa_hierarchy_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_xenc_data","rxecd_69_aaa_hierarchy_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_69_aaa_hierarchy_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_69_aaa_hierarchy_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_69_aaa_hierarchy_esat",2,"parent_key","LK_RXECD_69_AAA_HIERARCHY","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_69_aaa_hierarchy_hlnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_69_aaa_hierarchy_hlnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_69_aaa_hierarchy_hlnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_69_aaa_hierarchy_hlnk",2,"key","LK_RXECD_69_AAA_HIERARCHY","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_69_aaa_hierarchy_hlnk",3,"parent_key","HK_RXECD_69_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_69_aaa_hierarchy_hlnk",4,"parent_key","HK_RXECD_69_AAA_HRCHY1","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_69_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_69_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_69_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_69_aaa_hub",2,"key","HK_RXECD_69_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_69_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"],
      ["rvlt_xenc_keys","rxeck_69_aaa_hub_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_69_aaa_hub_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_69_aaa_hub_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_69_aaa_hub_ek",2,"key","HK_RXECD_69_AAA","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_69_aaa_hub_ek",5,"xenc_encryption_key","EK_RXECD_69_AAA_HUB","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_69_aaa_hub_ek",7,"xenc_bk_hash","BKH_RXECK_69_AAA_HUB_EK","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_69_aaa_hub_ek",7,"xenc_bk_salted_hash","BKH_RXECK_69_AAA_HUB_EK_ST","CHAR(28)"]
 ],
 "process_column_mapping": [
         ["rxecd_69_aaa_hierarchy_esat","_A_","LK_RXECD_69_AAA_HIERARCHY","LK_RXECD_69_AAA_HIERARCHY",null],
         ["rxecd_69_aaa_hierarchy_hlnk","_A_","LK_RXECD_69_AAA_HIERARCHY","LK_RXECD_69_AAA_HIERARCHY",null],
         ["rxecd_69_aaa_hierarchy_hlnk","_A_","HK_RXECD_69_AAA","HK_RXECD_69_AAA",null],
         ["rxecd_69_aaa_hierarchy_hlnk","_A_","HK_RXECD_69_AAA_HRCHY1","HK_RXECD_69_AAA_HRCHY1",null],
         ["rxecd_69_aaa_hub","_A_","HK_RXECD_69_AAA","HK_RXECD_69_AAA",null],
         ["rxecd_69_aaa_hub","_A_","BK_AAA","F1_BK_AAA","F1_BK_AAA"],
         ["rxecd_69_aaa_hub","_HRCHY1","HK_RXECD_69_AAA","HK_RXECD_69_AAA_HRCHY1",null],
         ["rxecd_69_aaa_hub","_HRCHY1","BK_AAA","F2_BK_AAA_H1","F2_BK_AAA_H1"]
 ],
 "stage_table_column": [
         ["HK_RXECD_69_AAA","CHAR(28)",2,null,null,false],
         ["HK_RXECD_69_AAA_HRCHY1","CHAR(28)",2,null,null,false],
         ["LK_RXECD_69_AAA_HIERARCHY","CHAR(28)",2,null,null,false],
         ["F1_BK_AAA","VARCHAR(20)",8,"F1_BK_AAA","VARCHAR(20)",true],
         ["F2_BK_AAA_H1","VARCHAR(20)",8,"F2_BK_AAA_H1","VARCHAR(20)",true]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RXECD_69_AAA","F1_BK_AAA",0,0],
         ["_A_","LK_RXECD_69_AAA_HIERARCHY","F1_BK_AAA",0,0],
         ["_A_","LK_RXECD_69_AAA_HIERARCHY","F2_BK_AAA_H1",0,0],
         ["_HRCHY1","HK_RXECD_69_AAA_HRCHY1","F2_BK_AAA_H1",0,0]
 ],
 "xenc_process_column_mapping": [
         ["rxeck_69_aaa_hub_ek","_A_","HK_RXECD_69_AAA","CHAR(28)","key","HK_RXECD_69_AAA","HK_RXECD_69_AAA","rxecd_69_aaa_hub"],
         ["rxeck_69_aaa_hub_ek","_A_","EK_RXECD_69_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_69_AAA_HUB",null,null],
         ["rxeck_69_aaa_hub_ek","_A_","BKH_RXECK_69_AAA_HUB_EK","CHAR(28)","xenc_bk_hash","BKH_RXECK_69_AAA_HUB_EK","HK_RXECD_69_AAA","rxecd_69_aaa_hub"],
         ["rxeck_69_aaa_hub_ek","_A_","BKH_RXECK_69_AAA_HUB_EK_ST","CHAR(28)","xenc_bk_salted_hash","BKH_RXECK_69_AAA_HUB_EK_ST","HK_RXECD_69_AAA","rxecd_69_aaa_hub"],
         ["rxeck_69_aaa_hub_ek","_HRCHY1","HK_RXECD_69_AAA","CHAR(28)","key","HK_RXECD_69_AAA_HRCHY1","HK_RXECD_69_AAA_HRCHY1","rxecd_69_aaa_hub"],
         ["rxeck_69_aaa_hub_ek","_HRCHY1","EK_RXECD_69_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_69_AAA_HUB_HRCHY1",null,null],
         ["rxeck_69_aaa_hub_ek","_HRCHY1","BKH_RXECK_69_AAA_HUB_EK","CHAR(28)","xenc_bk_hash","BKH_RXECK_69_AAA_HUB_EK_HRCHY1","HK_RXECD_69_AAA_HRCHY1","rxecd_69_aaa_hub"],
         ["rxeck_69_aaa_hub_ek","_HRCHY1","BKH_RXECK_69_AAA_HUB_EK_ST","CHAR(28)","xenc_bk_salted_hash","BKH_RXECK_69_AAA_HUB_EK_ST_HRCHY1","HK_RXECD_69_AAA_HRCHY1","rxecd_69_aaa_hub"]
 ],
 "xenc_process_field_to_encryption_key_mapping": [
         ["_A_","F1_BK_AAA","F1_BK_AAA","EK_RXECD_69_AAA_HUB",1],
         ["_HRCHY1","F2_BK_AAA_H1","F2_BK_AAA_H1","EK_RXECD_69_AAA_HUB_HRCHY1",1]
  ]    }');