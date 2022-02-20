 -- drop table  dv_pipeline_description.DVPD_ATMTST_REFERENCE cascade;

  create table dv_pipeline_description.DVPD_ATMTST_REFERENCE (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  pipeline_name VARCHAR(100),
  reference_data_json json,
  PRIMARY KEY ( pipeline_name)
  );