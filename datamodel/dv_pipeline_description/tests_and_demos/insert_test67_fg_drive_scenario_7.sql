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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test67_fg_drive_scenario_7';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test67_fg_drive_scenario_7','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test67_fg_drive_scenario_7",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_L1", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_67_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["R111"]}]}
		      ,{"field_name": "F2_BK_AAA_L2", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_67_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["R222"]}]}		 	  
		      ,{"field_name": "F3_BK_BBB", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_67_bbb_hub"}]}		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_67_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_67_aaa"}
				,{"table_name": "rtjj_67_aaa_bbb_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtjj_67_aaa_bbb",
																				"link_parent_tables": ["rtjj_67_aaa_hub","rtjj_67_bbb_hub"]}
				,{"table_name": "rtjj_67_aaa_bbb_g1_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_67_aaa_bbb_lnk"
																				,"tracked_relation_name": "R111"}
				,{"table_name": "rtjj_67_aaa_bbb_g2_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_67_aaa_bbb_lnk"
																				,"tracked_relation_name": "R222"}
				,{"table_name": "rtjj_67_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_67_bbb"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test67_fg_drive_scenario_7');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test67_fg_drive_scenario_7';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test67_fg_drive_scenario_7','{
 "dv_model_column": [
      ["rvlt_test_jj","rtjj_67_aaa_bbb_g1_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_g1_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_g1_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_g1_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_g1_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_g1_esat",2,"parent_key","LK_RTJJ_67_AAA_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_g2_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_g2_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_g2_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_g2_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_g2_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_g2_esat",2,"parent_key","LK_RTJJ_67_AAA_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_lnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_lnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_lnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_lnk",2,"key","LK_RTJJ_67_AAA_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_67_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_67_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_67_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_67_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_67_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_67_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_67_aaa_hub",2,"key","HK_RTJJ_67_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_67_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_67_bbb_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_67_bbb_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_67_bbb_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_67_bbb_hub",2,"key","HK_RTJJ_67_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_67_bbb_hub",8,"business_key","F3_BK_BBB","VARCHAR(20)"]
 ],
 "process_column_mapping": [
         ["rtjj_67_aaa_bbb_g1_esat","R111","LK_RTJJ_67_AAA_BBB","LK_RTJJ_67_AAA_BBB_R111",null],
         ["rtjj_67_aaa_bbb_g2_esat","R222","LK_RTJJ_67_AAA_BBB","LK_RTJJ_67_AAA_BBB_R222",null],
         ["rtjj_67_aaa_bbb_lnk","R111","LK_RTJJ_67_AAA_BBB","LK_RTJJ_67_AAA_BBB_R111",null],
         ["rtjj_67_aaa_bbb_lnk","R111","HK_RTJJ_67_AAA","HK_RTJJ_67_AAA_R111",null],
         ["rtjj_67_aaa_bbb_lnk","R111","HK_RTJJ_67_BBB","HK_RTJJ_67_BBB",null],
         ["rtjj_67_aaa_bbb_lnk","R222","LK_RTJJ_67_AAA_BBB","LK_RTJJ_67_AAA_BBB_R222",null],
         ["rtjj_67_aaa_bbb_lnk","R222","HK_RTJJ_67_AAA","HK_RTJJ_67_AAA_R222",null],
         ["rtjj_67_aaa_bbb_lnk","R222","HK_RTJJ_67_BBB","HK_RTJJ_67_BBB",null],
         ["rtjj_67_aaa_hub","R111","HK_RTJJ_67_AAA","HK_RTJJ_67_AAA_R111",null],
         ["rtjj_67_aaa_hub","R111","BK_AAA","F1_BK_AAA_L1","F1_BK_AAA_L1"],
         ["rtjj_67_aaa_hub","R222","HK_RTJJ_67_AAA","HK_RTJJ_67_AAA_R222",null],
         ["rtjj_67_aaa_hub","R222","BK_AAA","F2_BK_AAA_L2","F2_BK_AAA_L2"],
         ["rtjj_67_bbb_hub","_A_","HK_RTJJ_67_BBB","HK_RTJJ_67_BBB",null],
         ["rtjj_67_bbb_hub","_A_","F3_BK_BBB","F3_BK_BBB","F3_BK_BBB"]
 ],
 "stage_table_column": [
         ["HK_RTJJ_67_AAA_R111","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_67_AAA_R222","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_67_BBB","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_67_AAA_BBB_R111","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_67_AAA_BBB_R222","CHAR(28)",2,null,null,false],
         ["F1_BK_AAA_L1","VARCHAR(20)",8,"F1_BK_AAA_L1","VARCHAR(20)",false],
         ["F2_BK_AAA_L2","VARCHAR(20)",8,"F2_BK_AAA_L2","VARCHAR(20)",false],
         ["F3_BK_BBB","VARCHAR(20)",8,"F3_BK_BBB","VARCHAR(20)",false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_67_BBB","F3_BK_BBB",0,0],
         ["R111","HK_RTJJ_67_AAA_R111","F1_BK_AAA_L1",0,0],
         ["R111","LK_RTJJ_67_AAA_BBB_R111","F1_BK_AAA_L1",0,0],
         ["R111","LK_RTJJ_67_AAA_BBB_R111","F3_BK_BBB",0,0],
         ["R222","HK_RTJJ_67_AAA_R222","F2_BK_AAA_L2",0,0],
         ["R222","LK_RTJJ_67_AAA_BBB_R222","F2_BK_AAA_L2",0,0],
         ["R222","LK_RTJJ_67_AAA_BBB_R222","F3_BK_BBB",0,0]
  ]    }');