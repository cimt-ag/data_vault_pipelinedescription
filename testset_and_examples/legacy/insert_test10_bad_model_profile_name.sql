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


DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test10_bad_model_profile_name';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test10_bad_model_profile_name','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test10_bad_model_profile_name",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"model_profile_name":"XXBAD_PROFILE_NAMEXX",

	"fields": [
		      {"field_name": "F1_BK_AAA_VARCHAR", 		"field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_10_aaa_hub"}]},
		 	  {"field_name": "F2_BK_AAA_DECIMAL",	"field_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_10_aaa_hub"}]},
		 	  {"field_name": "F3_AAA_SP1_VARCHAR",		"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_10_aaa_p1_sat"}]},
			  {"field_name": "F4_AAA_SP1_DECIMAL",	"field_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_10_aaa_p1_sat"}]},
			  {"field_name": "F5__FIELD_NAME",	"field_type": "VARCHAR(200)",	"targets": [{"table_name": "rtjj_10_aaa_p1_sat",
																									 "column_name":"F5_AAA_SP1_VARCHAR"}]},
			  {"field_name": "F6_AAA_SP1_TIMESTAMP_XRH",	"field_type": "TIMESTAMP",		"targets": [{"table_name": "rtjj_10_aaa_p1_sat","exclude_from_change_detection": "true"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_10_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_10_aaa"},
				{"table_name": "rtjj_10_aaa_p1_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_10_aaa_HUB","diff_hash_column_name": "RH_rtjj_10_aaa_P1_SAT"}
				]
		}
	]
}
');
select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test10_bad_model_profile_name');
