DELETE FROM dv_pipeline_description.dvpd_dictionary where pipeline_name = 'test41_ref_simple_without_history';
INSERT INTO dv_pipeline_description.dvpd_dictionary
(pipeline_name, dvpd_json)
VALUES
('test41_ref_simple_without_history','{
	"dvpd_version": "1.0",
	"pipeline_name": "test41_ref_simple_without_history",
	"record_source_name_expression": "dvpd implementation test",
	"data_extraction": {
		"fetch_module_name":"none - this is a pure generator test case"
	},
	"fields": [
		      {"field_name": "F1_AAA_VARCHAR", 		"technical_type": "Varchar(20)",	"targets": [{"table_name": "rtjj_41_aaa_ref"}]},
		 	  {"field_name": "F2_BBB_DECIMAL",	"technical_type": "Decimal(20,0)",	"targets": [{"table_name": "rtjj_41_aaa_ref"}]},
		 	  {"field_name": "F3_CCC_FIELDNAME_DATE",		"technical_type": "DATE",			"targets": [{"table_name": "rtjj_41_aaa_ref"
																											,"target_column_name":"F3_CCC_DATE"}]},
			  {"field_name": "F4_DDD_NOT_IN_RH__DECIMAL",		"technical_type": "DECIMAL(5,0)",	"targets": [{"table_name": "rtjj_41_aaa_ref","exclude_from_diff_hash": "true"}]}
			 ],
	"data_vault_model": [
		{"schema_name": "rvlt_test_jj", 
		 "tables": [
				{"table_name": "rtjj_41_aaa_ref",		"stereotype": "ref","is_historized": "false"}
				]
		}
	]
}
');

select dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW('test41_ref_simple_without_history');

DELETE FROM dv_pipeline_description.DVPD_ATMTST_REFERENCE  where pipeline_name = 'test41_ref_simple_without_history';
INSERT INTO dv_pipeline_description.DVPD_ATMTST_REFERENCE
(pipeline_name, reference_data_json)
VALUES
('test41_ref_simple_without_history','{
	"dv_model_column": [
				["rvlt_test_jj","rtjj_41_aaa_ref",8,"content","F1_AAA_VARCHAR","VARCHAR(20)"],                      
				["rvlt_test_jj","rtjj_41_aaa_ref",8,"content","F2_BBB_DECIMAL","DECIMAL(20,0)"],                    
				["rvlt_test_jj","rtjj_41_aaa_ref",8,"content","F3_CCC_DATE","DATE"],                                
				["rvlt_test_jj","rtjj_41_aaa_ref",8,"content_untracked","F4_DDD_NOT_IN_RH__DECIMAL","DECIMAL(5,0)"]
],
 "process_column_mapping": [
         ["rtjj_41_aaa_ref","_A_","F1_AAA_VARCHAR","F1_AAA_VARCHAR","F1_AAA_VARCHAR"],
         ["rtjj_41_aaa_ref","_A_","F2_BBB_DECIMAL","F2_BBB_DECIMAL","F2_BBB_DECIMAL"],
         ["rtjj_41_aaa_ref","_A_","F3_CCC_DATE","F3_CCC_FIELDNAME_DATE","F3_CCC_FIELDNAME_DATE"],
         ["rtjj_41_aaa_ref","_A_","F4_DDD_NOT_IN_RH__DECIMAL","F4_DDD_NOT_IN_RH__DECIMAL","F4_DDD_NOT_IN_RH__DECIMAL"]
 ], 
"stage_table_column": [
				["F1_AAA_VARCHAR","VARCHAR(20)",8,"F1_AAA_VARCHAR","VARCHAR(20)",false],                        
				["F2_BBB_DECIMAL","DECIMAL(20,0)",8,"F2_BBB_DECIMAL","DECIMAL(20,0)",false],                    
				["F3_CCC_FIELDNAME_DATE","DATE",8,"F3_CCC_FIELDNAME_DATE","DATE",false],                
				["F4_DDD_NOT_IN_RH__DECIMAL","DECIMAL(5,0)",8,"F4_DDD_NOT_IN_RH__DECIMAL","DECIMAL(5,0)",false]
]
}');                                                                                                              
