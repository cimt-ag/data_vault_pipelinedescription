DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test30_hub_dlink_sat';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test04_hub_dlink_sat','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test30_hub_dlink_sat",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "MANDANT", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtstb_30_artikel_hub"}]},
		 	  {"field_name": "ARTIKELNUMMER",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtstb_30_artikel_hub"}]},
		 	  {"field_name": "VERKAUFSTAG",		"technical_type": "DATE",			"targets": [{"table_name": "rtstb_30_artikel_report_dlnk"}]},
			  {"field_name": "BESTELLT",		"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtstb_30_artikel_report_p1_sat"}]},
			  {"field_name": "GELIEFERT",		"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtstb_30_artikel_report_p1_sat"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_b", 
		 "tables": [
				{"table_name": "rtstb_30_artikel_hub",		"stereotype": "hub",			"hub_key_column_name": "HK_rtstb_30_artikel"},
				{"table_name": "rtstb_30_artikel_report_dlnk",		"stereotype": "lnk",	"link_key_column_name": "LK_ARTIKEL_REPORT",
																 				"link_parent_tables":["rtstb_30_artikel_hub"]},
				{"table_name": "rtstb_30_artikel_report_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtstb_30_artikel_report_dlnk","diff_hash_column_name": "RH_rtstb_30_artikel_REPORT_P1_SAT"}
				]
		}
	]
}
');