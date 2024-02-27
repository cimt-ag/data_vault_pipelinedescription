{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test62_fg_drive_scenario_2",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_BK_AAA_L1", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_62_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["R111"]}]}
		      ,{"field_name": "F2_BK_AAA_L2", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_62_aaa_hub"
																					,"column_name": "BK_AAA"
																				 	,"relation_names":["R222"]}]}		 	  
		      ,{"field_name": "F3_AAA_S1_COLA","field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_62_aaa_p1_sat"}]}		 
		      ,{"field_name": "F4_AAA_S1_COLB","field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_62_aaa_p1_sat"}]}		 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_62_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_62_aaa"}
				,{"table_name": "rtjj_62_aaa_p1_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_62_aaa_hub"
																			,"diff_hash_column_name": "RH_rtjj_62_aaa_p1_sat"}
				]
		}
	]
}
