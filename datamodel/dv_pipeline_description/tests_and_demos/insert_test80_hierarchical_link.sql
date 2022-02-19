/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test80_hierarchical_link';
INSERT INTO dv_pipeline_description.dvpd_dictionary 
(pipeline_name, dvpd_json)
VALUES
('test80_hierarchical_link','{
 	"DVPD_Version": "1.0",
 	"pipeline_name": "test80_hierarchical_link",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 	"fields": [
		{"field_name": "FI_ID",			"technical_type": "Varchar(20)",  "field_position": "1", "uniqueness_groups": ["key"],
									        "targets": [{"table_name": "rtsta_80_kunde_hub"}]},
		{"field_name": "KUNDE_NR",			"technical_type": "DECIMAL(10,0)","field_position": "3","targets": [{"table_name": "rtsta_80_kunde_hub"	}]},
		{"field_name": "MASTER_KUNDE_NR",	"technical_type": "DECIMAL(10,0)","field_position": "4","targets": [{"table_name": "rtsta_80_kunde_hub",
																								 			"target_column_name": "KUNDE_NR",
																								 			"hierarchy_key_suffix": "master"}]}
	],
 	"data_vault_model": [
		{"schema_name": "rvlt_test_a",
 		"tables": [
			{"table_name": "rtsta_80_kunde_hub",				"stereotype": "hub","hub_key_column_name": "HK_rtsta_80_KUNDE"},
			{"table_name": "rtsta_80_kunde_kunde_master_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rtsta_80_KUNDE_KUNDE_MASTER",
 																				 "link_parent_tables": ["rtsta_80_kunde_hub"],
																				 "hierarchical_parents": [ {"table_name":"rtsta_80_kunde_hub",
																											"hierarchy_key_suffix": "master"}]},

 			{"table_name": "rtsta_80_kunde_kunde_master_esat",	"stereotype": "esat","satellite_parent_table": "rtsta_80_kunde_kunde_master_lnk",
																			 				"driving_hub_keys": ["HK_rtsta_80_KUNDE"]}
 			]
 		}
	]
 }');