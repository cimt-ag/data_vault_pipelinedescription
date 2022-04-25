-- DROP TABLE dv_pipeline_description.dvpd_pipeline_dv_table_link_parent_raw cascade;

CREATE TABLE dv_pipeline_description.dvpd_pipeline_dv_table_link_parent_raw (
	meta_inserted_at timestamp default now(),
	pipeline_name text NULL,
	table_name text NULL,
	parent_table_name text NULL,
	is_recursive_relation bool NULL,
	recursion_name text NULL,
	link_parent_order integer,
	recursive_parent_order integer
);