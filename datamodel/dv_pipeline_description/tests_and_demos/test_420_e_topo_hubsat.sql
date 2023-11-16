{
	"dvpd_version": "0.6.0",
	"stage_properties" : [{"stage_schema":"stage_rvlt"}],
	"pipeline_name": "test_420_e_topo_hubsat",
	"purpose":"Test dvpd transformation for multilayered field groups. #NOT TESTED YET#",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		       {"field_name": "F01_ID_AAA1",   "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_420_aaa_hub"}]}
		      ,{"field_name": "F02_S_AAA1", 	  "field_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_420_aaa_sat"}]}	 	  
		      ,{"field_name": "F03_ID_BBB1_R1", "field_type": "Varchar(20)","targets": [{"table_name": "rtjj_420_bbb_hub" ,"column_name": "ID_BBB1"
																				 	,"relation_names":["R111"]} ]}		 	  
		      ,{"field_name": "F04_ID_BBB1_R2", "field_type": "Varchar(20)","targets": [{"table_name": "rtjj_420_bbb_hub" ,"column_name": "ID_BBB1"
																				 	,"relation_names":["R222"]} ]}		 	  
		      ,{"field_name": "F05_ID_BBB1_R3","field_type": "Varchar(20)",  "targets": [{"table_name": "rtjj_420_bbb_hub" ,"column_name": "ID_BBB1"
																				 	,"relation_names":["R333"]} ]}		 	  
		      ,{"field_name": "F06_ID_BBB2_R1", "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_420_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R111"]} ]}	 
		      ,{"field_name": "F07_ID_BBB2_R2", "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_420_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R222"]} ]}	 
		      ,{"field_name": "F08_ID_BBB2_R3", "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_420_bbb_hub" ,"column_name": "ID_BBB2"
																				 	,"relation_names":["R333"]} ]}
	 
		      ,{"field_name": "F09_S_BBB1_R1",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_420_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R111"]} ]}
		      ,{"field_name": "F10_S_BBB1_R2",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_420_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R222"]} ]}
		      ,{"field_name": "F11_S_BBB1_R3",  "field_type": "Varchar(20)", "targets": [{"table_name": "rtjj_420_bbb_sat" ,"column_name": "S_BBB1"
																				 	,"relation_names":["R333"]} ]}
		      ,{"field_name": "F12_S_BBB2_R1",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtjj_420_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R111"]} ]}
		      ,{"field_name": "F13_S_BBB2_R2",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtjj_420_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R222"]} ]}
		      ,{"field_name": "F14_S_BBB2_R3",  "field_type": "decimal(12,2)", "targets": [{"table_name": "rtjj_420_bbb_sat" ,"column_name": "S_BBB2"
																				 	,"relation_names":["R333"]} ]}
 
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables":  [
				{"table_name": "rtjj_420_aaa_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_420_aaa"}
				,{"table_name": "rtjj_420_aaa_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_420_aaa_hub"
																				,"diff_hash_column_name": "RH_rtjj_420_aaa_sat"}
				,{"table_name": "rtjj_420_aaa_bbb_lnk",	"table_stereotype": "lnk","link_key_column_name": "LK_rtjj_420_aaa_bbb",
												"link_parent_tables": [	"rtjj_420_aaa_hub","rtjj_420_bbb_hub"]}
				,{"table_name": "rtjj_420_aaa_bbb_r111_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_420_aaa_bbb_lnk"
																						,"tracked_relation_name":"R111"}
				,{"table_name": "rtjj_420_aaa_bbb_r222_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_420_aaa_bbb_lnk"
																						,"tracked_relation_name":"R222"}
				,{"table_name": "rtjj_420_aaa_bbb_r333_esat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_420_aaa_bbb_lnk"
																						,"tracked_relation_name":"R333"}
				,{"table_name": "rtjj_420_bbb_hub",		"table_stereotype": "hub","hub_key_column_name": "HK_rtjj_420_bbb"}
				,{"table_name": "rtjj_420_bbb_sat",	"table_stereotype": "sat","satellite_parent_table": "rtjj_420_bbb_hub"
																			,"diff_hash_column_name": "RH_rtjj_420_bbb_sat"}
				]
		}
	]
}