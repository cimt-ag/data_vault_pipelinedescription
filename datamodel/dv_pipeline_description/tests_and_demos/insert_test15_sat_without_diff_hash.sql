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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test15_sat_without_diff_hash';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test15_sat_without_diff_hash','{
	"dvpd_version": "1.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test15_sat_without_diff_hash",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_15_aaa_hub"}]}
		 	  ,{"field_name": "F2_AAA_SP1_VARCHAR",		"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_15_aaa_p1_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_15_aaa_hub",		"stereotype": "hub","hub_key_column_name": "HK_rtjj_15_aaa"},
				{"table_name": "rtjj_15_aaa_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtjj_15_aaa_HUB"}
				]
		}
	]
}
');
select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test15_sat_without_diff_hash');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test15_sat_without_diff_hash';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test15_sat_without_diff_hash','{
  "dv_model_column": [
      ["rvlt_test_jj","rtjj_15_aaa_hub",2,"key","HK_RTJJ_15_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_15_aaa_hub",8,"business_key","F1_BK_AAA_VARCHAR","VARCHAR(20)"],
      ["rvlt_test_jj","rtjj_15_aaa_p1_sat",2,"parent_key","HK_RTJJ_15_AAA","CHAR(28)"],
      ["rvlt_test_jj","rtjj_15_aaa_p1_sat",8,"content","F2_AAA_SP1_VARCHAR","VARCHAR(200)"]
 ],
 "process_column_mapping": [
         ["rtjj_15_aaa_hub","_A_","HK_RTJJ_15_AAA","HK_RTJJ_15_AAA",null],
         ["rtjj_15_aaa_hub","_A_","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR","F1_BK_AAA_VARCHAR"],
         ["rtjj_15_aaa_p1_sat","_A_","HK_RTJJ_15_AAA","HK_RTJJ_15_AAA",null],
         ["rtjj_15_aaa_p1_sat","_A_","F2_AAA_SP1_VARCHAR","F2_AAA_SP1_VARCHAR","F2_AAA_SP1_VARCHAR"]
 ],
 "stage_table_column": [
         ["HK_RTJJ_15_AAA","CHAR(28)",2,null,null,false],
         ["F1_BK_AAA_VARCHAR","VARCHAR(20)",8,"F1_BK_AAA_VARCHAR","VARCHAR(20)",false],
         ["F2_AAA_SP1_VARCHAR","VARCHAR(200)",8,"F2_AAA_SP1_VARCHAR","VARCHAR(200)",false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTJJ_15_AAA","F1_BK_AAA_VARCHAR",0,0]
  ]    }');                                                                                                   

