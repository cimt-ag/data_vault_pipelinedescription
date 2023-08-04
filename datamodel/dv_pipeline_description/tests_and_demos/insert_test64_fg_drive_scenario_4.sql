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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test64_fg_drive_scenario_4';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test64_fg_drive_scenario_4','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test64_fg_drive_scenario_4",
	"purpose":"Test dvpd multi relations wothout any differenciation in the link or esat",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_L1", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_64_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["R111"]}]}
		      ,{"field_name": "F2_BK_AAA_L2", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_64_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["R222"]}]}		 	  
		      ,{"field_name": "F3_BK_BBB", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_64_bbb_hub"}]}		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_64_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_64_aaa"}
				,{"table_name": "rtjj_64_aaa_bbb_lnk",	"table_stereotype": "lnk"	,"link_key_column_name": "LK_rtjj_64_aaa_bbb"
																			,"link_parent_tables": ["rtjj_64_aaa_hub","rtjj_64_bbb_hub"]}
				,{"table_name": "rtjj_64_aaa_bbb_esat",	"table_stereotype": "sat"	,"satellite_parent_table": "rtjj_64_aaa_bbb_lnk"}
				,{"table_name": "rtjj_64_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_64_bbb"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test64_fg_drive_scenario_4');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test64_fg_drive_scenario_4';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test64_fg_drive_scenario_4','{
 "dv_model_column": [
      ["rvlt_test_jj","rtjj_64_aaa_bbb_lnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_64_aaa_bbb_lnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_64_aaa_bbb_lnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_64_aaa_bbb_lnk",2,"key","LK_RTJJ_64_AAA_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_64_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_64_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_64_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_64_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_64_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_64_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_64_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_64_aaa_hub",2,"key","HK_RTJJ_64_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_64_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_64_bbb_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_64_bbb_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_64_bbb_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_64_bbb_hub",2,"key","HK_RTJJ_64_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_64_bbb_hub",8,"business_key","F3_BK_BBB","VARCHAR(20)"]
 ],
 "process_column_mapping": [
         ["rtjj_64_aaa_bbb_lnk","_FG1","LK_RTJJ_64_AAA_BBB","LK_RTJJ_64_AAA_BBB_FG1",null],
         ["rtjj_64_aaa_bbb_lnk","_FG1","HK_RTJJ_64_AAA","HK_RTJJ_64_AAA_FG1",null],
         ["rtjj_64_aaa_bbb_lnk","_FG1","HK_RTJJ_64_BBB","HK_RTJJ_64_BBB",null],
         ["rtjj_64_aaa_bbb_lnk","_FG2","LK_RTJJ_64_AAA_BBB","LK_RTJJ_64_AAA_BBB_FG2",null],
         ["rtjj_64_aaa_bbb_lnk","_FG2","HK_RTJJ_64_AAA","HK_RTJJ_64_AAA_FG2",null],
         ["rtjj_64_aaa_bbb_lnk","_FG2","HK_RTJJ_64_BBB","HK_RTJJ_64_BBB",null],
         ["rtjj_64_aaa_hub","_FG1","HK_RTJJ_64_AAA","HK_RTJJ_64_AAA_FG1",null],
         ["rtjj_64_aaa_hub","_FG1","BK_AAA","F1_BK_AAA_L1","F1_BK_AAA_L1"],
         ["rtjj_64_aaa_hub","_FG2","HK_RTJJ_64_AAA","HK_RTJJ_64_AAA_FG2",null],
         ["rtjj_64_aaa_hub","_FG2","BK_AAA","F2_BK_AAA_L2","F2_BK_AAA_L2"],
         ["rtjj_64_bbb_hub","_A_","HK_RTJJ_64_BBB","HK_RTJJ_64_BBB",null],
         ["rtjj_64_bbb_hub","_A_","F3_BK_BBB","F3_BK_BBB","F3_BK_BBB"]
 ],
 "stage_table_column": [
         ["HK_RTJJ_64_AAA_FG1","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_64_AAA_FG2","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_64_BBB","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_64_AAA_BBB_FG1","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_64_AAA_BBB_FG2","CHAR(28)",2,null,null,false],
         ["F1_BK_AAA_L1","VARCHAR(20)",8,"F1_BK_AAA_L1","VARCHAR(20)",false],
         ["F2_BK_AAA_L2","VARCHAR(20)",8,"F2_BK_AAA_L2","VARCHAR(20)",false],
         ["F3_BK_BBB","VARCHAR(20)",8,"F3_BK_BBB","VARCHAR(20)",false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_64_BBB","F3_BK_BBB",0,0],
         ["_FG1","HK_RTJJ_64_AAA_FG1","F1_BK_AAA_L1",0,0],
         ["_FG1","LK_RTJJ_64_AAA_BBB_FG1","F1_BK_AAA_L1",0,0],
         ["_FG1","LK_RTJJ_64_AAA_BBB_FG1","F3_BK_BBB",0,0],
         ["_FG2","HK_RTJJ_64_AAA_FG2","F2_BK_AAA_L2",0,0],
         ["_FG2","LK_RTJJ_64_AAA_BBB_FG2","F2_BK_AAA_L2",0,0],
         ["_FG2","LK_RTJJ_64_AAA_BBB_FG2","F3_BK_BBB",0,0]
  ]    }');