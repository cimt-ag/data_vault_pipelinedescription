DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test40_ref_simple_with_history';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test40_ref_simple_with_history','{
	"DVPD_Version": "1.0",
	"pipeline_name": "test40_ref_simple_with_history",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_AAA_VARCHAR", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_40_aaa_ref"}]},
		 	  {"field_name": "F2_BBB_DECIMAL",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_40_aaa_ref"}]},
		 	  {"field_name": "F3_CCC_XXXBADNAMEXXX_DATE",		"technical_type": "DATE",			"targets": [{"table_name": "rtjj_40_aaa_ref"
																											,"target_column_name":"F3_CCC_DATE"}]},
			  {"field_name": "F4_DDD_NOT_IN_RH__DECIMAL",		"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_40_aaa_ref","exclude_from_diff_hash": "true"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_40_aaa_ref",		"stereotype": "ref","diff_hash_column_name": "RH_rtjj_40_aaa_ref"}
				]
		}
	]
}
');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test40_ref_simple_with_history';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test40_ref_simple_with_history','{
	"dv_model_column": [
			["rtjj_40_aaa_ref",3,"diff_hash","RH_RTJJ_40_AAA_REF","CHAR(28)"],                   
			["rtjj_40_aaa_ref",8,"content","F1_AAA_VARCHAR","VARCHAR(20)"],                      
			["rtjj_40_aaa_ref",8,"content","F2_BBB_DECIMAL","DECIMAL(20,0)"],                    
			["rtjj_40_aaa_ref",8,"content","F3_CCC_DATE","DATE"],                                
			["rtjj_40_aaa_ref",8,"content_untracked","F4_DDD_NOT_IN_RH__DECIMAL","DECIMAL(5,0)"]
],
 "stage_table_column": [
			["F1_AAA_VARCHAR","VARCHAR(20)",8,"F1_AAA_VARCHAR","VARCHAR(20)",false],                        
			["F2_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_BBB_DECIMAL","DECIMAL(20,0)",false],                    
			["F3_CCC_XXXBADNAMEXXX_DATE","DATE",8,"F3_CCC_XXXBADNAMEXXX_DATE","DATE",false],                
			["F4_DDD_NOT_IN_RH__DECIMAL","DECIMAL(5,0)",8,"F4_DDD_NOT_IN_RH__DECIMAL","DECIMAL(5,0)",false],
			["RH_RTJJ_40_AAA_REF","CHAR(28)",3,null,null,false]                                            
]
}');                                                                                                              
