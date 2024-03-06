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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'etst_100_r_topo_2_to_2';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('etst_100_r_topo_2_to_2','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "etst_100_r_topo_2_to_2",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		       {"field_name": "F01_ID_AAA1_Q1",   "field_type": "Varchar(20)",	"targets": [{"table_name": "rtee_220_aaa_hub","column_name": "ID_AAA1"
																				 	,"relation_names":["Q111"]} ]}
		      ,{"field_name": "F01_ID_AAA1_Q2",   "field_type": "Varchar(20)",	"targets": [{"table_name": "rtee_220_aaa_hub","column_name": "ID_AAA1"
																				 	,"relation_names":["Q222"]} ]}
		      ,{"field_name": "F02_S_AAA1_Q2", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtee_220_aaa_sat","column_name": "S_AAA1"
																					,"relation_names":["Q222"]}]}	 	  
		      ,{"field_name": "F03_ID_BBB1_R1", "field_type": "Varchar(20)","targets": [{"table_name": "rtee_220_bbb_hub" ,"column_name": "ID_BBB1"
																				 	,"relation_names":["R111"]} ]}		 	  
		      ,{"field_name": "F04_ID_BBB1_R2", "field_type": "Varchar(20)","targets": [{"table_name": "rtee_220_bbb_hub" ,"column_name": "ID_BBB1"
																				 	,"relation_names":["R222"]} ]}		 	  
		      ,{"field_name": "F06_ID_BBB2_R1", "field_type": "Varchar(20)", "targets": [{"table_name": "rtee_220_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R111"]} ]}	 
		      ,{"field_name": "F07_ID_BBB2_R2", "field_type": "Varchar(20)", "targets": [{"table_name": "rtee_220_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R222"]} ]}	 
	 
		      ,{"field_name": "F09_S_BBB1_R1",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtee_220_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R111"]} ]}
		      ,{"field_name": "F10_S_BBB1_R2",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtee_220_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R222"]} ]}
		      ,{"field_name": "F12_S_BBB2_R1",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtee_220_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R111"]} ]}
		      ,{"field_name": "F13_S_BBB2_R2",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtee_220_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R222"]} ]}
 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_ee", 
		 "tables":  [
				{"table_name": "rtee_220_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtee_220_aaa"}
				,{"table_name": "rtee_220_aaa_sat",	"table_stereotype": "sat","satellite_parent_table": "rtee_220_aaa_hub"
																				,"diff_hash_column_name": "RH_rtee_220_aaa_sat"}
				,{"table_name": "rtee_220_aaa_bbb_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtee_220_aaa_bbb",
												"link_parent_tables": [	{"table_name":"rtee_220_aaa_hub","relation_name":"Q111"}
																	   ,{"table_name":"rtee_220_aaa_hub","relation_name":"Q222"}
																	   ,{"table_name":"rtee_220_bbb_hub","relation_name":"R111"}
																	   ,{"table_name":"rtee_220_bbb_hub","relation_name":"R222"}
																	     ]}
				,{"table_name": "rtee_220_aaa_bbb_esat",	"table_stereotype": "sat","satellite_parent_table": "rtee_220_aaa_bbb_lnk"}
				,{"table_name": "rtee_220_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtee_220_bbb"}
				,{"table_name": "rtee_220_bbb_sat",	"table_stereotype": "sat","satellite_parent_table": "rtee_220_bbb_hub"
																			,"diff_hash_column_name": "RH_rtee_220_bbb_sat"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('etst_100_r_topo_2_to_2');

-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'etst_100_r_topo_2_to_2';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('etst_100_r_topo_2_to_2','{
 "dv_model_column": [
      ["rvlt_test_ee","rtee_220_aaa_bbb_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_ee","rtee_220_aaa_bbb_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_ee","rtee_220_aaa_bbb_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_ee","rtee_220_aaa_bbb_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_ee","rtee_220_aaa_bbb_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_ee","rtee_220_aaa_bbb_esat",2,"parent_key","LK_RTEE_220_AAA_BBB","CHAR(28)"],
      ["rvlt_test_ee","rtee_220_aaa_bbb_lnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_ee","rtee_220_aaa_bbb_lnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_ee","rtee_220_aaa_bbb_lnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_ee","rtee_220_aaa_bbb_lnk",2,"key","LK_RTEE_220_AAA_BBB","CHAR(28)"],
      ["rvlt_test_ee","rtee_220_aaa_bbb_lnk",4,"parent_key","HK_RTEE_220_AAA_Q111","CHAR(28)"],
      ["rvlt_test_ee","rtee_220_aaa_bbb_lnk",4,"parent_key","HK_RTEE_220_AAA_Q222","CHAR(28)"],
      ["rvlt_test_ee","rtee_220_aaa_bbb_lnk",4,"parent_key","HK_RTEE_220_BBB_R111","CHAR(28)"],
      ["rvlt_test_ee","rtee_220_aaa_bbb_lnk",4,"parent_key","HK_RTEE_220_BBB_R222","CHAR(28)"],
      ["rvlt_test_ee","rtee_220_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_ee","rtee_220_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_ee","rtee_220_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_ee","rtee_220_aaa_hub",2,"key","HK_RTEE_220_AAA","CHAR(28)"],
      ["rvlt_test_ee","rtee_220_aaa_hub",8,"business_key","ID_AAA1","VARCHAR(20)"],
      ["rvlt_test_ee","rtee_220_aaa_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_ee","rtee_220_aaa_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_ee","rtee_220_aaa_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_ee","rtee_220_aaa_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_ee","rtee_220_aaa_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_ee","rtee_220_aaa_sat",2,"parent_key","HK_RTEE_220_AAA","CHAR(28)"],
      ["rvlt_test_ee","rtee_220_aaa_sat",3,"diff_hash","RH_RTEE_220_AAA_SAT","CHAR(28)"],
      ["rvlt_test_ee","rtee_220_aaa_sat",8,"content","S_AAA1","VARCHAR(20)"],
      ["rvlt_test_ee","rtee_220_bbb_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_ee","rtee_220_bbb_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_ee","rtee_220_bbb_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_ee","rtee_220_bbb_hub",2,"key","HK_RTEE_220_BBB","CHAR(28)"],
      ["rvlt_test_ee","rtee_220_bbb_hub",8,"business_key","ID_BBB1","VARCHAR(20)"],
      ["rvlt_test_ee","rtee_220_bbb_hub",8,"business_key","ID_BBB2","VARCHAR(20)"],
      ["rvlt_test_ee","rtee_220_bbb_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_ee","rtee_220_bbb_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_ee","rtee_220_bbb_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_ee","rtee_220_bbb_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_ee","rtee_220_bbb_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_ee","rtee_220_bbb_sat",2,"parent_key","HK_RTEE_220_BBB","CHAR(28)"],
      ["rvlt_test_ee","rtee_220_bbb_sat",3,"diff_hash","RH_RTEE_220_BBB_SAT","CHAR(28)"],
      ["rvlt_test_ee","rtee_220_bbb_sat",8,"content","S_BBB1","VARCHAR(20)"],
      ["rvlt_test_ee","rtee_220_bbb_sat",8,"content","S_BBB2","DECIMAL(12,2)"]
 ],
 "process_column_mapping": [
         ["rtee_220_aaa_bbb_esat","/","LK_RTEE_220_AAA_BBB","LK_RTEE_220_AAA_BBB",null],
         ["rtee_220_aaa_bbb_lnk","/","LK_RTEE_220_AAA_BBB","LK_RTEE_220_AAA_BBB",null],
         ["rtee_220_aaa_bbb_lnk","/","HK_RTEE_220_AAA_Q111","HK_RTEE_220_AAA_Q111",null],
         ["rtee_220_aaa_bbb_lnk","/","HK_RTEE_220_AAA_Q222","HK_RTEE_220_AAA_Q222",null],
         ["rtee_220_aaa_bbb_lnk","/","HK_RTEE_220_BBB_R111","HK_RTEE_220_BBB_R111",null],
         ["rtee_220_aaa_bbb_lnk","/","HK_RTEE_220_BBB_R222","HK_RTEE_220_BBB_R222",null],
         ["rtee_220_aaa_hub","Q111","HK_RTEE_220_AAA","HK_RTEE_220_AAA_Q111",null],
         ["rtee_220_aaa_hub","Q111","ID_AAA1","F01_ID_AAA1_Q1","F01_ID_AAA1_Q1"],
         ["rtee_220_aaa_hub","Q222","HK_RTEE_220_AAA","HK_RTEE_220_AAA_Q222",null],
         ["rtee_220_aaa_hub","Q222","ID_AAA1","F01_ID_AAA1_Q2","F01_ID_AAA1_Q2"],
         ["rtee_220_aaa_sat","Q222","HK_RTEE_220_AAA","HK_RTEE_220_AAA_Q222",null],
         ["rtee_220_aaa_sat","Q222","RH_RTEE_220_AAA_SAT","RH_RTEE_220_AAA_SAT_Q222",null],
         ["rtee_220_aaa_sat","Q222","S_AAA1","F02_S_AAA1_Q2","F02_S_AAA1_Q2"],
         ["rtee_220_bbb_hub","R111","HK_RTEE_220_BBB","HK_RTEE_220_BBB_R111",null],
         ["rtee_220_bbb_hub","R111","ID_BBB1","F03_ID_BBB1_R1","F03_ID_BBB1_R1"],
         ["rtee_220_bbb_hub","R111","ID_BBB2","F06_ID_BBB2_R1","F06_ID_BBB2_R1"],
         ["rtee_220_bbb_hub","R222","HK_RTEE_220_BBB","HK_RTEE_220_BBB_R222",null],
         ["rtee_220_bbb_hub","R222","ID_BBB1","F04_ID_BBB1_R2","F04_ID_BBB1_R2"],
         ["rtee_220_bbb_hub","R222","ID_BBB2","F07_ID_BBB2_R2","F07_ID_BBB2_R2"],
         ["rtee_220_bbb_sat","R111","HK_RTEE_220_BBB","HK_RTEE_220_BBB_R111",null],
         ["rtee_220_bbb_sat","R111","RH_RTEE_220_BBB_SAT","RH_RTEE_220_BBB_SAT_R111",null],
         ["rtee_220_bbb_sat","R111","S_BBB1","F09_S_BBB1_R1","F09_S_BBB1_R1"],
         ["rtee_220_bbb_sat","R111","S_BBB2","F12_S_BBB2_R1","F12_S_BBB2_R1"],
         ["rtee_220_bbb_sat","R222","HK_RTEE_220_BBB","HK_RTEE_220_BBB_R222",null],
         ["rtee_220_bbb_sat","R222","RH_RTEE_220_BBB_SAT","RH_RTEE_220_BBB_SAT_R222",null],
         ["rtee_220_bbb_sat","R222","S_BBB1","F10_S_BBB1_R2","F10_S_BBB1_R2"],
         ["rtee_220_bbb_sat","R222","S_BBB2","F13_S_BBB2_R2","F13_S_BBB2_R2"]
 ],
 "stage_table_column": [
         ["HK_RTEE_220_AAA_Q111","CHAR(28)",2,null,null,false],
         ["HK_RTEE_220_AAA_Q222","CHAR(28)",2,null,null,false],
         ["HK_RTEE_220_BBB_R111","CHAR(28)",2,null,null,false],
         ["HK_RTEE_220_BBB_R222","CHAR(28)",2,null,null,false],
         ["LK_RTEE_220_AAA_BBB","CHAR(28)",2,null,null,false],
         ["RH_RTEE_220_AAA_SAT_Q222","CHAR(28)",3,null,null,false],
         ["RH_RTEE_220_BBB_SAT_R111","CHAR(28)",3,null,null,false],
         ["RH_RTEE_220_BBB_SAT_R222","CHAR(28)",3,null,null,false],
         ["F01_ID_AAA1_Q1","VARCHAR(20)",8,"F01_ID_AAA1_Q1","VARCHAR(20)",false],
         ["F01_ID_AAA1_Q2","VARCHAR(20)",8,"F01_ID_AAA1_Q2","VARCHAR(20)",false],
         ["F02_S_AAA1_Q2","VARCHAR(20)",8,"F02_S_AAA1_Q2","VARCHAR(20)",false],
         ["F03_ID_BBB1_R1","VARCHAR(20)",8,"F03_ID_BBB1_R1","VARCHAR(20)",false],
         ["F04_ID_BBB1_R2","VARCHAR(20)",8,"F04_ID_BBB1_R2","VARCHAR(20)",false],
         ["F06_ID_BBB2_R1","VARCHAR(20)",8,"F06_ID_BBB2_R1","VARCHAR(20)",false],
         ["F07_ID_BBB2_R2","VARCHAR(20)",8,"F07_ID_BBB2_R2","VARCHAR(20)",false],
         ["F09_S_BBB1_R1","VARCHAR(20)",8,"F09_S_BBB1_R1","VARCHAR(20)",false],
         ["F10_S_BBB1_R2","VARCHAR(20)",8,"F10_S_BBB1_R2","VARCHAR(20)",false],
         ["F12_S_BBB2_R1","DECIMAL(12,2)",8,"F12_S_BBB2_R1","DECIMAL(12,2)",false],
         ["F13_S_BBB2_R2","DECIMAL(12,2)",8,"F13_S_BBB2_R2","DECIMAL(12,2)",false]
 ],
 "stage_hash_input_field": [
         ["/","LK_RTEE_220_AAA_BBB","F01_ID_AAA1_Q1",50000,50000],
         ["/","LK_RTEE_220_AAA_BBB","F01_ID_AAA1_Q2",50000,50000],
         ["/","LK_RTEE_220_AAA_BBB","F03_ID_BBB1_R1",50000,50000],
         ["/","LK_RTEE_220_AAA_BBB","F04_ID_BBB1_R2",50000,50000],
         ["/","LK_RTEE_220_AAA_BBB","F06_ID_BBB2_R1",50000,50000],
         ["/","LK_RTEE_220_AAA_BBB","F07_ID_BBB2_R2",50000,50000],
         ["Q111","HK_RTEE_220_AAA_Q111","F01_ID_AAA1_Q1",50000,50000],
         ["Q222","HK_RTEE_220_AAA_Q222","F01_ID_AAA1_Q2",50000,50000],
         ["Q222","RH_RTEE_220_AAA_SAT_Q222","F02_S_AAA1_Q2",50000,50000],
         ["R111","HK_RTEE_220_BBB_R111","F03_ID_BBB1_R1",50000,50000],
         ["R111","HK_RTEE_220_BBB_R111","F06_ID_BBB2_R1",50000,50000],
         ["R111","RH_RTEE_220_BBB_SAT_R111","F09_S_BBB1_R1",50000,50000],
         ["R111","RH_RTEE_220_BBB_SAT_R111","F12_S_BBB2_R1",50000,50000],
         ["R222","HK_RTEE_220_BBB_R222","F04_ID_BBB1_R2",50000,50000],
         ["R222","HK_RTEE_220_BBB_R222","F07_ID_BBB2_R2",50000,50000],
         ["R222","RH_RTEE_220_BBB_SAT_R222","F10_S_BBB1_R2",50000,50000],
         ["R222","RH_RTEE_220_BBB_SAT_R222","F13_S_BBB2_R2",50000,50000]
 ],
 "xenc_process_column_mapping": [
 ],
 "xenc_process_field_to_encryption_key_mapping": [
  ]    }');
