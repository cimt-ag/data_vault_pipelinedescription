/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test01_simple_hub_sat';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test01_simple_hub_sat','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test01_simple_hub_sat",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"Database",
		"connection_identifier": "mysql_knuppisoft",
		"increment_logic": "timeline",
		"increment_tracking_field": "SYSMODTIMESTAMP",
		"reject_procedure": "abort_process",
		"query": "SELECT * FROM KNUPPI.ARTIKEL WHERE SYSMODTIMESTAMP > $lowerbound"
	},
	"fields": [
		      {"field_name": "MANDANT", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtstb_artikel_hub"}]},
		 	  {"field_name": "ARTIKELNUMMER",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtstb_artikel_hub"}]},
		 	  {"field_name": "ARTIKELNAME",		"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtstb_artikel_p1_sat"}]},
			  {"field_name": "ARTIKELTYP_ID",	"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtstb_artikel_p1_sat"}]},
			  {"field_name": "VERKAUFSEINHEIT",	"technical_type": "VARCHAR(200)",	"targets": [{"table_name": "rtstb_artikel_p1_sat"}]},
			  {"field_name": "SYSMODTIMESTAMP",	"technical_type": "TIMESTAMP",		"targets": [{"table_name": "rtstb_artikel_p1_sat","exclude_from_diff_hash": "true"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_b", 
		 "tables": [
				{"table_name": "rtstb_artikel_hub",		"stereotype": "hub","hub_key_column_name": "HK_RTSTB_ARTIKEL"},
				{"table_name": "rtstb_artikel_p1_sat",	"stereotype": "sat","satellite_parent_table": "RTSTB_ARTIKEL_HUB","diff_hash_column_name": "RH_RTSTB_ARTIKEL_P1_SAT"}
				]
		}
	]
}
');