/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test50_double_esat_field_group';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES('test50_double_esat_field_group', '{
	"DVPD_Version": "1.0",
	"pipeline_name": "test50_double_esat_field_group",
	"record_source_name_expression": "knuppisoft.auftrag",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},

	"fields": [
		{"field_name": "FI_ID",			"technical_type": "Varchar(20)",  "field_position": "1", "uniqueness_groups": ["key"],
								"targets": [{"table_name": "rtstb_50_auftrag_hub"},
									        {"table_name": "rtsta_50_kunde_hub"}]},

 		{"field_name": "AUFTRAGSNR",	"technical_type": "Decimal(10,0)", "field_position": "2","uniqueness_groups": ["key"],
								"targets": [{"table_name": "rtstb_50_auftrag_hub","target_column_name": "A_NUMMER"}]},

		{"field_name": "KUNDE_NR",		"technical_type": "DECIMAL(10,0)", "field_position": "3",
								"targets": [{"table_name": "rtsta_50_kunde_hub","field_groups": ["hauptkunde"]}]},

		{"field_name": "CO_KUNDE_NR",	"technical_type": "DECIMAL(10,0)",	"field_position": "4",
								"targets": [{"table_name": "rtsta_50_kunde_hub","target_column_name": "KUNDE_NR","field_groups": ["co_kunde"]}]},

		{"field_name": "KUNDEN_NAME",		"technical_type": "VARCHAR(200)", "field_position": "5",
								"targets": [{"table_name": "rtsta_50_kunde_p1_sat","field_groups": ["hauptkunde"]}]},

		{"field_name": "AUFTRAGSART",	"technical_type": "Varchar(20)",	"field_position": "6",
								"targets": [{"table_name": "rtstb_50_auftrag_p1_sat"}]},
 		
		{"field_name": "PREIS_NETTO",	"technical_type": "DECIMAL(12,2)",	"field_position": "7",	"targets": [{"table_name": "rtstb_50_auftrag_p1_sat"}]},
		{"field_name": "STATUS",		"technical_type": "VARCHAR(10)",	"field_position": "8",	"targets": [{"table_name": "rtstb_50_auftrag_p1_sat"}]},
		{"field_name": "SYSTEMMODTIME",	"technical_type": "TIMESTAMP",		"field_position": "9",	"targets": [{"table_name": "rtstb_50_auftrag_p1_sat",
																												"exclude_from_diff_hash": "true"}]}
	],
	"data_vault_model": [{
		"schema_name": "rvlt_test_a",
			"tables": [
				{"table_name": "rtsta_50_kunde_hub",	"stereotype": "hub","hub_key_column_name": "HK_rtsta_50_KUNDE"},
 				{"table_name": "rtsta_50_kunde_p1_sat","stereotype": "sat","satellite_parent_table": "rtsta_50_kunde_hub","diff_hash_column_name": "RH_rtsta_50_KUNDE_P1_SAT",
																	"tracked_field_groups": ["hauptkunde"]}
			]
		},
		{"schema_name": "rvlt_test_b",
			"tables": [
				{"table_name": "rtstb_50_auftrag_hub",		 "stereotype": "hub","hub_key_column_name": "HK_rtstb_50_AUFTRAG"},
				{"table_name": "rtstb_50_auftrag_p1_sat",	 "stereotype": "sat","satellite_parent_table": "rtstb_50_auftrag_hub","diff_hash_column_name": "RH_AUFTRAG_P1_SAT"},
				{"table_name": "rtstb_50_auftrag_kunde_lnk","stereotype": "lnk","link_key_column_name": "LK_rtstb_50_AUFTRAG_KUNDE"
																	,	"link_parent_tables": ["rtstb_50_auftrag_hub","rtsta_50_kunde_hub"]},
				{"table_name": "rtstb_50_auftrag_kunde_esat","stereotype": "esat","satellite_parent_table": "rtstb_50_auftrag_kunde_lnk",
																		"tracked_field_groups": ["hauptkunde"],
																		"driving_hub_keys": ["hk_rtstb_50_auftrag"]},
				{"table_name": "rtstb_50_auftrag_co_kunde_esat","stereotype": "esat","satellite_parent_table": "rtstb_50_auftrag_kunde_lnk",
																		"tracked_field_groups": ["co_kunde"],
																		"driving_hub_keys": ["hk_rtstb_50_auftrag"]}
			]
		}
	]
}');