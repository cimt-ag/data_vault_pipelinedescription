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

/* insert Example 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'rgopd_keyword_click_report_p1';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('rgopd_keyword_click_report_p1','{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "rgopd_keyword_click_report_p1",
	"record_source_name_expression": ">>is hardcoded in stage function<<",
	"data_extraction": {
		"fetch_module_name":"hardcoded fetch and stage"
	},
	"fields": [
		      {"field_name": "key", 			"field_type": "Varchar(200)",	"targets": [{"table_name": "rgopd_keyword_hub","column_name": "keyword_id"}]},
		      {"field_name": "date", 			"field_type": "date",			"targets": [{"table_name": "rgopd_keyword_click_report_dlnk"}]},
		 	  {"field_name": "json_object",		"field_type": "json",			"targets": [{"table_name": "rgopd_keyword_click_report_p1_sat","exclude_from_change_detection": "true"}]},
		 	  {"field_name": "json_object_sorted","field_type": "json",			"targets": [{"table_name": "rgopd_keyword_click_report_p1_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_google_pandata", "tables": [
				{"table_name": "rgopd_keyword_hub",					"table_stereotype": "hub",	 "hub_key_column_name": "HK_RGOPD_KEYWORD"},
				{"table_name": "rgopd_keyword_click_report_dlnk",	"table_stereotype": "lnk",	"link_key_column_name": "LK_RGOPD_KEYWORD_CLICK_REPORT",
																							  "link_parent_tables": ["rgopd_keyword_hub"]},
				{"table_name": "rgopd_keyword_click_report_p1_sat",	"table_stereotype": "sat",  "satellite_parent_table": "rgopd_keyword_click_report_dlnk",
														 								   "diff_hash_column_name": "RH_RGOPD_KEYWORD_CLICK_REPORT_P1_SAT"}
				]
		}
	]
}
');