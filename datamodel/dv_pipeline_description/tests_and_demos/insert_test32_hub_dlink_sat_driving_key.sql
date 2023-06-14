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

DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test32_hub_dlink_sat_driving_key';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test32_hub_dlink_sat_driving_key','{
	"dvpd_version": "1.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test32_hub_dlink_sat_driving_key",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_32_aaa_hub"}]},
		 	  {"field_name": "F2_BK_AAA_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_32_aaa_hub"}]},
		 	  {"field_name": "F3_DC_AAA_DDD_VARCHAR",		"field_type": "DATE",			"targets": [{"table_name": "rtjj_32_aaa_ddd_dlnk"}]},
			  {"field_name": "F4_AAA_DDD_SP1_DECIMAL",		"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_32_aaa_ddd_p1_sat"}]},
			  {"field_name": "F5_AAA_DDD_SP1_DECIMAL",		"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_32_aaa_ddd_p1_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_32_aaa_hub",		"table_stereotype": "hub",			"hub_key_column_name": "HK_rtjj_32_aaa"},
				{"table_name": "rtjj_32_aaa_ddd_dlnk",		"table_stereotype": "lnk",	"link_key_column_name": "LK_rtjj_32_aaa_ddd",
																 				"link_parent_tables":["rtjj_32_aaa_hub"]},
				{"table_name": "rtjj_32_aaa_ddd_p1_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_32_aaa_ddd_dlnk"
													,"diff_hash_column_name": "RH_rtjj_32_aaa_ddd_p1_sat"
													,"driving_keys":["HK_rtjj_32_aaa","F3_DC_AAA_DDD_VARCHAR"]}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test32_hub_dlink_sat_driving_key');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test32_hub_dlink_sat_driving_key';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test32_hub_dlink_sat_driving_key','{
 "dv_model_column": [
      ["rvlt_test_jj","rtjj_32_aaa_ddd_dlnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_dlnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_dlnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_dlnk",2,"key","LK_RTJJ_32_AAA_DDD","CHAR(28)"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_dlnk",3,"parent_key","HK_RTJJ_32_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_dlnk",8,"dependent_child_key","F3_DC_AAA_DDD_VARCHAR","DATE"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_p1_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_p1_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_p1_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_p1_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_p1_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_p1_sat",2,"parent_key","LK_RTJJ_32_AAA_DDD","CHAR(28)"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_p1_sat",3,"diff_hash","RH_RTJJ_32_AAA_DDD_P1_SAT","CHAR(28)"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_p1_sat",8,"content","F4_AAA_DDD_SP1_DECIMAL","DECIMAL(5,0)"],
      ["rvlt_test_jj","rtjj_32_aaa_ddd_p1_sat",8,"content","F5_AAA_DDD_SP1_DECIMAL","DECIMAL(5,0)"],
      ["rvlt_test_jj","rtjj_32_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_32_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_32_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_32_aaa_hub",2,"key","HK_RTJJ_32_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_32_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_32_aaa_hub",8,"business_key","F2_BK_AAA_DECIMAL","DECIMAL(20,0)"]
 ],
 "process_column_mapping": [
         ["rtjj_32_aaa_ddd_dlnk","_A_","LK_RTJJ_32_AAA_DDD","LK_RTJJ_32_AAA_DDD",null],
         ["rtjj_32_aaa_ddd_dlnk","_A_","HK_RTJJ_32_AAA","HK_RTJJ_32_AAA",null],
         ["rtjj_32_aaa_ddd_dlnk","_A_","F3_DC_AAA_DDD_VARCHAR","F3_DC_AAA_DDD_VARCHAR","F3_DC_AAA_DDD_VARCHAR"],
         ["rtjj_32_aaa_ddd_p1_sat","_A_","LK_RTJJ_32_AAA_DDD","LK_RTJJ_32_AAA_DDD",null],
         ["rtjj_32_aaa_ddd_p1_sat","_A_","RH_RTJJ_32_AAA_DDD_P1_SAT","RH_RTJJ_32_AAA_DDD_P1_SAT",null],
         ["rtjj_32_aaa_ddd_p1_sat","_A_","F4_AAA_DDD_SP1_DECIMAL","F4_AAA_DDD_SP1_DECIMAL","F4_AAA_DDD_SP1_DECIMAL"],
         ["rtjj_32_aaa_ddd_p1_sat","_A_","F5_AAA_DDD_SP1_DECIMAL","F5_AAA_DDD_SP1_DECIMAL","F5_AAA_DDD_SP1_DECIMAL"],
         ["rtjj_32_aaa_hub","_A_","HK_RTJJ_32_AAA","HK_RTJJ_32_AAA",null],
         ["rtjj_32_aaa_hub","_A_","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR"],
         ["rtjj_32_aaa_hub","_A_","F2_BK_AAA_DECIMAL","F2_BK_AAA_DECIMAL","F2_BK_AAA_DECIMAL"]
 ],
 "stage_table_column": [
         ["HK_RTJJ_32_AAA","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_32_AAA_DDD","CHAR(28)",2,null,null,false],
         ["RH_RTJJ_32_AAA_DDD_P1_SAT","CHAR(28)",3,null,null,false],
         ["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
         ["F2_BK_AAA_DECIMAL","DECIMAL(20,0)",8,"F2_BK_AAA_DECIMAL","DECIMAL(20,0)",false],
         ["F3_DC_AAA_DDD_VARCHAR","DATE",8,"F3_DC_AAA_DDD_VARCHAR","DATE",false],
         ["F4_AAA_DDD_SP1_DECIMAL","DECIMAL(5,0)",8,"F4_AAA_DDD_SP1_DECIMAL","DECIMAL(5,0)",false],
         ["F5_AAA_DDD_SP1_DECIMAL","DECIMAL(5,0)",8,"F5_AAA_DDD_SP1_DECIMAL","DECIMAL(5,0)",false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_32_AAA","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","HK_RTJJ_32_AAA","F2_BK_AAA_DECIMAL",0,0],
         ["_A_","LK_RTJJ_32_AAA_DDD","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","LK_RTJJ_32_AAA_DDD","F2_BK_AAA_DECIMAL",0,0],
         ["_A_","LK_RTJJ_32_AAA_DDD","F3_DC_AAA_DDD_VARCHAR",0,0],
         ["_A_","RH_RTJJ_32_AAA_DDD_P1_SAT","F4_AAA_DDD_SP1_DECIMAL",0,0],
         ["_A_","RH_RTJJ_32_AAA_DDD_P1_SAT","F5_AAA_DDD_SP1_DECIMAL",0,0]
  ]    }');