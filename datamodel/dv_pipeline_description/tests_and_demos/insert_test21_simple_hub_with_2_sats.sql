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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test21_simple_hub_with_2_sats';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test21_simple_hub_with_2_sats','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test21_simple_hub_with_2_sats",
	"record_source_name_expression": "dvpd implementation test",
	"stage_properties" : [{"storage_component":"PostgresDWH","stage_schema":"stage_rvlt"}],
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_21_aaa_hub"}]},
		 	  {"field_name": "F2_BK_AAA_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_21_aaa_hub"}]},
		 	  {"field_name": "F3_AAA_SP1_VARCHAR",		"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_21_aaa_p1_sat"}]},
			  {"field_name": "F4_AAA_SP2_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_21_aaa_p2_sat"}]},
			  {"field_name": "F5_AAA_SP1_AND_SP2_DECIMAL",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_21_aaa_p1_sat"},{"table_name": "rtjj_21_aaa_p2_sat"}]},
			  {"field_name": "F6_AAA_SP1_TIMESTAMP_XRH",	"field_type": "TIMESTAMP",		"targets": [{"table_name": "rtjj_21_aaa_p1_sat","exclude_from_change_detection": "true"}]},
		 	  {"field_name": "F7_AAA_SP2_VARCHAR",		"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_21_aaa_p2_sat"}]},
			  {"field_name": "F8_AAA_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_21_aaa_p1_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_21_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_21_aaa"}
				,{"table_name": "rtjj_21_aaa_p1_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_21_aaa_HUB","diff_hash_column_name": "RH_rtjj_21_aaa_P1_SAT"}
				,{"table_name": "rtjj_21_aaa_p2_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_21_aaa_HUB","diff_hash_column_name": "RH_rtjj_21_aaa_P2_SAT"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test21_simple_hub_with_2_sats');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test21_simple_hub_with_2_sats';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test21_simple_hub_with_2_sats','{
	"dv_model_column": [
		["rvlt_test_jj","rtjj_21_aaa_hub",2,"key","HK_RTJJ_21_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_21_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"],
		["rvlt_test_jj","rtjj_21_aaa_hub",8,"business_key","F2_BK_AAA_DECIMAL","DECIMAL(20,0)"],
		["rvlt_test_jj","rtjj_21_aaa_p1_sat",2,"parent_key","HK_RTJJ_21_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_21_aaa_p1_sat",3,"diff_hash","RH_RTJJ_21_AAA_P1_SAT","CHAR(28)"],
		["rvlt_test_jj","rtjj_21_aaa_p1_sat",8,"content","F3_AAA_SP1_VARCHAR","VARCHAR(200)"],
		["rvlt_test_jj","rtjj_21_aaa_p1_sat",8,"content","F5_AAA_SP1_AND_SP2_DECIMAL","VARCHAR(200)"],
		["rvlt_test_jj","rtjj_21_aaa_p1_sat",8,"content","F8_AAA_SP1_DECIMAL","DECIMAL(5,0)"],
		["rvlt_test_jj","rtjj_21_aaa_p1_sat",8,"content_untracked","F6_AAA_SP1_TIMESTAMP_XRH","TIMESTAMP"],
		["rvlt_test_jj","rtjj_21_aaa_p2_sat",2,"parent_key","HK_RTJJ_21_AAA","CHAR(28)"],
		["rvlt_test_jj","rtjj_21_aaa_p2_sat",3,"diff_hash","RH_RTJJ_21_AAA_P2_SAT","CHAR(28)"],
		["rvlt_test_jj","rtjj_21_aaa_p2_sat",8,"content","F4_AAA_SP2_DECIMAL","DECIMAL(5,0)"],
		["rvlt_test_jj","rtjj_21_aaa_p2_sat",8,"content","F5_AAA_SP1_AND_SP2_DECIMAL","VARCHAR(200)"],
		["rvlt_test_jj","rtjj_21_aaa_p2_sat",8,"content","F7_AAA_SP2_VARCHAR","VARCHAR(200)"]
],
  "process_column_mapping": [
         ["rtjj_21_aaa_hub","_A_","HK_RTJJ_21_AAA","HK_RTJJ_21_AAA",null],
         ["rtjj_21_aaa_hub","_A_","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR"],
         ["rtjj_21_aaa_hub","_A_","F2_BK_AAA_DECIMAL","F2_BK_AAA_DECIMAL","F2_BK_AAA_DECIMAL"],
         ["rtjj_21_aaa_p1_sat","_A_","HK_RTJJ_21_AAA","HK_RTJJ_21_AAA",null],
         ["rtjj_21_aaa_p1_sat","_A_","RH_RTJJ_21_AAA_P1_SAT","RH_RTJJ_21_AAA_P1_SAT",null],
         ["rtjj_21_aaa_p1_sat","_A_","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR","F3_AAA_SP1_VARCHAR"],
         ["rtjj_21_aaa_p1_sat","_A_","F5_AAA_SP1_AND_SP2_DECIMAL","F5_AAA_SP1_AND_SP2_DECIMAL","F5_AAA_SP1_AND_SP2_DECIMAL"],
         ["rtjj_21_aaa_p1_sat","_A_","F6_AAA_SP1_TIMESTAMP_XRH","F6_AAA_SP1_TIMESTAMP_XRH","F6_AAA_SP1_TIMESTAMP_XRH"],
         ["rtjj_21_aaa_p1_sat","_A_","F8_AAA_SP1_DECIMAL","F8_AAA_SP1_DECIMAL","F8_AAA_SP1_DECIMAL"],
         ["rtjj_21_aaa_p2_sat","_A_","HK_RTJJ_21_AAA","HK_RTJJ_21_AAA",null],
         ["rtjj_21_aaa_p2_sat","_A_","RH_RTJJ_21_AAA_P2_SAT","RH_RTJJ_21_AAA_P2_SAT",null],
         ["rtjj_21_aaa_p2_sat","_A_","F4_AAA_SP2_DECIMAL","F4_AAA_SP2_DECIMAL","F4_AAA_SP2_DECIMAL"],
         ["rtjj_21_aaa_p2_sat","_A_","F5_AAA_SP1_AND_SP2_DECIMAL","F5_AAA_SP1_AND_SP2_DECIMAL","F5_AAA_SP1_AND_SP2_DECIMAL"],
         ["rtjj_21_aaa_p2_sat","_A_","F7_AAA_SP2_VARCHAR","F7_AAA_SP2_VARCHAR","F7_AAA_SP2_VARCHAR"]
 ],
"stage_table_column": [
		["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
		["F2_BK_AAA_DECIMAL","DECIMAL(20,0)",8,"F2_BK_AAA_DECIMAL","DECIMAL(20,0)",false],
		["F3_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F3_AAA_SP1_VARCHAR","VARCHAR(200)",false],
		["F4_AAA_SP2_DECIMAL","DECIMAL(5,0)",8,"F4_AAA_SP2_DECIMAL","DECIMAL(5,0)",false],
		["F5_AAA_SP1_AND_SP2_DECIMAL","VARCHAR(200)",8,"F5_AAA_SP1_AND_SP2_DECIMAL","VARCHAR(200)",false],
		["F6_AAA_SP1_TIMESTAMP_XRH","TIMESTAMP",8,"F6_AAA_SP1_TIMESTAMP_XRH","TIMESTAMP",false],
		["F7_AAA_SP2_VARCHAR","VARCHAR(200)",8,"F7_AAA_SP2_VARCHAR","VARCHAR(200)",false],
		["F8_AAA_SP1_DECIMAL","DECIMAL(5,0)",8,"F8_AAA_SP1_DECIMAL","DECIMAL(5,0)",false],
		["HK_RTJJ_21_AAA","CHAR(28)",2,null,null,false],
		["RH_RTJJ_21_AAA_P1_SAT","CHAR(28)",3,null,null,false],
		["RH_RTJJ_21_AAA_P2_SAT","CHAR(28)",3,null,null,false]
],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_21_AAA","F1_BK_AAA_VARCHAR",0,0],
         ["_A_","HK_RTJJ_21_AAA","F2_BK_AAA_DECIMAL",0,0],
         ["_A_","RH_RTJJ_21_AAA_P1_SAT","F3_AAA_SP1_VARCHAR",0,0],
         ["_A_","RH_RTJJ_21_AAA_P1_SAT","F5_AAA_SP1_AND_SP2_DECIMAL",0,0],
         ["_A_","RH_RTJJ_21_AAA_P1_SAT","F8_AAA_SP1_DECIMAL",0,0],
         ["_A_","RH_RTJJ_21_AAA_P2_SAT","F4_AAA_SP2_DECIMAL",0,0],
         ["_A_","RH_RTJJ_21_AAA_P2_SAT","F5_AAA_SP1_AND_SP2_DECIMAL",0,0],
         ["_A_","RH_RTJJ_21_AAA_P2_SAT","F7_AAA_SP2_VARCHAR",0,0]
  ]    }');                                                                                                           

