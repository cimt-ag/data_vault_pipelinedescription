/* insert Example 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'rgopd_keyword_click_report_p1';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('rgopd_keyword_click_report_p1','{
	"DVPD_Version": "1.0",
	"pipeline_name": "rgopd_keyword_click_report_p1",
	"record_source_name_expression": ">>is hardcoded in stage function<<",
	"data_extraction": {
		"fetch_module_name":"hardcoded fetch and stage"
	},
	"fields": [
		      {"field_name": "key", 			"technical_type": "Varchar(200)",	"targets": [{"table_name": "rgopd_keyword_hub","target_column_name": "keyword_id"}]},
		      {"field_name": "date", 			"technical_type": "date",			"targets": [{"table_name": "rgopd_keyword_click_report_dlnk"}]},
		 	  {"field_name": "json_object",		"technical_type": "json",			"targets": [{"table_name": "rgopd_keyword_click_report_p1_sat","exclude_from_diff_hash": "true"}]},
		 	  {"field_name": "json_object_sorted","technical_type": "json",			"targets": [{"table_name": "rgopd_keyword_click_report_p1_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_google_pandata", "tables": [
				{"table_name": "rgopd_keyword_hub",					"stereotype": "hub",	 "hub_key_column_name": "HK_RGOPD_KEYWORD"},
				{"table_name": "rgopd_keyword_click_report_dlnk",	"stereotype": "lnk",	"link_key_column_name": "LK_RGOPD_KEYWORD_CLICK_REPORT",
																							  "link_parent_tables": ["rgopd_keyword_hub"]},
				{"table_name": "rgopd_keyword_click_report_p1_sat",	"stereotype": "sat",  "satellite_parent_table": "rgopd_keyword_click_report_dlnk",
														 								   "diff_hash_column_name": "RH_RGOPD_KEYWORD_CLICK_REPORT_P1_SAT"}
				]
		}
	]
}
');