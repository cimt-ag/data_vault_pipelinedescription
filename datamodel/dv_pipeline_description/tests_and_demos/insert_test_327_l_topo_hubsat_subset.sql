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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test_327_l_topo_hubsat_subset';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test_327_l_topo_hubsat_subset','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test_327_l_topo_hubsat_subset",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		       {"field_name": "F01_ID_AAA1",   "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_327_aaa_hub"}]}
		      ,{"field_name": "F02_S_AAA1", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_327_aaa_sat"}]}	 	  
		      ,{"field_name": "F03_ID_BBB1_R12", "field_type": "Varchar(20)","targets": [{"table_name": "rtjj_327_bbb_hub" ,"column_name": "ID_BBB1"
																				 	,"relation_names":["R111","R222"]} ]}		 	  
		      ,{"field_name": "F04_ID_BBB1_R3","field_type": "Varchar(20)",  "targets": [{"table_name": "rtjj_327_bbb_hub" ,"column_name": "ID_BBB1"
																				 	,"relation_names":["R333"]} ]}		 	  
		      ,{"field_name": "F05_ID_BBB2_R1", "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_327_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R111"]} ]}	 
		      ,{"field_name": "F06_ID_BBB2_R2", "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_327_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R222"]} ]}	 
		      ,{"field_name": "F07_ID_BBB2_R3", "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_327_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R333"]} ]}
	 
		      ,{"field_name": "F08_S_BBB1_R1",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_327_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R111"]} ]}
		      ,{"field_name": "F09_S_BBB1_R23",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_327_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R222","R333"]} ]}
		      ,{"field_name": "F10_S_BBB2_R1",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtjj_327_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R111"]} ]}
		      ,{"field_name": "F11_S_BBB2_R2",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtjj_327_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R222"]} ]}
		      ,{"field_name": "F12_S_BBB2_R3",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtjj_327_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R333"]} ]}
 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables":  [
				{"table_name": "rtjj_327_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_327_aaa"}
				,{"table_name": "rtjj_327_aaa_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_327_aaa_hub"
																				,"diff_hash_column_name": "RH_rtjj_327_aaa_sat"}
				,{"table_name": "rtjj_327_aaa_bbb_r111_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtjj_327_aaa_bbb_r111",
												"link_parent_tables": [	"rtjj_327_aaa_hub","rtjj_327_bbb_hub"]}
				,{"table_name": "rtjj_327_aaa_bbb_r111_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_327_aaa_bbb_r111_lnk"
																						,"tracked_relation_name":"R111"}
				,{"table_name": "rtjj_327_aaa_bbb_r222_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtjj_327_aaa_bbb_r222",
												"link_parent_tables": [	"rtjj_327_aaa_hub","rtjj_327_bbb_hub"]}
				,{"table_name": "rtjj_327_aaa_bbb_r222_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_327_aaa_bbb_r222_lnk"
																						,"tracked_relation_name":"R222"}
				,{"table_name": "rtjj_327_aaa_bbb_r333_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtjj_327_aaa_bbb_r333",
												"link_parent_tables": [	"rtjj_327_aaa_hub","rtjj_327_bbb_hub"]}
				,{"table_name": "rtjj_327_aaa_bbb_r333_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_327_aaa_bbb_r333_lnk"
																						,"tracked_relation_name":"R333"}
				,{"table_name": "rtjj_327_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_327_bbb"}
				,{"table_name": "rtjj_327_bbb_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_327_bbb_hub"
																			,"diff_hash_column_name": "RH_rtjj_327_bbb_sat"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test_327_l_topo_hubsat_subset');

-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test_327_l_topo_hubsat_subset';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test_327_l_topo_hubsat_subset','{
 "dv_model_column": [
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r111_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r111_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r111_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r111_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r111_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r111_esat",2,"parent_key","LK_RTJJ_327_AAA_BBB_R111","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r111_lnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r111_lnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r111_lnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r111_lnk",2,"key","LK_RTJJ_327_AAA_BBB_R111","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r111_lnk",3,"parent_key","HK_RTJJ_327_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r111_lnk",3,"parent_key","HK_RTJJ_327_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r222_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r222_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r222_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r222_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r222_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r222_esat",2,"parent_key","LK_RTJJ_327_AAA_BBB_R222","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r222_lnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r222_lnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r222_lnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r222_lnk",2,"key","LK_RTJJ_327_AAA_BBB_R222","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r222_lnk",3,"parent_key","HK_RTJJ_327_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r222_lnk",3,"parent_key","HK_RTJJ_327_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r333_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r333_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r333_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r333_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r333_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r333_esat",2,"parent_key","LK_RTJJ_327_AAA_BBB_R333","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r333_lnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r333_lnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r333_lnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r333_lnk",2,"key","LK_RTJJ_327_AAA_BBB_R333","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r333_lnk",3,"parent_key","HK_RTJJ_327_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_bbb_r333_lnk",3,"parent_key","HK_RTJJ_327_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_327_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_327_aaa_hub",2,"key","HK_RTJJ_327_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_hub",8,"business_key","F01_ID_AAA1","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_327_aaa_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_aaa_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_327_aaa_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_327_aaa_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_327_aaa_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_aaa_sat",2,"parent_key","HK_RTJJ_327_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_sat",3,"diff_hash","RH_RTJJ_327_AAA_SAT","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_aaa_sat",8,"content","F02_S_AAA1","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_327_bbb_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_bbb_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_327_bbb_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_327_bbb_hub",2,"key","HK_RTJJ_327_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_bbb_hub",8,"business_key","ID_BBB1","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_327_bbb_hub",8,"business_key","ID_BBB2","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_327_bbb_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_bbb_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_327_bbb_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_327_bbb_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_327_bbb_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_327_bbb_sat",2,"parent_key","HK_RTJJ_327_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_bbb_sat",3,"diff_hash","RH_RTJJ_327_BBB_SAT","CHAR(28)"],
      ["rvlt_test_jj","rtjj_327_bbb_sat",8,"content","S_BBB1","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_327_bbb_sat",8,"content","S_BBB2","DECIMAL(12,2)"]
 ],
 "process_column_mapping": [
         ["rtjj_327_aaa_bbb_r111_esat","R111","LK_RTJJ_327_AAA_BBB_R111","LK_RTJJ_327_AAA_BBB_R111",null],
         ["rtjj_327_aaa_bbb_r111_lnk","R111","LK_RTJJ_327_AAA_BBB_R111","LK_RTJJ_327_AAA_BBB_R111",null],
         ["rtjj_327_aaa_bbb_r111_lnk","R111","HK_RTJJ_327_AAA","HK_RTJJ_327_AAA",null],
         ["rtjj_327_aaa_bbb_r111_lnk","R111","HK_RTJJ_327_BBB","HK_RTJJ_327_BBB_R111",null],
         ["rtjj_327_aaa_bbb_r222_esat","R222","LK_RTJJ_327_AAA_BBB_R222","LK_RTJJ_327_AAA_BBB_R222",null],
         ["rtjj_327_aaa_bbb_r222_lnk","R222","LK_RTJJ_327_AAA_BBB_R222","LK_RTJJ_327_AAA_BBB_R222",null],
         ["rtjj_327_aaa_bbb_r222_lnk","R222","HK_RTJJ_327_AAA","HK_RTJJ_327_AAA",null],
         ["rtjj_327_aaa_bbb_r222_lnk","R222","HK_RTJJ_327_BBB","HK_RTJJ_327_BBB_R222",null],
         ["rtjj_327_aaa_bbb_r333_esat","R333","LK_RTJJ_327_AAA_BBB_R333","LK_RTJJ_327_AAA_BBB_R333",null],
         ["rtjj_327_aaa_bbb_r333_lnk","R333","LK_RTJJ_327_AAA_BBB_R333","LK_RTJJ_327_AAA_BBB_R333",null],
         ["rtjj_327_aaa_bbb_r333_lnk","R333","HK_RTJJ_327_AAA","HK_RTJJ_327_AAA",null],
         ["rtjj_327_aaa_bbb_r333_lnk","R333","HK_RTJJ_327_BBB","HK_RTJJ_327_BBB_R333",null],
         ["rtjj_327_aaa_hub","/","HK_RTJJ_327_AAA","HK_RTJJ_327_AAA",null],
         ["rtjj_327_aaa_hub","/","F01_ID_AAA1","F01_ID_AAA1","F01_ID_AAA1"],
         ["rtjj_327_aaa_sat","/","HK_RTJJ_327_AAA","HK_RTJJ_327_AAA",null],
         ["rtjj_327_aaa_sat","/","RH_RTJJ_327_AAA_SAT","RH_RTJJ_327_AAA_SAT",null],
         ["rtjj_327_aaa_sat","/","F02_S_AAA1","F02_S_AAA1","F02_S_AAA1"],
         ["rtjj_327_bbb_hub","R111","HK_RTJJ_327_BBB","HK_RTJJ_327_BBB_R111",null],
         ["rtjj_327_bbb_hub","R111","ID_BBB1","F03_ID_BBB1_R12","F03_ID_BBB1_R12"],
         ["rtjj_327_bbb_hub","R111","ID_BBB2","F05_ID_BBB2_R1","F05_ID_BBB2_R1"],
         ["rtjj_327_bbb_hub","R222","HK_RTJJ_327_BBB","HK_RTJJ_327_BBB_R222",null],
         ["rtjj_327_bbb_hub","R222","ID_BBB1","F03_ID_BBB1_R12","F03_ID_BBB1_R12"],
         ["rtjj_327_bbb_hub","R222","ID_BBB2","F06_ID_BBB2_R2","F06_ID_BBB2_R2"],
         ["rtjj_327_bbb_hub","R333","HK_RTJJ_327_BBB","HK_RTJJ_327_BBB_R333",null],
         ["rtjj_327_bbb_hub","R333","ID_BBB1","F04_ID_BBB1_R3","F04_ID_BBB1_R3"],
         ["rtjj_327_bbb_hub","R333","ID_BBB2","F07_ID_BBB2_R3","F07_ID_BBB2_R3"],
         ["rtjj_327_bbb_sat","R111","HK_RTJJ_327_BBB","HK_RTJJ_327_BBB_R111",null],
         ["rtjj_327_bbb_sat","R111","RH_RTJJ_327_BBB_SAT","RH_RTJJ_327_BBB_SAT_R111",null],
         ["rtjj_327_bbb_sat","R111","S_BBB1","F08_S_BBB1_R1","F08_S_BBB1_R1"],
         ["rtjj_327_bbb_sat","R111","S_BBB2","F10_S_BBB2_R1","F10_S_BBB2_R1"],
         ["rtjj_327_bbb_sat","R222","HK_RTJJ_327_BBB","HK_RTJJ_327_BBB_R222",null],
         ["rtjj_327_bbb_sat","R222","RH_RTJJ_327_BBB_SAT","RH_RTJJ_327_BBB_SAT_R222",null],
         ["rtjj_327_bbb_sat","R222","S_BBB1","F09_S_BBB1_R23","F09_S_BBB1_R23"],
         ["rtjj_327_bbb_sat","R222","S_BBB2","F11_S_BBB2_R2","F11_S_BBB2_R2"],
         ["rtjj_327_bbb_sat","R333","HK_RTJJ_327_BBB","HK_RTJJ_327_BBB_R333",null],
         ["rtjj_327_bbb_sat","R333","RH_RTJJ_327_BBB_SAT","RH_RTJJ_327_BBB_SAT_R333",null],
         ["rtjj_327_bbb_sat","R333","S_BBB1","F09_S_BBB1_R23","F09_S_BBB1_R23"],
         ["rtjj_327_bbb_sat","R333","S_BBB2","F12_S_BBB2_R3","F12_S_BBB2_R3"]
 ],
 "stage_table_column": [
         ["HK_RTJJ_327_AAA","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_327_BBB_R111","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_327_BBB_R222","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_327_BBB_R333","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_327_AAA_BBB_R111","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_327_AAA_BBB_R222","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_327_AAA_BBB_R333","CHAR(28)",2,null,null,false],
         ["RH_RTJJ_327_AAA_SAT","CHAR(28)",3,null,null,false],
         ["RH_RTJJ_327_BBB_SAT_R111","CHAR(28)",3,null,null,false],
         ["RH_RTJJ_327_BBB_SAT_R222","CHAR(28)",3,null,null,false],
         ["RH_RTJJ_327_BBB_SAT_R333","CHAR(28)",3,null,null,false],
         ["F01_ID_AAA1","VARCHAR(20)",8,"F01_ID_AAA1","VARCHAR(20)",false],
         ["F02_S_AAA1","VARCHAR(20)",8,"F02_S_AAA1","VARCHAR(20)",false],
         ["F03_ID_BBB1_R12","VARCHAR(20)",8,"F03_ID_BBB1_R12","VARCHAR(20)",false],
         ["F04_ID_BBB1_R3","VARCHAR(20)",8,"F04_ID_BBB1_R3","VARCHAR(20)",false],
         ["F05_ID_BBB2_R1","VARCHAR(20)",8,"F05_ID_BBB2_R1","VARCHAR(20)",false],
         ["F06_ID_BBB2_R2","VARCHAR(20)",8,"F06_ID_BBB2_R2","VARCHAR(20)",false],
         ["F07_ID_BBB2_R3","VARCHAR(20)",8,"F07_ID_BBB2_R3","VARCHAR(20)",false],
         ["F08_S_BBB1_R1","VARCHAR(20)",8,"F08_S_BBB1_R1","VARCHAR(20)",false],
         ["F09_S_BBB1_R23","VARCHAR(20)",8,"F09_S_BBB1_R23","VARCHAR(20)",false],
         ["F10_S_BBB2_R1","DECIMAL(12,2)",8,"F10_S_BBB2_R1","DECIMAL(12,2)",false],
         ["F11_S_BBB2_R2","DECIMAL(12,2)",8,"F11_S_BBB2_R2","DECIMAL(12,2)",false],
         ["F12_S_BBB2_R3","DECIMAL(12,2)",8,"F12_S_BBB2_R3","DECIMAL(12,2)",false]
 ],
 "stage_hash_input_field": [
         ["/","HK_RTJJ_327_AAA","F01_ID_AAA1",50000,50000],
         ["/","RH_RTJJ_327_AAA_SAT","F02_S_AAA1",50000,50000],
         ["R111","HK_RTJJ_327_BBB_R111","F03_ID_BBB1_R12",50000,50000],
         ["R111","HK_RTJJ_327_BBB_R111","F05_ID_BBB2_R1",50000,50000],
         ["R111","LK_RTJJ_327_AAA_BBB_R111","F01_ID_AAA1",50000,50000],
         ["R111","LK_RTJJ_327_AAA_BBB_R111","F03_ID_BBB1_R12",50000,50000],
         ["R111","LK_RTJJ_327_AAA_BBB_R111","F05_ID_BBB2_R1",50000,50000],
         ["R111","RH_RTJJ_327_BBB_SAT_R111","F08_S_BBB1_R1",50000,50000],
         ["R111","RH_RTJJ_327_BBB_SAT_R111","F10_S_BBB2_R1",50000,50000],
         ["R222","HK_RTJJ_327_BBB_R222","F03_ID_BBB1_R12",50000,50000],
         ["R222","HK_RTJJ_327_BBB_R222","F06_ID_BBB2_R2",50000,50000],
         ["R222","LK_RTJJ_327_AAA_BBB_R222","F01_ID_AAA1",50000,50000],
         ["R222","LK_RTJJ_327_AAA_BBB_R222","F03_ID_BBB1_R12",50000,50000],
         ["R222","LK_RTJJ_327_AAA_BBB_R222","F06_ID_BBB2_R2",50000,50000],
         ["R222","RH_RTJJ_327_BBB_SAT_R222","F09_S_BBB1_R23",50000,50000],
         ["R222","RH_RTJJ_327_BBB_SAT_R222","F11_S_BBB2_R2",50000,50000],
         ["R333","HK_RTJJ_327_BBB_R333","F04_ID_BBB1_R3",50000,50000],
         ["R333","HK_RTJJ_327_BBB_R333","F07_ID_BBB2_R3",50000,50000],
         ["R333","LK_RTJJ_327_AAA_BBB_R333","F01_ID_AAA1",50000,50000],
         ["R333","LK_RTJJ_327_AAA_BBB_R333","F04_ID_BBB1_R3",50000,50000],
         ["R333","LK_RTJJ_327_AAA_BBB_R333","F07_ID_BBB2_R3",50000,50000],
         ["R333","RH_RTJJ_327_BBB_SAT_R333","F09_S_BBB1_R23",50000,50000],
         ["R333","RH_RTJJ_327_BBB_SAT_R333","F12_S_BBB2_R3",50000,50000]
 ],
 "xenc_process_column_mapping": [
 ],
 "xenc_process_field_to_encryption_key_mapping": [
  ]    }');