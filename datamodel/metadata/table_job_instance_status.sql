
-- DROP TABLE metadata.job_instance_status

CREATE TABLE metadata.job_instance_status (
	job_instance_id bigserial NOT NULL,
	process_instance_id int8 NULL,
	parent_id int8 NULL,
	process_instance_name varchar(255) NULL,
	job_name varchar(255) NULL,
	work_item varchar(1024) NULL,
	time_range_start timestamp NULL,
	time_range_end timestamp NULL,
	value_range_start varchar(512) NULL,
	value_range_end varchar(512) NULL,
	job_started_at timestamp NOT NULL,
	job_ended_at timestamp NULL,
	count_input int8 NULL,
	count_output int8 NULL,
	count_rejected int8 NULL,
	count_ignored int8 NULL,
	return_code int8 NULL,
	return_message varchar(1024) NULL,
	host_name varchar(255) NULL,
	host_pid int8 NULL,
	host_user varchar(128) NULL,
	CONSTRAINT job_instance_status_pkey PRIMARY KEY (job_instance_id)
);
