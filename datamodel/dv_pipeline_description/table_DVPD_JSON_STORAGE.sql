 -- drop table dv_pipeline_description.DVPD_JSON_STORAGE cascade;

  create table dv_pipeline_description.DVPD_JSON_STORAGE (
  meta_inserted_at TIMESTAMP DEFAULT NOW(),
  object_class VARCHAR(100),
  object_name VARCHAR(100),
  object_json json,
  PRIMARY KEY ( object_class, object_name )
  );
  
 comment on table  dv_pipeline_description.DVPD_JSON_STORAGE is 
 'Table to store the json input texts for pipelines and profiles';