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
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test_702_r_topo_link_3_hubs_1_common';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test_702_r_topo_link_3_hubs_1_common','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test_702_r_topo_link_3_hubs_1_common",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		       {"field_name": "ID_ABC",   "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_702_aaa_hub"}
																						,{"table_name": "rtjj_702_bbb_hub"}
																						,{"table_name": "rtjj_702_ccc_hub"}	]}
		      ,{"field_name": "ID_AAA2", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_702_aaa_hub"}]}	 	  
		      ,{"field_name": "ID_BBB2_T", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_702_bbb_hub"
																						,"column_name": "ID_BBB2"
																				 		,"relation_names":["TTT"]} ] }	 	  
		      ,{"field_name": "ID_BBB2_U", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_702_bbb_hub"
																						,"column_name": "ID_BBB2"
																				 		,"relation_names":["UUU"]} ] }	 	  
		      ,{"field_name": "ID_CCC2", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_702_ccc_hub"}]}	 	  
		      ,{"field_name": "DT_AAA1", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_702_aaa_sat"}]}	 	  
		      ,{"field_name": "DT_BBB1", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_702_bbb_sat"}]}	 	  
		      ,{"field_name": "DT_CCC1", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_702_ccc_sat"}]}	 	  

			 ],
	"data_vault_model": [
		{
			"schema_name": "rvlt_test_jj", 
		 	"tables":  [
				{
					"table_name": "rtjj_702_aaa_hub"
					,"table_stereotype": "hub"
					,"hub_key_column_name": "HK_rtjj_702_aaa"
				}
				,{
					"table_name": "rtjj_702_aaa_sat"
					,"table_stereotype": "sat"
					,"satellite_parent_table": "rtjj_702_aaa_hub"
					,"diff_hash_column_name": "RH_rtjj_702_aaa_sat"
				}
				,{
					"table_name": "rtjj_702_bbb_hub"
					,"table_stereotype": "hub"
					,"hub_key_column_name": "HK_rtjj_702_bbb"
				}
				,{
					"table_name": "rtjj_702_bbb_sat"
					,"table_stereotype": "sat"
					,"satellite_parent_table": "rtjj_702_bbb_hub"
					,"diff_hash_column_name": "RH_rtjj_702_bbb_sat"
				}
				,{
					"table_name": "rtjj_702_ccc_hub"
					,"table_stereotype": "hub"
					,"hub_key_column_name": "HK_rtjj_702_ccc"
				}
				,{
					"table_name": "rtjj_702_ccc_sat"
					,"table_stereotype": "sat"
					,"satellite_parent_table": "rtjj_702_ccc_hub"
					,"diff_hash_column_name": "RH_rtjj_702_ccc_sat"
				}
				,{
					"table_name": "rtjj_702_aaa_bbb_ccc_lnk"
					,"table_stereotype": "lnk"
					,"link_key_column_name": "LK_rtjj_702_aaa_bbb_ccc"
					,"link_parent_tables": [{"table_name":"rtjj_702_aaa_hub"}
											,{"table_name":"rtjj_702_bbb_hub", "relation_name":"TTT"}
											,{"table_name":"rtjj_702_bbb_hub", "relation_name":"UUU"}
											,{"table_name":"rtjj_702_ccc_hub"}]
				}
				,{
					"table_name": "rtjj_702_aaa_bbb_ccc_esat"
					,"table_stereotype": "sat"
					,"satellite_parent_table": "rtjj_702_aaa_bbb_ccc_lnk"
				}
			]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test_702_r_topo_link_3_hubs_1_common');

-- select * from dv_pipeline_description.dvpd_check
-- vvvvv Reference data for automated testing of dvpd implementation vvvv
DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test_702_r_topo_link_3_hubs_1_common';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test_702_r_topo_link_3_hubs_1_common','{
 "dv_model_column": [
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_esat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_esat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_esat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_esat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_esat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_esat",2,"parent_key","LK_RTJJ_702_AAA_BBB_CCC","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_lnk",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_lnk",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_lnk",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_lnk",2,"key","LK_RTJJ_702_AAA_BBB_CCC","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_lnk",3,"parent_key","HK_RTJJ_702_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_lnk",3,"parent_key","HK_RTJJ_702_CCC","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_lnk",4,"parent_key","HK_RTJJ_702_BBB_TTT","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_aaa_bbb_ccc_lnk",4,"parent_key","HK_RTJJ_702_BBB_UUU","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_aaa_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_702_aaa_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_702_aaa_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_702_aaa_hub",2,"key","HK_RTJJ_702_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_aaa_hub",8,"business_key","ID_AAA2","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_702_aaa_hub",8,"business_key","ID_ABC","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_702_aaa_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_702_aaa_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_702_aaa_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_702_aaa_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_702_aaa_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_702_aaa_sat",2,"parent_key","HK_RTJJ_702_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_aaa_sat",3,"diff_hash","RH_RTJJ_702_AAA_SAT","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_aaa_sat",8,"content","DT_AAA1","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_702_bbb_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_702_bbb_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_702_bbb_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_702_bbb_hub",2,"key","HK_RTJJ_702_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_bbb_hub",8,"business_key","ID_ABC","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_702_bbb_hub",8,"business_key","ID_BBB2","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_702_bbb_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_702_bbb_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_702_bbb_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_702_bbb_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_702_bbb_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_702_bbb_sat",2,"parent_key","HK_RTJJ_702_BBB","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_bbb_sat",3,"diff_hash","RH_RTJJ_702_BBB_SAT","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_bbb_sat",8,"content","DT_BBB1","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_702_ccc_hub",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_702_ccc_hub",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_702_ccc_hub",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_702_ccc_hub",2,"key","HK_RTJJ_702_CCC","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_ccc_hub",8,"business_key","ID_ABC","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_702_ccc_hub",8,"business_key","ID_CCC2","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_702_ccc_sat",1,"meta","META_INSERTED_AT","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_702_ccc_sat",1,"meta","META_IS_DELETED","BOOLEAN"],
      ["rvlt_test_jj","rtjj_702_ccc_sat",1,"meta","META_JOB_INSTANCE_ID","INT8"],
      ["rvlt_test_jj","rtjj_702_ccc_sat",1,"meta","META_RECORD_SOURCE","VARCHAR(255)"],
      ["rvlt_test_jj","rtjj_702_ccc_sat",1,"meta","META_VALID_BEFORE","TIMESTAMP"],
      ["rvlt_test_jj","rtjj_702_ccc_sat",2,"parent_key","HK_RTJJ_702_CCC","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_ccc_sat",3,"diff_hash","RH_RTJJ_702_CCC_SAT","CHAR(28)"],
      ["rvlt_test_jj","rtjj_702_ccc_sat",8,"content","DT_CCC1","VARCHAR(20)"]
 ],
 "process_column_mapping": [
         ["rtjj_702_aaa_bbb_ccc_esat","/","LK_RTJJ_702_AAA_BBB_CCC","LK_RTJJ_702_AAA_BBB_CCC",null],
         ["rtjj_702_aaa_bbb_ccc_lnk","/","LK_RTJJ_702_AAA_BBB_CCC","LK_RTJJ_702_AAA_BBB_CCC",null],
         ["rtjj_702_aaa_bbb_ccc_lnk","/","HK_RTJJ_702_AAA","HK_RTJJ_702_AAA",null],
         ["rtjj_702_aaa_bbb_ccc_lnk","/","HK_RTJJ_702_CCC","HK_RTJJ_702_CCC",null],
         ["rtjj_702_aaa_bbb_ccc_lnk","/","HK_RTJJ_702_BBB_TTT","HK_RTJJ_702_BBB_TTT",null],
         ["rtjj_702_aaa_bbb_ccc_lnk","/","HK_RTJJ_702_BBB_UUU","HK_RTJJ_702_BBB_UUU",null],
         ["rtjj_702_aaa_hub","/","HK_RTJJ_702_AAA","HK_RTJJ_702_AAA",null],
         ["rtjj_702_aaa_hub","/","ID_AAA2","ID_AAA2","ID_AAA2"],
         ["rtjj_702_aaa_hub","/","ID_ABC","ID_ABC","ID_ABC"],
         ["rtjj_702_aaa_sat","/","HK_RTJJ_702_AAA","HK_RTJJ_702_AAA",null],
         ["rtjj_702_aaa_sat","/","RH_RTJJ_702_AAA_SAT","RH_RTJJ_702_AAA_SAT",null],
         ["rtjj_702_aaa_sat","/","DT_AAA1","DT_AAA1","DT_AAA1"],
         ["rtjj_702_bbb_hub","TTT","HK_RTJJ_702_BBB","HK_RTJJ_702_BBB_TTT",null],
         ["rtjj_702_bbb_hub","TTT","ID_ABC","ID_ABC","ID_ABC"],
         ["rtjj_702_bbb_hub","TTT","ID_BBB2","ID_BBB2_T","ID_BBB2_T"],
         ["rtjj_702_bbb_hub","UUU","HK_RTJJ_702_BBB","HK_RTJJ_702_BBB_UUU",null],
         ["rtjj_702_bbb_hub","UUU","ID_ABC","ID_ABC","ID_ABC"],
         ["rtjj_702_bbb_hub","UUU","ID_BBB2","ID_BBB2_U","ID_BBB2_U"],
         ["rtjj_702_bbb_sat","TTT","HK_RTJJ_702_BBB","HK_RTJJ_702_BBB_TTT",null],
         ["rtjj_702_bbb_sat","TTT","RH_RTJJ_702_BBB_SAT","RH_RTJJ_702_BBB_SAT",null],
         ["rtjj_702_bbb_sat","TTT","DT_BBB1","DT_BBB1","DT_BBB1"],
         ["rtjj_702_bbb_sat","UUU","HK_RTJJ_702_BBB","HK_RTJJ_702_BBB_UUU",null],
         ["rtjj_702_bbb_sat","UUU","RH_RTJJ_702_BBB_SAT","RH_RTJJ_702_BBB_SAT",null],
         ["rtjj_702_bbb_sat","UUU","DT_BBB1","DT_BBB1","DT_BBB1"],
         ["rtjj_702_ccc_hub","/","HK_RTJJ_702_CCC","HK_RTJJ_702_CCC",null],
         ["rtjj_702_ccc_hub","/","ID_ABC","ID_ABC","ID_ABC"],
         ["rtjj_702_ccc_hub","/","ID_CCC2","ID_CCC2","ID_CCC2"],
         ["rtjj_702_ccc_sat","/","HK_RTJJ_702_CCC","HK_RTJJ_702_CCC",null],
         ["rtjj_702_ccc_sat","/","RH_RTJJ_702_CCC_SAT","RH_RTJJ_702_CCC_SAT",null],
         ["rtjj_702_ccc_sat","/","DT_CCC1","DT_CCC1","DT_CCC1"]
 ],
 "stage_table_column": [
         ["HK_RTJJ_702_AAA","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_702_BBB_TTT","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_702_BBB_UUU","CHAR(28)",2,null,null,false],
         ["HK_RTJJ_702_CCC","CHAR(28)",2,null,null,false],
         ["LK_RTJJ_702_AAA_BBB_CCC","CHAR(28)",2,null,null,false],
         ["RH_RTJJ_702_AAA_SAT","CHAR(28)",3,null,null,false],
         ["RH_RTJJ_702_BBB_SAT","CHAR(28)",3,null,null,false],
         ["RH_RTJJ_702_CCC_SAT","CHAR(28)",3,null,null,false],
         ["DT_AAA1","VARCHAR(20)",8,"DT_AAA1","VARCHAR(20)",false],
         ["DT_BBB1","VARCHAR(20)",8,"DT_BBB1","VARCHAR(20)",false],
         ["DT_CCC1","VARCHAR(20)",8,"DT_CCC1","VARCHAR(20)",false],
         ["ID_AAA2","VARCHAR(20)",8,"ID_AAA2","VARCHAR(20)",false],
         ["ID_ABC","VARCHAR(20)",8,"ID_ABC","VARCHAR(20)",false],
         ["ID_BBB2_T","VARCHAR(20)",8,"ID_BBB2_T","VARCHAR(20)",false],
         ["ID_BBB2_U","VARCHAR(20)",8,"ID_BBB2_U","VARCHAR(20)",false],
         ["ID_CCC2","VARCHAR(20)",8,"ID_CCC2","VARCHAR(20)",false]
 ],
 "stage_hash_input_field": [
         ["/","HK_RTJJ_702_AAA","ID_AAA2",50000,50000],
         ["/","HK_RTJJ_702_AAA","ID_ABC",50000,50000],
         ["/","HK_RTJJ_702_CCC","ID_ABC",50000,50000],
         ["/","HK_RTJJ_702_CCC","ID_CCC2",50000,50000],
         ["/","LK_RTJJ_702_AAA_BBB_CCC","ID_AAA2",50000,50000],
         ["/","LK_RTJJ_702_AAA_BBB_CCC","ID_ABC",50000,50000],
         ["/","LK_RTJJ_702_AAA_BBB_CCC","ID_BBB2_T",50000,50000],
         ["/","LK_RTJJ_702_AAA_BBB_CCC","ID_BBB2_U",50000,50000],
         ["/","LK_RTJJ_702_AAA_BBB_CCC","ID_CCC2",50000,50000],
         ["/","RH_RTJJ_702_AAA_SAT","DT_AAA1",50000,50000],
         ["/","RH_RTJJ_702_CCC_SAT","DT_CCC1",50000,50000],
         ["TTT","HK_RTJJ_702_BBB_TTT","ID_ABC",50000,50000],
         ["TTT","HK_RTJJ_702_BBB_TTT","ID_BBB2_T",50000,50000],
         ["TTT","RH_RTJJ_702_BBB_SAT","DT_BBB1",50000,50000],
         ["UUU","HK_RTJJ_702_BBB_UUU","ID_ABC",50000,50000],
         ["UUU","HK_RTJJ_702_BBB_UUU","ID_BBB2_U",50000,50000]
 ],
 "xenc_process_column_mapping": [
 ],
 "xenc_process_field_to_encryption_key_mapping": [
  ]    }');
