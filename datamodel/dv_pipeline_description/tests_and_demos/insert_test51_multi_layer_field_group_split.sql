/* insert Testcase 1*/
DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test51_multi_layer_field_group_split';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test51_multi_layer_field_group_split','{
	"dvpd_version": "1.0",
	"pipeline_name": "test51_multi_layer_field_group_split",
	"purpose":"Test dvpd transformation for multilayered field groups",
	"record_source_name_expression": "knuppisoft.artikel",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "MANDANT", 	"technical_type": "VARCHAR(20)",	
											"targets": [{"table_name": "rtsta_51_fahrzeug_hub"}]},
		 	  {"field_name": "FZG_TY_1_U_2",	"technical_type": "VARCHAR(20)",
												"targets": [{"table_name": "rtsta_51_fahrzeug_hub", "target_column_name": "FAHRZEUG_TYP",
						     					"field_groups":["fzg1","fzg2"]}] },
		 	  {"field_name": "FZG_TY_3",	"technical_type": "VARCHAR(20)",	
											"targets": [{"table_name": "rtsta_51_fahrzeug_hub","target_column_name": "FAHRZEUG_TYP",
												 	"field_groups":["fzg3"]}]},
		 	  {"field_name": "KENN_1",	"technical_type": "VARCHAR(2)",	
											"targets": [{"table_name": "rtsta_51_fahrzeug_hub","target_column_name": "FAHRZEUG_KENNUNG",
											"field_groups":["fzg1"]}]},
		 	  {"field_name": "KENN_2",	"technical_type": "VARCHAR(2)",	
											"targets": [{"table_name": "rtsta_51_fahrzeug_hub","target_column_name": "FAHRZEUG_KENNUNG",
										    "field_groups":["fzg2"]}]},
		 	  {"field_name": "KENN_3",	"technical_type": "VARCHAR(2)",	
										"targets": [{"table_name": "rtsta_51_fahrzeug_hub","target_column_name": "FAHRZEUG_KENNUNG",
											 "field_groups":["fzg3"]}]},
		 	  {"field_name": "MARKE_1",		"technical_type": "VARCHAR(200)",	
										"targets": [{"table_name": "rtsta_51_fahrzeug_p1_sat","target_column_name": "MARKE",
										"field_groups":["fzg1"]}]},
		 	  {"field_name": "MARKE_2",		"technical_type": "VARCHAR(200)",	
										"targets": [{"table_name": "rtsta_51_fahrzeug_p1_sat","target_column_name": "MARKE",
										 "field_groups":["fzg2"]}]},
		 	  {"field_name": "MARKE_3",		"technical_type": "VARCHAR(200)",	
										"targets": [{"table_name": "rtsta_51_fahrzeug_p1_sat","target_column_name": "MARKE",
										 "field_groups":["fzg3"]}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_a", 
		 "tables": [
				{"table_name": "rtsta_51_fahrzeug_hub",		"stereotype": "hub","hub_key_column_name": "HK_RTSTB_FAHRZEUG"},
				{"table_name": "rtsta_51_fahrzeug_p1_sat",	"stereotype": "sat","satellite_parent_table": "rtsta_51_fahrzeug_hub","diff_hash_column_name": "RH_rtsta_51_FAHRZEUG_P1_SAT"}
				]
		}
	]
}
');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test51_multi_layer_field_group_split';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE (pipeline_name, reference_data_json) VALUES
('test51_multi_layer_field_group_split','{
 "dv_model_column": [
         ["rvlt_test_a","rtsta_51_fahrzeug_hub",2,"key","HK_RTSTB_FAHRZEUG","CHAR(28)"],
         ["rvlt_test_a","rtsta_51_fahrzeug_hub",8,"business_key","FAHRZEUG_KENNUNG","VARCHAR(2)"],
         ["rvlt_test_a","rtsta_51_fahrzeug_hub",8,"business_key","FAHRZEUG_TYP","VARCHAR(20)"],
         ["rvlt_test_a","rtsta_51_fahrzeug_hub",8,"business_key","MANDANT","VARCHAR(20)"],
         ["rvlt_test_a","rtsta_51_fahrzeug_p1_sat",2,"parent_key","HK_RTSTB_FAHRZEUG","CHAR(28)"],
         ["rvlt_test_a","rtsta_51_fahrzeug_p1_sat",3,"diff_hash","RH_RTSTA_51_FAHRZEUG_P1_SAT","CHAR(28)"],
         ["rvlt_test_a","rtsta_51_fahrzeug_p1_sat",8,"content","MARKE","VARCHAR(200)"]
 ],
 "stage_table_column": [
         ["FZG_TY_1_U_2","VARCHAR(20)",8,"FZG_TY_1_U_2","VARCHAR(20)",false],
         ["FZG_TY_3","VARCHAR(20)",8,"FZG_TY_3","VARCHAR(20)",false],
         ["HK_RTSTB_FAHRZEUG_FZG1","CHAR(28)",2,null,null,false],
         ["HK_RTSTB_FAHRZEUG_FZG2","CHAR(28)",2,null,null,false],
         ["HK_RTSTB_FAHRZEUG_FZG3","CHAR(28)",2,null,null,false],
         ["KENN_1","VARCHAR(2)",8,"KENN_1","VARCHAR(2)",false],
         ["KENN_2","VARCHAR(2)",8,"KENN_2","VARCHAR(2)",false],
         ["KENN_3","VARCHAR(2)",8,"KENN_3","VARCHAR(2)",false],
         ["MANDANT","VARCHAR(20)",8,"MANDANT","VARCHAR(20)",false],
         ["MARKE_1","VARCHAR(200)",8,"MARKE_1","VARCHAR(200)",false],
         ["MARKE_2","VARCHAR(200)",8,"MARKE_2","VARCHAR(200)",false],
         ["MARKE_3","VARCHAR(200)",8,"MARKE_3","VARCHAR(200)",false],
         ["RH_RTSTA_51_FAHRZEUG_P1_SAT_FZG1","CHAR(28)",3,null,null,false],
         ["RH_RTSTA_51_FAHRZEUG_P1_SAT_FZG2","CHAR(28)",3,null,null,false],
         ["RH_RTSTA_51_FAHRZEUG_P1_SAT_FZG3","CHAR(28)",3,null,null,false]
 ],
 "stage_hash_input_field": [
         ["_FZG1","HK_RTSTB_FAHRZEUG_FZG1","FZG_TY_1_U_2",0,0],
         ["_FZG1","HK_RTSTB_FAHRZEUG_FZG1","KENN_1",0,0],
         ["_FZG1","HK_RTSTB_FAHRZEUG_FZG1","MANDANT",0,0],
         ["_FZG1","RH_RTSTA_51_FAHRZEUG_P1_SAT_FZG1","MARKE_1",0,0],
         ["_FZG2","HK_RTSTB_FAHRZEUG_FZG2","FZG_TY_1_U_2",0,0],
         ["_FZG2","HK_RTSTB_FAHRZEUG_FZG2","KENN_2",0,0],
         ["_FZG2","HK_RTSTB_FAHRZEUG_FZG2","MANDANT",0,0],
         ["_FZG2","RH_RTSTA_51_FAHRZEUG_P1_SAT_FZG2","MARKE_2",0,0],
         ["_FZG3","HK_RTSTB_FAHRZEUG_FZG3","FZG_TY_3",0,0],
         ["_FZG3","HK_RTSTB_FAHRZEUG_FZG3","KENN_3",0,0],
         ["_FZG3","HK_RTSTB_FAHRZEUG_FZG3","MANDANT",0,0],
         ["_FZG3","RH_RTSTA_51_FAHRZEUG_P1_SAT_FZG3","MARKE_3",0,0]
  ]    }');