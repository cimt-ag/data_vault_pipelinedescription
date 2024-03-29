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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test50_double_esat_relation_separation';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES('test50_double_esat_relation_separation', '{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test50_double_esat_relation_separation",
	"record_source_name_expression":"dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		{"field_name": "F1_BK_1",			"field_type": "Varchar(20)",  "field_position": "1", "uniqueness_groups": ["key"],
								"targets": [{"table_name": "rtjj_50_aaa_hub"},
									        {"table_name": "rtkk_50_bbb_hub"}]}

 		,{"field_name": "F2_BK_AAA_FIELDNAME",	"field_type": "Decimal(10,0)", "field_position": "2","uniqueness_groups": ["key"],
								"targets": [{"table_name": "rtjj_50_aaa_hub","column_name": "F2_BK_AAA_2"}]}

		,{"field_name": "F3_AAA_SP1",	"field_type": "Varchar(20)",	"field_position": "6",
								"targets": [{"table_name": "rtjj_50_aaa_p1_sat"}]}
 		
		,{"field_name": "F4_AAA_SP1",	"field_type": "DECIMAL(12,2)",	"field_position": "7",	
								"targets": [{"table_name": "rtjj_50_aaa_p1_sat"}]}

		,{"field_name": "F5_AAA_SP1",		"field_type": "VARCHAR(10)",	"field_position": "8",	
								"targets": [{"table_name": "rtjj_50_aaa_p1_sat"}]}

		,{"field_name": "F6_AAA_SP1_EXCLUDED_FROM_DIFF",	"field_type": "TIMESTAMP",		"field_position": "9",	
								"targets": [{"table_name": "rtjj_50_aaa_p1_sat","exclude_from_change_detection": "true"}]}

		,{"field_name": "F7_BK_BBB_2_L1",		"field_type": "DECIMAL(10,0)", "field_position": "3",
								"targets": [{"table_name": "rtkk_50_bbb_hub","column_name": "F7_BK_BBB_2","relation_names": ["R111"]}]}

		,{"field_name": "F8_BK_BBB_2_L2",	"field_type": "DECIMAL(10,0)",	"field_position": "4",
								"targets": [{"table_name": "rtkk_50_bbb_hub","column_name": "F7_BK_BBB_2","relation_names": ["R222"]}]}

		,{"field_name": "F9_BBB_SP1_L1",		"field_type": "VARCHAR(200)", "field_position": "5",
								"targets": [{"table_name": "rtkk_50_bbb_p1_sat","relation_names": ["R111"]}]}

	],
	"data_vault_model": [{
		"schema_name": "rvlt_test_jj",
			"tables": [
				{"table_name": "rtjj_50_aaa_hub",	"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_50_aaa"}
 				,{"table_name": "rtjj_50_aaa_p1_sat","table_stereotype": "sat","satellite_parent_table": "rtjj_50_aaa_hub","diff_hash_column_name": "RH_rtjj_50_aaa_p1_sat"}
				,{"table_name": "rtjj_50_aaa_rtjkk_bbb_lnk","table_stereotype": "lnk","link_key_column_name": "LK_rtjj_50_aaa_rtjkk_bbb"
																	,	"link_parent_tables": ["rtjj_50_aaa_hub","rtkk_50_bbb_hub"]}
				,{"table_name": "rtjj_50_aaa_rtjkk_bbb_g1_esat","table_stereotype": "sat","satellite_parent_table": "rtjj_50_aaa_rtjkk_bbb_lnk",
																		"tracked_relation_name": "R111",
																		"driving_keys": ["HK_rtjj_50_aaa"]}
				,{"table_name": "rtjj_50_aaa_rtjkk_bbb_g2_esat","table_stereotype": "sat","satellite_parent_table": "rtjj_50_aaa_rtjkk_bbb_lnk",
																		"tracked_relation_name": "R222",
																		"driving_keys": ["HK_rtjj_50_aaa"]}
			]
		},
		{"schema_name": "rvlt_test_kk",
			"tables": [
				{"table_name": "rtkk_50_bbb_hub",		 "table_stereotype": "hub","hub_key_column_name": "HK_rtkk_50_bbb"}
				,{"table_name": "rtkk_50_bbb_p1_sat",	 "table_stereotype": "sat","satellite_parent_table": "rtkk_50_bbb_hub"
																		,"diff_hash_column_name": "rh_rtkk_50_bbb_p1_sat"}
			]
		}
	]
}');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test50_double_esat_relation_separation');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test50_double_esat_relation_separation';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test50_double_esat_relation_separation','{
 "dv_model_column": [
         ["rvlt_test_jj","rtjj_50_aaa_hub",2,"key","HK_RTJJ_50_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_50_aaa_hub",8,"business_key","F1_BK_1","VARCHAR(20)"],
         ["rvlt_test_jj","rtjj_50_aaa_hub",8,"business_key","F2_BK_AAA_2","DECIMAL(10,0)"],
         ["rvlt_test_jj","rtjj_50_aaa_p1_sat",2,"parent_key","HK_RTJJ_50_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_50_aaa_p1_sat",3,"diff_hash","RH_RTJJ_50_AAA_P1_SAT","CHAR(28)"],
         ["rvlt_test_jj","rtjj_50_aaa_p1_sat",8,"content","F3_AAA_SP1","VARCHAR(20)"],
         ["rvlt_test_jj","rtjj_50_aaa_p1_sat",8,"content","F4_AAA_SP1","DECIMAL(12,2)"],
         ["rvlt_test_jj","rtjj_50_aaa_p1_sat",8,"content","F5_AAA_SP1","VARCHAR(10)"],
         ["rvlt_test_jj","rtjj_50_aaa_p1_sat",8,"content_untracked","F6_AAA_SP1_EXCLUDED_FROM_DIFF","TIMESTAMP"],
         ["rvlt_test_jj","rtjj_50_aaa_rtjkk_bbb_g1_esat",2,"parent_key","LK_RTJJ_50_AAA_RTJKK_BBB","CHAR(28)"],
         ["rvlt_test_jj","rtjj_50_aaa_rtjkk_bbb_g2_esat",2,"parent_key","LK_RTJJ_50_AAA_RTJKK_BBB","CHAR(28)"],
         ["rvlt_test_jj","rtjj_50_aaa_rtjkk_bbb_lnk",2,"key","LK_RTJJ_50_AAA_RTJKK_BBB","CHAR(28)"],
         ["rvlt_test_jj","rtjj_50_aaa_rtjkk_bbb_lnk",3,"parent_key","HK_RTJJ_50_AAA","CHAR(28)"],
         ["rvlt_test_jj","rtjj_50_aaa_rtjkk_bbb_lnk",3,"parent_key","HK_RTKK_50_BBB","CHAR(28)"],
         ["rvlt_test_kk","rtkk_50_bbb_hub",2,"key","HK_RTKK_50_BBB","CHAR(28)"],
         ["rvlt_test_kk","rtkk_50_bbb_hub",8,"business_key","F1_BK_1","VARCHAR(20)"],
         ["rvlt_test_kk","rtkk_50_bbb_hub",8,"business_key","F7_BK_BBB_2","DECIMAL(10,0)"],
         ["rvlt_test_kk","rtkk_50_bbb_p1_sat",2,"parent_key","HK_RTKK_50_BBB","CHAR(28)"],
         ["rvlt_test_kk","rtkk_50_bbb_p1_sat",3,"diff_hash","RH_RTKK_50_BBB_P1_SAT","CHAR(28)"],
         ["rvlt_test_kk","rtkk_50_bbb_p1_sat",8,"content","F9_BBB_SP1_L1","VARCHAR(200)"]
 ],
 "process_column_mapping": [
         ["rtjj_50_aaa_hub","_A_","HK_RTJJ_50_AAA","HK_RTJJ_50_AAA",null],
         ["rtjj_50_aaa_hub","_A_","F1_BK_1","F1_BK_1","F1_BK_1"],
         ["rtjj_50_aaa_hub","_A_","F2_BK_AAA_2","F2_BK_AAA_FIELDNAME","F2_BK_AAA_FIELDNAME"],
         ["rtjj_50_aaa_p1_sat","_A_","HK_RTJJ_50_AAA","HK_RTJJ_50_AAA",null],
         ["rtjj_50_aaa_p1_sat","_A_","RH_RTJJ_50_AAA_P1_SAT","RH_RTJJ_50_AAA_P1_SAT",null],
         ["rtjj_50_aaa_p1_sat","_A_","F3_AAA_SP1","F3_AAA_SP1","F3_AAA_SP1"],
         ["rtjj_50_aaa_p1_sat","_A_","F4_AAA_SP1","F4_AAA_SP1","F4_AAA_SP1"],
         ["rtjj_50_aaa_p1_sat","_A_","F5_AAA_SP1","F5_AAA_SP1","F5_AAA_SP1"],
         ["rtjj_50_aaa_p1_sat","_A_","F6_AAA_SP1_EXCLUDED_FROM_DIFF","F6_AAA_SP1_EXCLUDED_FROM_DIFF","F6_AAA_SP1_EXCLUDED_FROM_DIFF"],
         ["rtjj_50_aaa_rtjkk_bbb_g1_esat","R111","LK_RTJJ_50_AAA_RTJKK_BBB","LK_RTJJ_50_AAA_RTJKK_BBB_R111",null],
         ["rtjj_50_aaa_rtjkk_bbb_g2_esat","R222","LK_RTJJ_50_AAA_RTJKK_BBB","LK_RTJJ_50_AAA_RTJKK_BBB_R222",null],
         ["rtjj_50_aaa_rtjkk_bbb_lnk","R111","LK_RTJJ_50_AAA_RTJKK_BBB","LK_RTJJ_50_AAA_RTJKK_BBB_R111",null],
         ["rtjj_50_aaa_rtjkk_bbb_lnk","R111","HK_RTJJ_50_AAA","HK_RTJJ_50_AAA",null],
         ["rtjj_50_aaa_rtjkk_bbb_lnk","R111","HK_RTKK_50_BBB","HK_RTKK_50_BBB_R111",null],
         ["rtjj_50_aaa_rtjkk_bbb_lnk","R222","LK_RTJJ_50_AAA_RTJKK_BBB","LK_RTJJ_50_AAA_RTJKK_BBB_R222",null],
         ["rtjj_50_aaa_rtjkk_bbb_lnk","R222","HK_RTJJ_50_AAA","HK_RTJJ_50_AAA",null],
         ["rtjj_50_aaa_rtjkk_bbb_lnk","R222","HK_RTKK_50_BBB","HK_RTKK_50_BBB_R222",null],
         ["rtkk_50_bbb_hub","R111","HK_RTKK_50_BBB","HK_RTKK_50_BBB_R111",null],
         ["rtkk_50_bbb_hub","R111","F1_BK_1","F1_BK_1","F1_BK_1"],
         ["rtkk_50_bbb_hub","R111","F7_BK_BBB_2","F7_BK_BBB_2_L1","F7_BK_BBB_2_L1"],
         ["rtkk_50_bbb_hub","R222","HK_RTKK_50_BBB","HK_RTKK_50_BBB_R222",null],
         ["rtkk_50_bbb_hub","R222","F1_BK_1","F1_BK_1","F1_BK_1"],
         ["rtkk_50_bbb_hub","R222","F7_BK_BBB_2","F8_BK_BBB_2_L2","F8_BK_BBB_2_L2"],
         ["rtkk_50_bbb_p1_sat","R111","HK_RTKK_50_BBB","HK_RTKK_50_BBB_R111",null],
         ["rtkk_50_bbb_p1_sat","R111","RH_RTKK_50_BBB_P1_SAT","RH_RTKK_50_BBB_P1_SAT_R111",null],
         ["rtkk_50_bbb_p1_sat","R111","F9_BBB_SP1_L1","F9_BBB_SP1_L1","F9_BBB_SP1_L1"]
 ], 
