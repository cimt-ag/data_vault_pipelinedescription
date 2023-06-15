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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test71_fg_drive_scenario_11';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test71_fg_drive_scenario_11','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test71_fg_drive_scenario_11",
	"record_source_name_expression":"dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 
	"fields": [
		      {"field_name": "F1_BK_AAA", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_71_aaa_hub"
																					,"column_name": "BK_AAA"}]}
		      ,{"field_name": "F2_BK_AAA_R1", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_71_aaa_hub"
																					,"column_name": "BK_AAA"
																					,"recursion_name": "RRRR"
																				 	,"field_groups":["fg1"]}]}		 	  
		      ,{"field_name": "F3_BK_AAA_R2", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_71_aaa_hub"
																					,"column_name": "BK_AAA"
																					,"recursion_name": "RRRR"																				 	
																					,"field_groups":["fg2"]}]}		  
		      ,{"field_name": "F4_AAA_S1_COLA","field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_71_aaa_p1_sat"}]}		 
		      ,{"field_name": "F5_AAA_S1_COLB","field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_71_aaa_p1_sat"}]}		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_71_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_71_aaa"}
				,{"table_name": "rtjj_71_aaa_p1_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_71_aaa_hub"
																			,"diff_hash_column_name": "RH_rtjj_71_aaa_p1_sat"}
				,{"table_name": "rtjj_71_aaa_recursion_hlnk",	"table_stereotype": "lnk" ,"link_key_column_name": "LK_rtjj_71_aaa_recursion"
																			,"link_parent_tables": ["rtjj_71_aaa_hub"]
																			,"recursive_parents": [ {"table_name":"rtjj_71_aaa_hub"
																										,"recursion_name": "RRRR"}]}
				,{"table_name": "rtjj_71_aaa_rec1_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_71_aaa_recursion_hlnk"
																				 ,"tracked_field_groups":["fg1"]}
				,{"table_name": "rtjj_71_aaa_rec2_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_71_aaa_recursion_hlnk"
																				 ,"tracked_field_groups":["fg2"]}

				]
		}
 ]
}');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test71_fg_drive_scenario_11');

