/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test80_recursive_link_with_common_bk_field';
INSERT INTO dv_pipeline_description.dvpd_dictionary 
(pipeline_name, dvpd_json)
VALUES
('test80_recursive_link_with_common_bk_field','{
 	"DVPD_Version": "1.0",
 	"pipeline_name": "test80_recursive_link_with_common_bk_field",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
 	"fields": [
		{"field_name": "FI_ID",			"technical_type": "Varchar(20)",  "field_position": "1", "uniqueness_groups": ["key"],
									        "targets": [{"table_name": "rtsta_80_kunde_hub"}]},
		{"field_name": "KUNDE_NR",			"technical_type": "DECIMAL(10,0)","field_position": "3","targets": [{"table_name": "rtsta_80_kunde_hub"	}]},
		{"field_name": "MASTER_KUNDE_NR",	"technical_type": "DECIMAL(10,0)","field_position": "4","targets": [{"table_name": "rtsta_80_kunde_hub",
																								 			"target_column_name": "KUNDE_NR",
																								 			"recursion_suffix": "master"}]}
	],
 	"data_vault_model": [
		{"schema_name": "rvlt_test_a",
 		"tables": [
			{"table_name": "rtsta_80_kunde_hub",				"stereotype": "hub","hub_key_column_name": "HK_rtsta_80_KUNDE"},
			{"table_name": "rtsta_80_kunde_kunde_master_lnk",	"stereotype": "lnk","link_key_column_name": "LK_rtsta_80_KUNDE_KUNDE_MASTER",
 																				 "link_parent_tables": ["rtsta_80_kunde_hub"],
																				 "recursive_parents": [ {"table_name":"rtsta_80_kunde_hub",
																											"recursion_suffix": "master"}]},

 			{"table_name": "rtsta_80_kunde_kunde_master_esat",	"stereotype": "esat","satellite_parent_table": "rtsta_80_kunde_kunde_master_lnk",
																			 				"driving_hub_keys": ["HK_rtsta_80_KUNDE"]}
 			]
 		}
	]
 }');
 

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test80_recursive_link_with_common_bk_field';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test80_recursive_link_with_common_bk_field','{
  "dv_model_column": [
         ["rvlt_test_a","rtsta_80_kunde_hub",2,"key","HK_RTSTA_80_KUNDE","CHAR(28)"],
         ["rvlt_test_a","rtsta_80_kunde_hub",8,"business_key","FI_ID","VARCHAR(20)"],
         ["rvlt_test_a","rtsta_80_kunde_hub",8,"business_key","KUNDE_NR","DECIMAL(10,0)"],
         ["rvlt_test_a","rtsta_80_kunde_kunde_master_esat",2,"parent_key","LK_RTSTA_80_KUNDE_KUNDE_MASTER","CHAR(28)"],
         ["rvlt_test_a","rtsta_80_kunde_kunde_master_lnk",2,"key","LK_RTSTA_80_KUNDE_KUNDE_MASTER","CHAR(28)"],
         ["rvlt_test_a","rtsta_80_kunde_kunde_master_lnk",3,"parent_key","HK_RTSTA_80_KUNDE","CHAR(28)"],
         ["rvlt_test_a","rtsta_80_kunde_kunde_master_lnk",4,"parent_key","HK_RTSTA_80_KUNDE__MASTER","CHAR(28)"]
 ],
 "stage_table_column": [
         ["FI_ID","VARCHAR(20)",8,"FI_ID","VARCHAR(20)",false],
         ["FI_ID__MASTER","VARCHAR(20)",8,"FI_ID","VARCHAR(20)",false],
         ["HK_RTSTA_80_KUNDE","CHAR(28)",2,null,null,false],
         ["HK_RTSTA_80_KUNDE__MASTER","CHAR(28)",2,null,null,false],
         ["KUNDE_NR","DECIMAL(10,0)",8,"KUNDE_NR","DECIMAL(10,0)",false],
         ["KUNDE_NR__MASTER","DECIMAL(10,0)",8,"MASTER_KUNDE_NR","DECIMAL(10,0)",false],
         ["LK_RTSTA_80_KUNDE_KUNDE_MASTER","CHAR(28)",2,null,null,false]
 ],
 "stage_hash_input_field": [
         ["_A_","HK_RTSTA_80_KUNDE","FI_ID",0,0],
         ["_A_","HK_RTSTA_80_KUNDE","KUNDE_NR",0,0],
         ["_A_","LK_RTSTA_80_KUNDE_KUNDE_MASTER","FI_ID",0,0],
         ["_A_","LK_RTSTA_80_KUNDE_KUNDE_MASTER","KUNDE_NR",0,0],
         ["_A_","LK_RTSTA_80_KUNDE_KUNDE_MASTER","MASTER_KUNDE_NR",0,0],
         ["_MASTER","HK_RTSTA_80_KUNDE__MASTER","FI_ID",0,0],
         ["_MASTER","HK_RTSTA_80_KUNDE__MASTER","MASTER_KUNDE_NR",0,0]
  ]    }');