"stage_table_column": [
         ["F1_BK_1","VARCHAR(20)",8,"F1_BK_1","VARCHAR(20)",false],
         ["F2_BK_AAA_FIELDNAME","DECIMAL(10,0)",8,"F2_BK_AAA_FIELDNAME","DECIMAL(10,0)",false],
         ["F3_AAA_SP1","VARCHAR(20)",8,"F3_AAA_SP1","VARCHAR(20)",false],
         ["F4_AAA_SP1","DECIMAL(12,2)",8,"F4_AAA_SP1","DECIMAL(12,2)",false],
         ["F5_AAA_SP1","VARCHAR(10)",8,"F5_AAA_SP1","VARCHAR(10)",false],
         ["F6_AAA_SP1_EXCLUDED_FROM_DIFF","TIMESTAMP",8,"F6_AAA_SP1_EXCLUDED_FROM_DIFF","TIMESTAMP",false],
         ["F7_BK_BBB_2_L1","DECIMAL(10,0)",8,"F7_BK_BBB_2_L1","DECIMAL(10,0)",false],
         ["F8_BK_BBB_2_L2","DECIMAL(10,0)",8,"F8_BK_BBB_2_L2","DECIMAL(10,0)",false],
         ["F9_BBB_SP1_L1","VARCHAR(200)",8,"F9_BBB_SP1_L1","VARCHAR(200)",false],
         ["HK_RTJJ_50_AAA","CHAR(28)",2,null,null,false],
         ["HK_RTKK_50_BBB_R111","CHAR(28)",2,null,null,false],
         ["HK_RTKK_50_BBB_R222","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_50_AAA_RTJKK_BBB_R111","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_50_AAA_RTJKK_BBB_R222","CHAR(28)",2,null,null,false],
         ["RH_RTJJ_50_AAA_P1_SAT","CHAR(28)",3,null,null,false],
         ["RH_RTKK_50_BBB_P1_SAT_R111","CHAR(28)",3,null,null,false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_50_AAA","F1_BK_1",0,0],
         ["_A_","HK_RTJJ_50_AAA","F2_BK_AAA_FIELDNAME",0,0],
         ["_A_","RH_RTJJ_50_AAA_P1_SAT","F3_AAA_SP1",0,0],
         ["_A_","RH_RTJJ_50_AAA_P1_SAT","F4_AAA_SP1",0,0],
         ["_A_","RH_RTJJ_50_AAA_P1_SAT","F5_AAA_SP1",0,0],
         ["R111","HK_RTKK_50_BBB_R111","F1_BK_1",0,0],
         ["R111","HK_RTKK_50_BBB_R111","F7_BK_BBB_2_L1",0,0],
         ["R111","LK_RTJJ_50_AAA_RTJKK_BBB_R111","F1_BK_1",0,0],
         ["R111","LK_RTJJ_50_AAA_RTJKK_BBB_R111","F2_BK_AAA_FIELDNAME",0,0],
         ["R111","LK_RTJJ_50_AAA_RTJKK_BBB_R111","F7_BK_BBB_2_L1",0,0],
         ["R111","RH_RTKK_50_BBB_P1_SAT_R111","F9_BBB_SP1_L1",0,0],
         ["R222","HK_RTKK_50_BBB_R222","F1_BK_1",0,0],
         ["R222","HK_RTKK_50_BBB_R222","F8_BK_BBB_2_L2",0,0],
         ["R222","LK_RTJJ_50_AAA_RTJKK_BBB_R222","F1_BK_1",0,0],
         ["R222","LK_RTJJ_50_AAA_RTJKK_BBB_R222","F2_BK_AAA_FIELDNAME",0,0],
         ["R222","LK_RTJJ_50_AAA_RTJKK_BBB_R222","F8_BK_BBB_2_L2",0,0]
  ]    }');