-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test71_fg_drive_scenario_11';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test71_fg_drive_scenario_11','{
 "dv_model_column": [
      ["rvlt_test_jj","rtjj_71_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_71_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_71_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_71_aaa_hub",2,"key","HK_RTJJ_71_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_71_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_71_aaa_p1_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_71_aaa_p1_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_71_aaa_p1_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_71_aaa_p1_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_71_aaa_p1_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_71_aaa_p1_sat",2,"parent_key","HK_RTJJ_71_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_71_aaa_p1_sat",3,"diff_hash","RH_RTJJ_71_AAA_P1_SAT","CHAR(28)"],
      ["rvlt_test_jj","rtjj_71_aaa_p1_sat",8,"content","F4_AAA_S1_COLA","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_71_aaa_p1_sat",8,"content","F5_AAA_S1_COLB","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_71_aaa_rec1_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_71_aaa_rec1_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_71_aaa_rec1_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_71_aaa_rec1_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_71_aaa_rec1_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_71_aaa_rec1_esat",2,"parent_key","LK_RTJJ_71_AAA_RECURSION","CHAR(28)"],
      ["rvlt_test_jj","rtjj_71_aaa_rec2_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_71_aaa_rec2_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_71_aaa_rec2_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_71_aaa_rec2_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_71_aaa_rec2_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_71_aaa_rec2_esat",2,"parent_key","LK_RTJJ_71_AAA_RECURSION","CHAR(28)"],
      ["rvlt_test_jj","rtjj_71_aaa_recursion_hlnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_71_aaa_recursion_hlnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_71_aaa_recursion_hlnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_71_aaa_recursion_hlnk",2,"key","LK_RTJJ_71_AAA_RECURSION","CHAR(28)"],
      ["rvlt_test_jj","rtjj_71_aaa_recursion_hlnk",3,"parent_key","HK_RTJJ_71_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_71_aaa_recursion_hlnk",4,"parent_key","HK_RTJJ_71_AAA_RRRR","CHAR(28)"]
 ],
 "process_column_mapping": [
         ["rtjj_71_aaa_hub","_A_","HK_RTJJ_71_AAA","HK_RTJJ_71_AAA",null],
         ["rtjj_71_aaa_hub","_A_","BK_AAA","F1_BK_AAA","F1_BK_AAA"],
         ["rtjj_71_aaa_hub","_RRRR_FG1","HK_RTJJ_71_AAA","HK_RTJJ_71_AAA_RRRR_FG1",null],
         ["rtjj_71_aaa_hub","_RRRR_FG1","BK_AAA","F2_BK_AAA_R1","F2_BK_AAA_R1"],
         ["rtjj_71_aaa_hub","_RRRR_FG2","HK_RTJJ_71_AAA","HK_RTJJ_71_AAA_RRRR_FG2",null],
         ["rtjj_71_aaa_hub","_RRRR_FG2","BK_AAA","F3_BK_AAA_R2","F3_BK_AAA_R2"],
         ["rtjj_71_aaa_p1_sat","_A_","HK_RTJJ_71_AAA","HK_RTJJ_71_AAA",null],
         ["rtjj_71_aaa_p1_sat","_A_","RH_RTJJ_71_AAA_P1_SAT","RH_RTJJ_71_AAA_P1_SAT",null],
         ["rtjj_71_aaa_p1_sat","_A_","F4_AAA_S1_COLA","F4_AAA_S1_COLA","F4_AAA_S1_COLA"],
         ["rtjj_71_aaa_p1_sat","_A_","F5_AAA_S1_COLB","F5_AAA_S1_COLB","F5_AAA_S1_COLB"],
         ["rtjj_71_aaa_rec1_esat","_FG1","LK_RTJJ_71_AAA_RECURSION","LK_RTJJ_71_AAA_RECURSION_FG1",null],
         ["rtjj_71_aaa_rec2_esat","_FG2","LK_RTJJ_71_AAA_RECURSION","LK_RTJJ_71_AAA_RECURSION_FG2",null],
         ["rtjj_71_aaa_recursion_hlnk","_FG1","LK_RTJJ_71_AAA_RECURSION","LK_RTJJ_71_AAA_RECURSION_FG1",null],
         ["rtjj_71_aaa_recursion_hlnk","_FG1","HK_RTJJ_71_AAA","HK_RTJJ_71_AAA_FG1",null],
         ["rtjj_71_aaa_recursion_hlnk","_FG1","HK_RTJJ_71_AAA_RRRR","HK_RTJJ_71_AAA_RRRR_FG1",null],
         ["rtjj_71_aaa_recursion_hlnk","_FG2","LK_RTJJ_71_AAA_RECURSION","LK_RTJJ_71_AAA_RECURSION_FG2",null],
         ["rtjj_71_aaa_recursion_hlnk","_FG2","HK_RTJJ_71_AAA","HK_RTJJ_71_AAA_FG2",null],
         ["rtjj_71_aaa_recursion_hlnk","_FG2","HK_RTJJ_71_AAA_RRRR","HK_RTJJ_71_AAA_RRRR_FG2",null]
 ],
 "stage_table_column": [
         ["HK_RTJJ_71_AAA","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_71_AAA_RRRR_FG1","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_71_AAA_RRRR_FG2","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_71_AAA_RECURSION_FG1","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_71_AAA_RECURSION_FG2","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_71_AAA_FG1","CHAR(28)",3,null,null,false],
         ["HK_RTJJ_71_AAA_FG2","CHAR(28)",3,null,null,false],
         ["RH_RTJJ_71_AAA_P1_SAT","CHAR(28)",3,null,null,false],
         ["F1_BK_AAA","VARCHAR(20)",8,"F1_BK_AAA","VARCHAR(20)",false],
         ["F2_BK_AAA_R1","VARCHAR(20)",8,"F2_BK_AAA_R1","VARCHAR(20)",false],
         ["F3_BK_AAA_R2","VARCHAR(20)",8,"F3_BK_AAA_R2","VARCHAR(20)",false],
         ["F4_AAA_S1_COLA","VARCHAR(20)",8,"F4_AAA_S1_COLA","VARCHAR(20)",false],
         ["F5_AAA_S1_COLB","VARCHAR(20)",8,"F5_AAA_S1_COLB","VARCHAR(20)",false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_71_AAA","F1_BK_AAA",0,0],
         ["_A_","RH_RTJJ_71_AAA_P1_SAT","F4_AAA_S1_COLA",0,0],
         ["_A_","RH_RTJJ_71_AAA_P1_SAT","F5_AAA_S1_COLB",0,0],
         ["_FG1","LK_RTJJ_71_AAA_RECURSION_FG1","F1_BK_AAA",0,0],
         ["_FG1","LK_RTJJ_71_AAA_RECURSION_FG1","F2_BK_AAA_R1",0,0],
         ["_FG2","LK_RTJJ_71_AAA_RECURSION_FG2","F1_BK_AAA",0,0],
         ["_FG2","LK_RTJJ_71_AAA_RECURSION_FG2","F3_BK_AAA_R2",0,0],
         ["_RRRR_FG1","HK_RTJJ_71_AAA_RRRR_FG1","F2_BK_AAA_R1",0,0],
         ["_RRRR_FG2","HK_RTJJ_71_AAA_RRRR_FG2","F3_BK_AAA_R2",0,0]
  ]    }');