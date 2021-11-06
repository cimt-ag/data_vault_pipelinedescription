/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'rkpsf_auftrag_p1';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES('rkpsf_auftrag_p1', '{
	"DVPD_Version": "1.0",
	"pipeline_name": "rkpsf_auftrag_p1",
	"record_source_name_expression": "knuppisoft.auftrag",
	"data_fetch_module": {
		"fetch_module_name": "read_file_delimted",
		"search_expression": "$PipelineInputDirectory/Auftrag*.csv",
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
			"field_name": "FI_ID",			"technical_type": "Varchar(20)",			"parsing_expression": "1",
			"uniqeness_groups": ["key"],
			"targets": [{
				"table_name": "rkpsf_auftrag_hub"
			},{
				"table_name": "rsfrc_kunde_hub",
				"field_groups": ["haupt_kunde","co_kunde"]
			}]
		}, {
			"field_name": "AUFTRAGSNR",
			"technical_type": "Decimal(10,0)",
			"parsing_expression": "2",
			"uniqeness_groups": ["key"],
			"targets": [{
				"table_name": "rkpsf_auftrag_hub",
				"target_column_name": "A_NUMMER"
			}]
		}, {
			"field_name": "KUNDE_NR",
			"technical_type": "DECIMAL(10,0)",
			"parsing_expression": "3",
			"targets": [{
				"table_name": "rsfrc_kunde_hub",
				"field_groups": ["haupt_kunde"]
			}]
		}, {
			"field_name": "CO_KUNDE_NR",
			"technical_type": "DECIMAL(10,0)",
			"parsing_expression": "4",
			"targets": [{
				"table_name": "rsfrc_kunde_hub",
				"target_column_name": "KUNDE_NR",
				"field_groups": ["co_kunde"]
			}]
		}, {
			"field_name": "AUFTRAGSART",
			"technical_type": "Varchar(20)",
			"parsing_expression": "6",
			"targets": [{
				"table_name": "rkpsf_auftrag_p1_sat"
			}]
		}, {
			"field_name": "PREIS_NETTO",
			"technical_type": "DECIMAL(12,2)",
			"parsing_expression": "7",
			"targets": [{
				"table_name": "rkpsf_auftrag_p1_sat"
			}]
		},
		{
			"field_name": "STATUS",
			"technical_type": "VARCHAR(10)",
			"parsing_expression": "8",
			"targets": [{
				"table_name": "rkpsf_auftrag_p1_sat"
			}]
		},
		{
			"field_name": "SYSTEMMODTIME",
			"technical_type": "TIMESTAMP",
			"parsing_expression": "9",
			"targets": [{
				"table_name": "rkpsf_auftrag_p1_sat",
				"exclude_from_diff_hash": "true"
			}]
		}
	],
	"data_vault_modell": [{
			"schema_name": "rvlt_salesforce",
			"tables": [{
				"table_name": "rsfrc_kunde_hub",
				"stereotype": "hub",
				"hub_key_column_name": "HK_RSFRC_KUNDE"
			}, {
				"table_name": "rsfrc_kunde_p1_sat",
				"stereotype": "sat",
				"satellite_parent_table": "rsfrc_kunde_hub",
				"diff_hash_column_name": "RH_KUNDE_P1_SAT"
			}]
		},
		{
			"schema_name": "rvlt_knuppisoft",
			"tables": [{
					"table_name": "rkpsf_auftrag_hub",
					"stereotype": "hub",
					"hub_key_column_name": "HK_RKPSF_AUFTRAG"
				}, {
					"table_name": "rkpsf_auftrag_p1_sat",
					"stereotype": "sat",
					"satellite_parent_table": "rkpsf_auftrag_hub",
					"diff_hash_column_name": "RH_AUFTRAG_P1_SAT"
				}, {
					"table_name": "rkpsf_auftrag_kunde_lnk",
					"stereotype": "link",
					"link_key_column_name": "LK_RKPSF_AUFTRAG_KUNDE",
					"link_parent_tables": ["rkpsf_auftrag_hub","rsfrc_kunde_hub"]
				}, {
					"table_name": "rkpsf_auftrag_kunde_esat",
					"stereotype": "esat",
					"satellite_parent_table": "rkpsf_auftrag_kunde_lnk",
					"tracked_field_groups": ["hauptkunde"],
					"driving_hub_keys": ["hk_rkpsf_auftrag"]
				},
				{
					"table_name": "rkpsf_auftrag_co_kunde_esat",
					"stereotype": "esat",
					"satellite_parent_table": "rkpsf_auftrag_kunde_lnk",
					"tracked_field_groups": ["co_kunde"],
					"driving_hub_keys": ["hk_rkpsf_auftrag"]
				}
			]
		}
	]
}');