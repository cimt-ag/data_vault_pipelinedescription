

/* generate sql to change ownership of all relevant schemas and objects to owner_dwh */

SELECT 'ALTER SCHEMA  '
		 || schema_name
 		|| '  OWNER TO owner_dwh;' as sqlstatement
FROM information_schema.schemata
where (schema_name like 'rvlt%' OR schema_name like 'bvlt%' or schema_name like 'mart%' or schema_name like 'stage%' or schema_name in ('metadata','template'))
union all
 SELECT 'ALTER TABLE  '
		|| table_schema ||'.'|| table_name 
 		|| '  OWNER TO owner_dwh;' as sqlstatement
FROM information_schema."tables"
where (table_schema like 'rvlt%' OR table_schema like 'bvlt%' or table_schema like 'mart%'  or table_schema like 'stage%' or table_schema in('metadata','template'))