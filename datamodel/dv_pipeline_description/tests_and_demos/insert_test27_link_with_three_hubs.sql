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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test27_link_with_three_hubs';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test27_link_with_three_hubs','{
	"dvpd_version": "1.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test27_link_with_three_hubs",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 	"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_27_aaa_hub"}]}
		 	  ,{"field_name": "F2_AAA_SP1_VARCHAR",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_27_aaa_p1_sat"}]}
			  ,{"field_name": "F3_AAA_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_27_aaa_p1_sat"}]}
		 	  ,{"field_name": "F4_BK_BBB_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_27_bbb_hub"}]}
		 	  ,{"field_name": "F5_BK_CCC_VARCHAR",	"field_type": "Varchar(40)",	"targets": [{"table_name": "rtjj_27_ccc_hub"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_27_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_27_aaa"}
				,{"table_name": "rtjj_27_aaa_p1_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_27_aaa_HUB","diff_hash_column_name": "RH_rtjj_27_aaa_P1_SAT"}
				,{"table_name": "rtjj_27_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_27_bbb"}
				,{"table_name": "rtjj_27_ccc_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_27_ccc"}
				,{"table_name": "rtjj_27_aaa_bbb_ccc_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtjj_27_aaa_bbb_ccc",
																				"link_parent_tables": ["rtjj_27_aaa_hub","rtjj_27_bbb_hub","rtjj_27_ccc_hub"]}
				,{"table_name": "rtjj_27_aaa_bbb_ccc_esat",	"table_stereotype": "esat","satellite_parent_table": "rtjj_27_aaa_bbb_ccc_lnk"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test27_link_with_three_hubs');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test27_link_with_three_hubs';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test27_link_with_three_hubs','{
 "dv_model_column": [
      ["rvlt_test_jj","rtjj_27_aaa_bbb_ccc_esat",2,"parent_key","LK_RTJJ_27_AAA_BBB_CCC","CHAR(28)"],
      ["rvlt_test_jj","rtjj_27_aaa_bbb_ccc_lnk",2,"key","LK_RTJJ_27_AAA_BBB_CCC","CHAR(28)"],
      ["rvlt_test_jj","rtjj_27_aaa_bbb_ccc_lnk",3,"parent_key","HK_RTJJ_27_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_27_aaa_bbb_ccc_lnk",3,"parent_key","HK_RTJJ_27_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_27_aaa_bbb_ccc_lnk",3,"parent_key","HK_RTJJ_27_CCC","CHAR(28)"],
      ["rvlt_test_jj","rtjj_27_aaa_hub",2,"key","HK_RTJJ_27_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_27_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_27_aaa_p1_sat",2,"parent_key","HK_RTJJ_27_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_27_aaa_p1_sat",3,"diff_hash","RH_RTJJ_27_AAA_P1_SAT","CHAR(28)"],
      ["rvlt_test_jj","rtjj_27_aaa_p1_sat",8,"content","F2_AAA_SP1_VARCHAR","VARCHAR(200)"],
      ["rvlt_test_jj","rtjj_27_aaa_p1_sat",8,"content","F3_AAA_SP1_DECIMAL","DECIMAL(5,0)"],
      ["rvlt_test_jj","rtjj_27_bbb_hub",2,"key","HK_RTJJ_27_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_27_bbb_hub",8,"business_key","F4_BK_BBB_DECIMAL","DECIMAL(20,0)"],
      ["rvlt_test_jj","rtjj_27_ccc_hub",2,"key","HK_RTJJ_27_CCC","CHAR(28)"],
      ["rvlt_test_jj","rtjj_27_ccc_hub",8,"business_key","F5_BK_CCC_VARCHAR","VARCHAR(40)"]
 ],
 "process_column_mapping": [
         ["rtjj_27_aaa_bbb_ccc_esat","_A_","LK_RTJJ_27_AAA_BBB_CCC","LK_RTJJ_27_AAA_BBB_CCC",null],
         ["rtjj_27_aaa_bbb_ccc_lnk","_A_","LK_RTJJ_27_AAA_BBB_CCC","LK_RTJJ_27_AAA_BBB_CCC",null],
         ["rtjj_27_aaa_bbb_ccc_lnk","_A_","HK_RTJJ_27_AAA","HK_RTJJ_27_AAA",null],
         ["rtjj_27_aaa_bbb_ccc_lnk","_A_","HK_RTJJ_27_BBB","HK_RTJJ_27_BBB",null],
         ["rtjj_27_aaa_bbb_ccc_lnk","_A_","HK_RTJJ_27_CCC","HK_RTJJ_27_CCC",null],
         ["rtjj_27_aaa_hub","_A_","HK_RTJJ_27_AAA","HK_RTJJ_27_AAA",null],
         ["rtjj_27_aaa_hub","_A_","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR"],
         ["rtjj_27_aaa_p1_sat","_A_","HK_RTJJ_27_AAA","HK_RTJJ_27_AAA",null],
         ["rtjj_27_aaa_p1_sat","_A_","RH_RTJJ_27_AAA_P1_SAT","RH_RTJJ_27_AAA_P1_SAT",null],
         ["rtjj_27_aaa_p1_sat","_A_","F2_AAA_SP1_VARCHAR","F2_AAA_SP1_VARCHAR","F2_AAA_SP1_VARCHAR"],
         ["rtjj_27_aaa_p1_sat","_A_","F3_AAA_SP1_DECIMAL","F3_AAA_SP1_DECIMAL","F3_AAA_SP1_DECIMAL"],
         ["rtjj_27_bbb_hub","_A_","HK_RTJJ_27_BBB","HK_RTJJ_27_BBB",null],
         ["rtjj_27_bbb_hub","_A_","F4_BK_BBB_DECIMAL","F4_BK_BBB_DECIMAL","F4_BK_BBB_DECIMAL"],
         ["rtjj_27_ccc_hub","_A_","HK_RTJJ_27_CCC","HK_RTJJ_27_CCC",null],
         ["rtjj_27_ccc_hub","_A_","F5_BK_CCC_VARCHAR","F5_BK_CCC_VARCHAR","F5_BK_CCC_VARCHAR"]
 ],
 "stage_table_column": [
         ["HK_RTJJ_27_AAA","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_27_BBB","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_27_CCC","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_27_AAA_BBB_CCC","CHAR(28)",2,null,null,false],
         ["RH_RTJJ_27_AAA_P1_SAT","CHAR(28)",3,null,null,false],
         ["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
         ["F2_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F2_AAA_SP1_VARCHAR","VARCHAR(200)",false],
         ["F3_AAA_SP1_DECIMAL","DECIMAL(5,0)",8,"F3_AAA_SP1_DECIMAL","DECIMAL(5,0)",false],
         ["F4_BK_BBB_DECIMAL","DECIMAL(20,0)",8,"F4_BK_BBB_DECIMAL","DECIMAL(20,0)",false],
         ["F5_BK_CCC_VARCHAR","VARCHAR(40)",8,"F5_BK_CCC_VARCHAR","VARCHAR(40)",false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_27_AAA","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","HK_RTJJ_27_BBB","F4_BK_BBB_DECIMAL",0,0],
         ["_A_","HK_RTJJ_27_CCC","F5_BK_CCC_VARCHAR",0,0],
         ["_A_","LK_RTJJ_27_AAA_BBB_CCC","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","LK_RTJJ_27_AAA_BBB_CCC","F4_BK_BBB_DECIMAL",0,0],
         ["_A_","LK_RTJJ_27_AAA_BBB_CCC","F5_BK_CCC_VARCHAR",0,0],
         ["_A_","RH_RTJJ_27_AAA_P1_SAT","F2_AAA_SP1_VARCHAR",0,0],
         ["_A_","RH_RTJJ_27_AAA_P1_SAT","F3_AAA_SP1_DECIMAL",0,0]
  ]    }');
