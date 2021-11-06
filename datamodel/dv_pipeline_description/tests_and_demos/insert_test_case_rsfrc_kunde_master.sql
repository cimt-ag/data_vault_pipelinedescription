/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'rsfrc_kunde_master';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('rsfrc_kunde_master','{
 	"DVPD_Version": "1.0",
 	"pipeline_name": "rsfrc_kunde_master",
 	"record_source_name_expression": "salesforce.kundenmaster",
 	"data_fetch_module": {
 		"fetch_module_name": "read_file_delimted",
 		"search_expression": "$PipelineInputDirectory/kunde_master*.csv",
 		"file_archive_path": "$PipelineArchiveDirectory"
 	},
 	"data_parse_module": {
 		"parse_module_name": "delimited_text",
 		"codepage": "UTF_8",
 		"columnseparator": "|",
 		"rowseparator": "\n",
 		"skip_first_rows": "1",
 		"reject_processing": "reject_container"
 	},
 	"fields": [{
 		"field_name": "KUNDE_NR",
 		"technical_type": "DECIMAL(10,0)",
 		"parsing_expression": "3",
 		"targets": [{
 			"table_name": "rsfrc_kunde_hub"
 		}]
 	}, {
 		"field_name": "MASTER_KUNDE_NR",
 		"technical_type": "DECIMAL(10,0)",
 		"parsing_expression": "4",
 		"targets": [{
 			"table_name": "rsfrc_kunde_hub",
 			"target_column_name": "KUNDE_NR",
 			"hierarchy_key_suffix": "master"
 		}]

 	}],
 	"data_vault_modell": [{
 		"schema_name": "rvlt_salesforce",
 		"tables": [{
 				"table_name": "rsfrc_kunde_hub",
 				"stereotype": "hub",
 				"hub_key_column_name": "HK_RSFRC_KUNDE"
 			}, {
 				"table_name": "rkpsf_kunde_kunde_master_lnk",
 				"stereotype": "link",
 				"link_key_column_name": "LK_RKPSF_AUFTRAG_KUNDE",
 				"link_parent_tables": ["rsfrc_kunde_hub"]
 			},
 			{
 				"table_name": "rkpsf_kunde_kunde_master_esat",
				"satellite_parent_table": "rkpsf_kunde_kunde_master_lnk",
 				"stereotype": "esat",
 				"satellite_parent": "rkpsf_kunde_kunde_master_lnk",
 				"driving_hub_keys": ["HK_RSFRC_KUNDE"]
 			}
 		]
 	}]
 }');