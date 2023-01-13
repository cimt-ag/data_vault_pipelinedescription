-- =====================================================================
-- Part of the Cimt Job Instance Framework
--
-- Copyright 2023 cimt ag
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =====================================================================


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
