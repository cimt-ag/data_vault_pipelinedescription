 -- drop table  dvpd_dictionary cascade;

  create table dv_pipeline_description.DVPD_DICTIONARY (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  pipeline_name VARCHAR(100),
  dvpd_json json,
  PRIMARY KEY ( pipeline_name)
  );