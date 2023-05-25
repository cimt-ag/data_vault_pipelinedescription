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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test82_double_recursion_and_link';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test82_double_recursion_and_link','{
	"dvpd_version": "1.0",
	"pipeline_name": "test82_double_recursion_and_link",
	"record_source_name_expression":"dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 
	"fields": [
		      {"field_name": "F1_BK_AAA", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_82_aaa_hub"
																					,"target_column_name": "BK_AAA"}]}
		      ,{"field_name": "F2_BK_AAA_H1", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_82_aaa_hub"
																					,"target_column_name": "BK_AAA"
																					,"recursion_name": "RECU1"}]}		  
		      ,{"field_name": "F3_BK_AAA_H2", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_82_aaa_hub"
																					,"target_column_name": "BK_AAA"
																					,"recursion_name": "RECU2"}]}		  
		      ,{"field_name": "F4_BK_BBB", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_82_bbb_hub"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_82_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_82_aaa"}
				,{"table_name": "rtjj_82_aaa_hierarchy_hlnk",	"stereotype": "lnk" ,"link_key_column_name": "LK_rtjj_82_aaa_hierarchy"
													,"link_parent_tables": ["rtjj_82_aaa_hub"]
													,"recursive_parents": [ {"table_name":"rtjj_82_aaa_hub","recursion_name": "RECU1"}
																			,{"table_name":"rtjj_82_aaa_hub","recursion_name": "RECU2"}]}
				,{"table_name": "rtjj_82_aaa_hierarchy_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_82_aaa_hierarchy_hlnk"}
				,{"table_name": "rtjj_82_bbb_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_82_bbb"}
				,{"table_name": "rtjj_82_bbb_aaa_lnk",		"stereotype": "lnk","link_key_column_name": "LK_rtjj_82_bbb_aaa"
																	,"link_parent_tables": ["rtjj_82_bbb_hub","rtjj_82_aaa_hub"]}

				,{"table_name": "rtjj_82_bbb_aaa_esat",	"stereotype": "esat","satellite_parent_table": "rtjj_82_bbb_aaa_lnk"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test82_double_recursion_and_link');

-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test82_double_recursion_and_link';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test82_double_recursion_and_link','{
 "dv_model_column": [
      ["rvlt_test_jj","rtjj_82_aaa_hierarchy_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_82_aaa_hierarchy_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_82_aaa_hierarchy_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_82_aaa_hierarchy_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_82_aaa_hierarchy_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_82_aaa_hierarchy_esat",2,"parent_key","LK_RTJJ_82_AAA_HIERARCHY","CHAR(28)"],
      ["rvlt_test_jj","rtjj_82_aaa_hierarchy_hlnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_82_aaa_hierarchy_hlnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_82_aaa_hierarchy_hlnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_82_aaa_hierarchy_hlnk",2,"key","LK_RTJJ_82_AAA_HIERARCHY","CHAR(28)"],
      ["rvlt_test_jj","rtjj_82_aaa_hierarchy_hlnk",3,"parent_key","HK_RTJJ_82_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_82_aaa_hierarchy_hlnk",4,"parent_key","HK_RTJJ_82_AAA_RECU1","CHAR(28)"],
      ["rvlt_test_jj","rtjj_82_aaa_hierarchy_hlnk",4,"parent_key","HK_RTJJ_82_AAA_RECU2","CHAR(28)"],
      ["rvlt_test_jj","rtjj_82_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_82_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_82_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_82_aaa_hub",2,"key","HK_RTJJ_82_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_82_aaa_hub",8,"business_key","BK_AAA","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_82_bbb_aaa_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_82_bbb_aaa_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_82_bbb_aaa_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_82_bbb_aaa_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_82_bbb_aaa_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_82_bbb_aaa_esat",2,"parent_key","LK_RTJJ_82_BBB_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_82_bbb_aaa_lnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_82_bbb_aaa_lnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_82_bbb_aaa_lnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_82_bbb_aaa_lnk",2,"key","LK_RTJJ_82_BBB_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_82_bbb_aaa_lnk",3,"parent_key","HK_RTJJ_82_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_82_bbb_aaa_lnk",3,"parent_key","HK_RTJJ_82_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_82_bbb_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_82_bbb_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_82_bbb_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_82_bbb_hub",2,"key","HK_RTJJ_82_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_82_bbb_hub",8,"business_key","F4_BK_BBB","VARCHAR(20)"]
 ],
 "process_column_mapping": [
         ["rtjj_82_aaa_hierarchy_esat","_A_","LK_RTJJ_82_AAA_HIERARCHY","LK_RTJJ_82_AAA_HIERARCHY",null],
         ["rtjj_82_aaa_hierarchy_hlnk","_A_","LK_RTJJ_82_AAA_HIERARCHY","LK_RTJJ_82_AAA_HIERARCHY",null],
         ["rtjj_82_aaa_hierarchy_hlnk","_A_","HK_RTJJ_82_AAA","HK_RTJJ_82_AAA",null],
         ["rtjj_82_aaa_hierarchy_hlnk","_A_","HK_RTJJ_82_AAA_RECU1","HK_RTJJ_82_AAA_RECU1",null],
         ["rtjj_82_aaa_hierarchy_hlnk","_A_","HK_RTJJ_82_AAA_RECU2","HK_RTJJ_82_AAA_RECU2",null],
         ["rtjj_82_aaa_hub","_A_","HK_RTJJ_82_AAA","HK_RTJJ_82_AAA",null],
         ["rtjj_82_aaa_hub","_A_","BK_AAA","F1_BK_AAA","F1_BK_AAA"],
         ["rtjj_82_aaa_hub","_RECU1","HK_RTJJ_82_AAA","HK_RTJJ_82_AAA_RECU1",null],
         ["rtjj_82_aaa_hub","_RECU1","BK_AAA","F2_BK_AAA_H1","F2_BK_AAA_H1"],
         ["rtjj_82_aaa_hub","_RECU2","HK_RTJJ_82_AAA","HK_RTJJ_82_AAA_RECU2",null],
         ["rtjj_82_aaa_hub","_RECU2","BK_AAA","F3_BK_AAA_H2","F3_BK_AAA_H2"],
         ["rtjj_82_bbb_aaa_esat","_A_","LK_RTJJ_82_BBB_AAA","LK_RTJJ_82_BBB_AAA",null],
         ["rtjj_82_bbb_aaa_lnk","_A_","LK_RTJJ_82_BBB_AAA","LK_RTJJ_82_BBB_AAA",null],
         ["rtjj_82_bbb_aaa_lnk","_A_","HK_RTJJ_82_AAA","HK_RTJJ_82_AAA",null],
         ["rtjj_82_bbb_aaa_lnk","_A_","HK_RTJJ_82_BBB","HK_RTJJ_82_BBB",null],
         ["rtjj_82_bbb_hub","_A_","HK_RTJJ_82_BBB","HK_RTJJ_82_BBB",null],
         ["rtjj_82_bbb_hub","_A_","F4_BK_BBB","F4_BK_BBB","F4_BK_BBB"]
 ],
 "stage_table_column": [
         ["HK_RTJJ_82_AAA","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_82_AAA_RECU1","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_82_AAA_RECU2","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_82_BBB","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_82_AAA_HIERARCHY","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_82_BBB_AAA","CHAR(28)",2,null,null,false],
         ["F1_BK_AAA","VARCHAR(20)",8,"F1_BK_AAA","VARCHAR(20)",false],
         ["F2_BK_AAA_H1","VARCHAR(20)",8,"F2_BK_AAA_H1","VARCHAR(20)",false],
         ["F3_BK_AAA_H2","VARCHAR(20)",8,"F3_BK_AAA_H2","VARCHAR(20)",false],
         ["F4_BK_BBB","VARCHAR(20)",8,"F4_BK_BBB","VARCHAR(20)",false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_82_AAA","F1_BK_AAA",0,0],
         ["_A_","HK_RTJJ_82_BBB","F4_BK_BBB",0,0],
         ["_A_","LK_RTJJ_82_AAA_HIERARCHY","F1_BK_AAA",0,0],
         ["_A_","LK_RTJJ_82_AAA_HIERARCHY","F2_BK_AAA_H1",0,0],
         ["_A_","LK_RTJJ_82_AAA_HIERARCHY","F3_BK_AAA_H2",0,0],
         ["_A_","LK_RTJJ_82_BBB_AAA","F1_BK_AAA",0,0],
         ["_A_","LK_RTJJ_82_BBB_AAA","F4_BK_BBB",0,0],
         ["_RECU1","HK_RTJJ_82_AAA_RECU1","F2_BK_AAA_H1",0,0],
         ["_RECU2","HK_RTJJ_82_AAA_RECU2","F3_BK_AAA_H2",0,0]
  ]    }');