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

DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test40_ref_simple_with_history';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test40_ref_simple_with_history','{
	"dvpd_version": "1.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test40_ref_simple_with_history",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_AAA_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_40_aaa_ref"}]},
		 	  {"field_name": "F2_BBB_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_40_aaa_ref"}]},
		 	  {"field_name": "F3_CCC_FIELDNAME_DATE",		"field_type": "DATE",			"targets": [{"table_name": "rtjj_40_aaa_ref"
																											,"target_column_name":"F3_CCC_DATE"}]},
			  {"field_name": "F4_DDD_NOT_IN_RH__DECIMAL",		"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_40_aaa_ref","exclude_from_diff_hash": "true"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_40_aaa_ref",		"stereotype": "ref","diff_hash_column_name": "RH_rtjj_40_aaa_ref"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test40_ref_simple_with_history');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test40_ref_simple_with_history';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test40_ref_simple_with_history','{
	"dv_model_column": [
			["rvlt_test_jj","rtjj_40_aaa_ref",3,"diff_hash","RH_RTJJ_40_AAA_REF","CHAR(28)"],                   
			["rvlt_test_jj","rtjj_40_aaa_ref",8,"content","F1_AAA_VARCHAR","VARCHAR(20)"],                      
			["rvlt_test_jj","rtjj_40_aaa_ref",8,"content","F2_BBB_DECIMAL","DECIMAL(20,0)"],                    
			["rvlt_test_jj","rtjj_40_aaa_ref",8,"content","F3_CCC_DATE","DATE"],                                
			["rvlt_test_jj","rtjj_40_aaa_ref",8,"content_untracked","F4_DDD_NOT_IN_RH__DECIMAL","DECIMAL(5,0)"]
],
 "process_column_mapping": [
         ["rtjj_40_aaa_ref","_A_","RH_RTJJ_40_AAA_REF","RH_RTJJ_40_AAA_REF",null],
         ["rtjj_40_aaa_ref","_A_","F1_AAA_VARCHAR","F1_AAA_VARCHAR","F1_AAA_VARCHAR"],
         ["rtjj_40_aaa_ref","_A_","F2_BBB_DECIMAL","F2_BBB_DECIMAL","F2_BBB_DECIMAL"],
         ["rtjj_40_aaa_ref","_A_","F3_CCC_DATE","F3_CCC_FIELDNAME_DATE","F3_CCC_FIELDNAME_DATE"],
         ["rtjj_40_aaa_ref","_A_","F4_DDD_NOT_IN_RH__DECIMAL","F4_DDD_NOT_IN_RH__DECIMAL","F4_DDD_NOT_IN_RH__DECIMAL"]
 ], 
"stage_table_column": [
			["F1_AAA_VARCHAR","VARCHAR(20)",8,"F1_AAA_VARCHAR","VARCHAR(20)",false],                        
			["F2_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_BBB_DECIMAL","DECIMAL(20,0)",false],                    
			["F3_CCC_FIELDNAME_DATE","DATE",8,"F3_CCC_FIELDNAME_DATE","DATE",false],                
			["F4_DDD_NOT_IN_RH__DECIMAL","DECIMAL(5,0)",8,"F4_DDD_NOT_IN_RH__DECIMAL","DECIMAL(5,0)",false],
			["RH_RTJJ_40_AAA_REF","CHAR(28)",3,null,null,false]                                            
 ],
 "stage_hash_input_field": [
         ["_A_","RH_RTJJ_40_AAA_REF","F1_AAA_VARCHAR",0,0],
         ["_A_","RH_RTJJ_40_AAA_REF","F2_BBB_DECIMAL",0,0],
         ["_A_","RH_RTJJ_40_AAA_REF","F3_CCC_FIELDNAME_DATE",0,0]
  ]    }');                                                                                                             
