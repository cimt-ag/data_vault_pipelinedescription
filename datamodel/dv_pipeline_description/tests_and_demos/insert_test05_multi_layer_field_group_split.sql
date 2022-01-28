/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test05_multi_layer_field_group_split';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test05_multi_layer_field_group_split','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test05_multi_layer_field_group_split",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "MANDANT", 	"technical_type": "VARCHAR(20)",	
											"targets": [{"table_name": "rtsta_fahrzeug_hub"}]},
		 	  {"field_name": "FZG_TY_1_U_2",	"technical_type": "VARCHAR(20)",
												"targets": [{"table_name": "rtsta_fahrzeug_hub", "target_column_name": "FAHRZEUG_TYP",
						     					"field_groups":["fzg1","fzg2"]}] },
		 	  {"field_name": "FZG_TY_3",	"technical_type": "VARCHAR(20)",	
											"targets": [{"table_name": "rtsta_fahrzeug_hub","target_column_name": "FAHRZEUG_TYP",
												 	"field_groups":["fzg3"]}]},
		 	  {"field_name": "KENN_1",	"technical_type": "VARCHAR(2)",	
											"targets": [{"table_name": "rtsta_fahrzeug_hub","target_column_name": "FAHRZEUG_KENNUNG",
											"field_groups":["fzg1"]}]},
		 	  {"field_name": "KENN_2",	"technical_type": "VARCHAR(2)",	
											"targets": [{"table_name": "rtsta_fahrzeug_hub","target_column_name": "FAHRZEUG_KENNUNG",
										    "field_groups":["fzg2"]}]},
		 	  {"field_name": "KENN_3",	"technical_type": "VARCHAR(2)",	
										"targets": [{"table_name": "rtsta_fahrzeug_hub","target_column_name": "FAHRZEUG_KENNUNG",
											 "field_groups":["fzg3"]}]},
		 	  {"field_name": "MARKE_1",		"technical_type": "VARCHAR(200)",	
										"targets": [{"table_name": "rtsta_fahrzeug_p1_sat","target_column_name": "MARKE",
										"field_groups":["fzg1"]}]},
		 	  {"field_name": "MARKE_2",		"technical_type": "VARCHAR(200)",	
										"targets": [{"table_name": "rtsta_fahrzeug_p1_sat","target_column_name": "MARKE",
										 "field_groups":["fzg2"]}]},
		 	  {"field_name": "MARKE_3",		"technical_type": "VARCHAR(200)",	
										"targets": [{"table_name": "rtsta_fahrzeug_p1_sat","target_column_name": "MARKE",
										 "field_groups":["fzg3"]}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_a", 
		 "tables": [
				{"table_name": "rtsta_fahrzeug_hub",		"stereotype": "hub","hub_key_column_name": "HK_RTSTB_FAHRZEUG"},
				{"table_name": "rtsta_fahrzeug_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtsta_fahrzeug_hub","diff_hash_column_name": "RH_RTSTA_FAHRZEUG_P1_SAT"}
				]
		}
	]
}
');