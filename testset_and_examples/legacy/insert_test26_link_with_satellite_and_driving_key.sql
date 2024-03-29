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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test26_link_with_satellite_and_driving_key';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test26_link_with_satellite_and_driving_key','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test26_link_with_satellite_and_driving_key",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		       {"field_name": "F1_BK_AAA_VARCHAR", 	"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_26_aaa_hub"}]}
		 	  ,{"field_name": "F2_BK_BBB_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_26_bbb_hub"}]}
		 	  ,{"field_name": "F3_AAA_SP1_VARCHAR",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_26_aaa_bbb_sat"}]}
			  ,{"field_name": "F4_AAA_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_26_aaa_bbb_sat"}]}
			  ,{"field_name": "F5__FIELD_NAME",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_26_aaa_bbb_sat",
																									 "column_name":"F5_AAA_SP1_VARCHAR"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_26_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_26_aaa"}
				,{"table_name": "rtjj_26_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_26_bbb"}
				,{"table_name": "rtjj_26_aaa_bbb_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtjj_26_aaa_bbb",
																				"link_parent_tables": ["rtjj_26_aaa_hub","rtjj_26_bbb_hub"]}
				,{"table_name": "rtjj_26_aaa_bbb_sat",	"table_stereotype": "sat"	,"satellite_parent_table": "rtjj_26_aaa_bbb_lnk"
																			,"diff_hash_column_name": "RH_rtjj_26_aaa_bbb_sat"
																			,"driving_keys": ["HK_rtjj_26_aaa"]}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test26_link_with_satellite_and_driving_key');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test26_link_with_satellite_and_driving_key';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test26_link_with_satellite_and_driving_key','{
	"dv_model_column": [
		["rvlt_test_jj","rtjj_26_aaa_bbb_lnk",2,"key","LK_RTJJ_26_AAA_BBB","CHAR(28)"],          
		["rvlt_test_jj","rtjj_26_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_26_AAA","CHAR(28)"],       
		["rvlt_test_jj","rtjj_26_aaa_bbb_lnk",3,"parent_key","HK_RTJJ_26_BBB","CHAR(28)"],       
		["rvlt_test_jj","rtjj_26_aaa_bbb_sat",2,"parent_key","LK_RTJJ_26_AAA_BBB","CHAR(28)"],   
		["rvlt_test_jj","rtjj_26_aaa_bbb_sat",3,"diff_hash","RH_RTJJ_26_AAA_BBB_SAT","CHAR(28)"],
		["rvlt_test_jj","rtjj_26_aaa_bbb_sat",8,"content","F3_AAA_SP1_VARCHAR","VARCHAR(200)"],  
		["rvlt_test_jj","rtjj_26_aaa_bbb_sat",8,"content","F4_AAA_SP1_DECIMAL","DECIMAL(5,0)"],  
		["rvlt_test_jj","rtjj_26_aaa_bbb_sat",8,"content","F5_AAA_SP1_VARCHAR","VARCHAR(200)"],  
		["rvlt_test_jj","rtjj_26_aaa_hub",2,"key","HK_RTJJ_26_AAA","CHAR(28)"],                  
		["rvlt_test_jj","rtjj_26_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"],   
		["rvlt_test_jj","rtjj_26_bbb_hub",2,"key","HK_RTJJ_26_BBB","CHAR(28)"],                  
		["rvlt_test_jj","rtjj_26_bbb_hub",8,"business_key","F2_BK_BBB_DECIMAL","DECIMAL(20,0)"] 
],
 "process_column_mapping": [
         ["rtjj_26_aaa_bbb_lnk","_A_","LK_RTJJ_26_AAA_BBB","LK_RTJJ_26_AAA_BBB",null],
         ["rtjj_26_aaa_bbb_lnk","_A_","HK_RTJJ_26_AAA","HK_RTJJ_26_AAA",null],
         ["rtjj_26_aaa_bbb_lnk","_A_","HK_RTJJ_26_BBB","HK_RTJJ_26_BBB",null],
         ["rtjj_26_aaa_bbb_sat","_A_","LK_RTJJ_26_AAA_BBB","LK_RTJJ_26_AAA_BBB",null],
         ["rtjj_26_aaa_bbb_sat","_A_","RH_RTJJ_26_AAA_BBB_SAT","RH_RTJJ_26_AAA_BBB_SAT",null],
         ["rtjj_26_aaa_bbb_sat","_A_","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR"],
         ["rtjj_26_aaa_bbb_sat","_A_","F4_AAA_SP1_DECIMAL","F4_AAA_SP1_DECIMAL","F4_AAA_SP1_DECIMAL"],
         ["rtjj_26_aaa_bbb_sat","_A_","F5_AAA_SP1_VARCHAR","F5__FIELD_NAME","F5__FIELD_NAME"],
         ["rtjj_26_aaa_hub","_A_","HK_RTJJ_26_AAA","HK_RTJJ_26_AAA",null],
         ["rtjj_26_aaa_hub","_A_","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR"],
         ["rtjj_26_bbb_hub","_A_","HK_RTJJ_26_BBB","HK_RTJJ_26_BBB",null],
         ["rtjj_26_bbb_hub","_A_","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL","F2_BK_BBB_DECIMAL"]
 ],
 "stage_table_column": [
		["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],      
		["F2_BK_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_BK_BBB_DECIMAL","DECIMAL(20,0)",false],  
		["F3_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F3_AAA_SP1_VARCHAR","VARCHAR(200)",false],  
		["F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",8,"F4_AAA_SP1_DECIMAL","DECIMAL(5,0)",false],  
		["F5__FIELD_NAME","VARCHAR(200)",8,"F5__FIELD_NAME","VARCHAR(200)",false],
		["HK_RTJJ_26_AAA","CHAR(28)",2,null,null,false],                                    
		["HK_RTJJ_26_BBB","CHAR(28)",2,null,null,false],                                    
		["LK_RTJJ_26_AAA_BBB","CHAR(28)",2,null,null,false],                                
		["RH_RTJJ_26_AAA_BBB_SAT","CHAR(28)",3,null,null,false]                           
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_26_AAA","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","HK_RTJJ_26_BBB","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","LK_RTJJ_26_AAA_BBB","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","LK_RTJJ_26_AAA_BBB","F2_BK_BBB_DECIMAL",0,0],
         ["_A_","RH_RTJJ_26_AAA_BBB_SAT","F3_AAA_SP1_VARCHAR",0,0],
         ["_A_","RH_RTJJ_26_AAA_BBB_SAT","F4_AAA_SP1_DECIMAL",0,0],
         ["_A_","RH_RTJJ_26_AAA_BBB_SAT","F5__FIELD_NAME",0,0]
  ]    }');
