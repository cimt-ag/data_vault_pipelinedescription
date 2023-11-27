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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'xenc_test21_encrypt_on_hub';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('xenc_test21_encrypt_on_hub','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
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
				{"table_name": "rxecd_21_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rxecd_21_aaa"}
				,{"table_name": "rxecd_21_aaa_sat",		"table_stereotype": "sat","satellite_parent_table": "rxecd_21_aaa_hub","diff_hash_column_name": "RH_rxecd_21_aaa_sat"}
				,{"table_name": "rxecd_21_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rxecd_21_bbb"}
				,{"table_name": "rxecd_21_aaa_bbb_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rxecd_21_aaa_bbb",
																			"link_parent_tables": ["rxecd_21_aaa_hub","rxecd_21_bbb_hub"]}
				]
		}
		,{"schema_name": "rvlt_xenc_keys", 
		 "tables": [
				{"table_name": "rxeck_21_aaa_hub_ek",		"table_stereotype": "xenc_hub-ek", "xenc_content_table_name":"rxecd_21_aaa_hub"}
				]
		}
	]
}

');

select dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW('xenc_test21_encrypt_on_hub');
select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('xenc_test21_encrypt_on_hub');

-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'xenc_test21_encrypt_on_hub';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('xenc_test21_encrypt_on_hub','{
 "dv_model_column": [
      ["rvlt_xenc_data","rxecd_21_aaa_bbb_lnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_21_aaa_bbb_lnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_21_aaa_bbb_lnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_21_aaa_bbb_lnk",2,"key","LK_RXECD_21_AAA_BBB","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_21_aaa_bbb_lnk",3,"parent_key","HK_RXECD_21_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_21_aaa_bbb_lnk",3,"parent_key","HK_RXECD_21_BBB","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_21_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_21_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_21_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_21_aaa_hub",2,"key","HK_RXECD_21_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_21_aaa_hub",8,"business_key","F1_BK_AAA_ENCRYPT_ME","VARCHAR(20)"],
      ["rvlt_xenc_data","rxecd_21_aaa_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_21_aaa_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_xenc_data","rxecd_21_aaa_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_21_aaa_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_21_aaa_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_21_aaa_sat",2,"parent_key","HK_RXECD_21_AAA","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_21_aaa_sat",3,"diff_hash","RH_RXECD_21_AAA_SAT","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_21_aaa_sat",8,"content","F3_AAA_SP1_VARCHAR","VARCHAR(200)"],
      ["rvlt_xenc_data","rxecd_21_aaa_sat",8,"content","F4_AAA_SP1_VARCHAR","VARCHAR(200)"],
      ["rvlt_xenc_data","rxecd_21_bbb_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_data","rxecd_21_bbb_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_data","rxecd_21_bbb_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_data","rxecd_21_bbb_hub",2,"key","HK_RXECD_21_BBB","CHAR(28)"],
      ["rvlt_xenc_data","rxecd_21_bbb_hub",8,"business_key","F2_BK_BBB_DECIMAL","DECIMAL(20,0)"],
      ["rvlt_xenc_keys","rxeck_21_aaa_hub_ek",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_xenc_keys","rxeck_21_aaa_hub_ek",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_xenc_keys","rxeck_21_aaa_hub_ek",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_xenc_keys","rxeck_21_aaa_hub_ek",2,"key","HK_RXECD_21_AAA","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_21_aaa_hub_ek",5,"xenc_encryption_key","EK_RXECD_21_AAA_HUB","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_21_aaa_hub_ek",7,"xenc_bk_hash","BKH_RXECK_21_AAA_HUB_EK","CHAR(28)"],
      ["rvlt_xenc_keys","rxeck_21_aaa_hub_ek",7,"xenc_bk_salted_hash","BKH_RXECK_21_AAA_HUB_EK_ST","CHAR(28)"]
 ],
 "process_column_mapping": [
         ["rxecd_21_aaa_bbb_lnk","_A_","LK_RXECD_21_AAA_BBB","LK_RXECD_21_AAA_BBB",null],
         ["rxecd_21_aaa_bbb_lnk","_A_","HK_RXECD_21_AAA","HK_RXECD_21_AAA",null],
         ["rxecd_21_aaa_bbb_lnk","_A_","HK_RXECD_21_BBB","HK_RXECD_21_BBB",null],
         ["rxecd_21_aaa_hub","_A_","HK_RXECD_21_AAA","HK_RXECD_21_AAA",null],
         ["rxecd_21_aaa_hub","_A_","F1_BK_AAA_ENCRYPT_ME","F1_BK_AAA_ENCRYPT_ME","F1_BK_AAA_ENCRYPT_ME"],
         ["rxecd_21_aaa_sat","_A_","HK_RXECD_21_AAA","HK_RXECD_21_AAA",null],
         ["rxecd_21_aaa_sat","_A_","RH_RXECD_21_AAA_SAT","RH_RXECD_21_AAA_SAT",null],
         ["rxecd_21_aaa_sat","_A_","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR"],
         ["rxecd_21_aaa_sat","_A_","F4_AAA_SP1_VARCHAR","F4_AAA_SP1_VARCHAR","F4_AAA_SP1_VARCHAR"],
         ["rxecd_21_bbb_hub","_A_","HK_RXECD_21_BBB","HK_RXECD_21_BBB",null],
         ["rxecd_21_bbb_hub","_A_","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL"]
 ],
 "stage_table_column": [
         ["HK_RXECD_21_AAA","CHAR(28)",2,null,null,false],
         ["HK_RXECD_21_BBB","CHAR(28)",2,null,null,false],
         ["LK_RXECD_21_AAA_BBB","CHAR(28)",2,null,null,false],
         ["RH_RXECD_21_AAA_SAT","CHAR(28)",3,null,null,false],
         ["F1_BK_AAA_ENCRYPT_ME","VARCHAR(20)",8,"F1_BK_AAA_ENCRYPT_ME","VARCHAR(20)",true],
         ["F2_BK_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_BK_BBB_DECIMAL","DECIMAL(20,0)",false],
         ["F3_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F3_AAA_SP1_VARCHAR","VARCHAR(200)",false],
         ["F4_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F4_AAA_SP1_VARCHAR","VARCHAR(200)",false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RXECD_21_AAA","F1_BK_AAA_ENCRYPT_ME",0,0],
         ["_A_","HK_RXECD_21_BBB","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","LK_RXECD_21_AAA_BBB","F1_BK_AAA_ENCRYPT_ME",0,0],
         ["_A_","LK_RXECD_21_AAA_BBB","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","RH_RXECD_21_AAA_SAT","F3_AAA_SP1_VARCHAR",0,0],
         ["_A_","RH_RXECD_21_AAA_SAT","F4_AAA_SP1_VARCHAR",0,0]
 ],
 "xenc_process_column_mapping": [
         ["rxeck_21_aaa_hub_ek","_A_","HK_RXECD_21_AAA","CHAR(28)","key","HK_RXECD_21_AAA","HK_RXECD_21_AAA","rxecd_21_aaa_hub"],
         ["rxeck_21_aaa_hub_ek","_A_","EK_RXECD_21_AAA_HUB","CHAR(28)","xenc_encryption_key","EK_RXECD_21_AAA_HUB",null,null],
         ["rxeck_21_aaa_hub_ek","_A_","BKH_RXECK_21_AAA_HUB_EK","CHAR(28)","xenc_bk_hash","BKH_RXECK_21_AAA_HUB_EK","HK_RXECD_21_AAA","rxecd_21_aaa_hub"],
         ["rxeck_21_aaa_hub_ek","_A_","BKH_RXECK_21_AAA_HUB_EK_ST","CHAR(28)","xenc_bk_salted_hash","BKH_RXECK_21_AAA_HUB_EK_ST","HK_RXECD_21_AAA","rxecd_21_aaa_hub"]
 ],
 "xenc_process_field_to_encryption_key_mapping": [
         ["_A_","F1_BK_AAA_ENCRYPT_ME","F1_BK_AAA_ENCRYPT_ME","EK_RXECD_21_AAA_HUB",1]
  ]    }');