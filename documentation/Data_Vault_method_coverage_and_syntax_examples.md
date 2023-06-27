# Data Vault stereo type coverage and examples
The following examples provides a field and model DVPD declaration for all official data vault stereotypes and their variations. All examples, referring to stereotypes in the book "Building A Scalable Data Warehouse With Data Vault 2.0" by Dan Linstedt and Michael Olschimke from 2016, are marked with "{DV-\<chapternumber>}". 

To be easy understandable, the examples use simplified table and column names that don't follow all best practices. For the same reason, not all examples are matched to the data vault book.

Some properties of the DVPD can be declared on the level of the **model profile**.  All examples refer to the following, most common, profile settings:
```json
{	"insert_criteria": "key+actual",
	"uses_diff_hash_default": true,
	"is_enddated_default": true,
	"has_deletion_flag_default": true
}
```

## Hub tables
### Hub with a single column business key {DV-4.3}
```json
"fields": [
		      {"field_name": "AIRLINE_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "airline_hub"}]},

			  ...
	],
"tables": [
		      {"table_name": "airline_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_AIRLINE"}

			  ...
		]
```

### Hub with a composite business key {DV-4.3.1.1}
This example assumes, that customer id's are not unique over the different web shops, the data is collected from. Therfore the web shop id must also be used for identification.
```json
"fields": [
		      {"field_name": "WEBSHOP_ID",  "field_type": "integer", "targets": [{"table_name": "customer_hub"}]},
		      {"field_name": "CUSTOMER_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "customer_hub"}]}

			  ...
		],
"tables": [
		      {"table_name": "customer_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_CUSTOMER"},
		]
```

### Hub with a last seen date {DV-4.3.2.5}
```json
"fields": [
		      {"field_name": "TAILNUM",  "field_type": "Varchar(20)", "targets": [{"table_name": "airline_hub"}]},
		      {"field_name": "LASTSEENDATE",  "field_type": "TIMESTAMP",
			  "field_value":"${LOAD_TIMESTAMP}", "targets": [{"table_name": "airline_hub", "exclude_from_key_hash":true, "update_on_every_load":true}]},

			  ...
	],
"tables": [
		      {"table_name": "airplane_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_AIRPLANE"}

			  ...
		]
```


## Link tables
### Link connecting two hubs {DV-4.3}
An order and its related customer
```json
"fields": [
		      {"field_name": "ORDER_ID",  "field_type": "integer", "targets": [{"table_name": "order_hub"}]},
		      {"field_name": "CUSTOMER_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "customer_hub"}]}
	],
"tables": [
			  {"table_name": "order_customer_link", "table_stereotype": "lnk",  "link_parent_tables": ["order_hub","customer_hub"]},

		      {"table_name": "order_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_ORDER"},
		      {"table_name": "customer_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_CUSTOMER"}
		]
```

### Link connecting three hubs {DV-4.4.2}
Example of a car rental relation.
```json
"fields": [
		      {"field_name": "VEHICLE_ID",  "field_type": "integer", "targets": [{"table_name": "car_hub"}]},
		      {"field_name": "CUSTOMER_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "customer_hub"}]},
			  {"field_name": "STATION_NAME",  "field_type": "Varchar(20)", "targets": [{"table_name": "station_hub"}]}
	],
"tables": [
			  {"table_name": "car_customer_station_link", "table_stereotype": "lnk",  "link_parent_tables": ["car_hub","customer_hub","station_hub"]},

		      {"table_name": "car_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_CAR"},
		      {"table_name": "customer_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_CUSTOMER"},
		      {"table_name": "station_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_STATION"},
		]
```

### Link with two hubs, but one with two relations {DV-4.4.4}
```json
"fields": [
		      {"field_name": "CARRIER_ID",  "field_type": "integer", "targets": [{"table_name": "carrier_hub"}]},
		      {"field_name": "SOURCEAIRPORT_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "airport_hub","link_branch_name":"SOURCE"}]},
			  {"field_name": "DESTINATIONAIRPORT_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "airport_hub","link_branch_name":"DEST"}]}
	],
"tables": [
			  {"table_name": "car_customer_station_link", "table_stereotype": "lnk",  "link_parent_tables": [{"table_name":"carrier_hub"},
			  						 {"table_name":"airport_hub","link_branch_name":"SOURCE"}
									 {"table_name":"airport_hub","link_branch_name":"DEST"}]},

		      {"table_name": "carrier_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_CARRIER"},
		      {"table_name": "airport_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_AIRPORT"},
		]
```

### Link with dependent child key columns {DV-4.4.5.2}
Dependend child keys are declared by mapping fields to link tables.
```json
"fields": [
		      {"field_name": "WEBSHOP_ID",  "field_type": "integer", "targets": [{"table_name": "webshop_hub"}]},
		      {"field_name": "PRODUCT_ID",  "field_type": "integer", "targets": [{"table_name": "product_hub"}]},
		      {"field_name": "SELLING_MONTH",  "field_type": "integer", "targets": [{"table_name": "webshop_sale_report_link"}]},
		      {"field_name": "SELLING_YEAR",  "field_type": "integer", "targets": [{"table_name": "webshop_sale_report_link"}]},
			  {...}
	],
"tables": [
			  {"table_name": "webshop_sale_report_link", "table_stereotype": "lnk",  "link_parent_tables": ["webshop_hub","product_hub"]},

		      {"table_name": "webshop_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_WEBSHOP"},
		      {"table_name": "product_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_PRODUCT"}
		]
```

### Same As Link
The source for a "same as" Link contains the business key of the main object and the business key of its duplicate. The following example "deduplicates" products.
```json
"fields": [
		      {"field_name": "PRODUCT_ID",  "field_type": "integer", "targets": [{"table_name": "product_hub"}]},
		      {"field_name": "SAME_PRODUCT_ID",  "field_type": "integer", "targets": [{"table_name": "product_hub", "column_name":"PRODUCT_ID"
									,"link_branch_name":: "DUPLICATE"}]},
	],
"tables": [
			  {"table_name": "product_duplicate_saslink", "table_stereotype": "lnk",  "link_parent_tables": [{"table_name":"product_hub"},
			     			  		{"table_name":"product_hub","link_branch_name":"DUPLICATE"}]},

		      {"table_name": "product_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_PRODUCT"}
		]
```

### hierachical link
This is an example of a product hierarchy.
```json
"fields": [
		      {"field_name": "PART_ID",  "field_type": "integer", "targets": [{"table_name": "product_hub"}]},
		      {"field_name": "CONTAINING_PART_ID",  "field_type": "integer", "targets": [{"table_name": "product_hub", "column_name":"PART_ID"
			  			,"link_branch_name": "CONTAINED_BY"}]},
	],
"tables": [
			  {"table_name": "product_containment_hlink", "table_stereotype": "lnk",  "link_parent_tables": [{"table_name":"product_hub"},
			     			  		{"table_name":"product_hub","link_branch_name":"CONTAINED_BY"}]},

		      {"table_name": "product_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_PRODUCT"}
		]
```

### non historized link
```json
"fields": [
		      {"field_name": "ACCOUNT_NO",  "field_type": "integer", "targets": [{"table_name": "account_hub"}]},
		      {"field_name": "ACCOUNTANT_ID",  "field_type": "varchar(20)", "targets": [{"table_name": "accountant_hub"}]},
		      {"field_name": "BOOKING_ID",  "field_type": "varchar(22)", "targets": [{"table_name": "product_hub"}]},
		      {"field_name": "BOOKING_TIME",  "field_type": "varchar(22)", "targets": [{"table_name": "product_hub"}]},
			  {"field_name": "AMOUNT",  "field_type": "decimal(12,2)", "targets": [{"table_name": "product_hub"}]},

	],
"tables": [
			  {"table_name": "account_booking_tlink", "table_stereotype": "lnk",  "link_parent_tables": ["account_hub","accountant_hub"]},
		      {"table_name": "account_booking_tlinksat", "table_stereotype": "sat",  "satellite_parent_table": "account_booking_tlink"
			  													,"is_enddated": false, "has_deletion_flag":false,"insert_criteria":"key"}

		      {"table_name": "account_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_ACCOUNT"},
		      {"table_name": "accountant_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_ACCOUNTANT"}
		]
```
### exploration link
An exploration link is declared like any other link by declaring the hubs, that are connected by the link and the link itself. The main difference to normal links comes from the sourcing of the business keys, that will be selected from the raw vault. (a drirective to take  hub key values from the source dataset instead of recalculating it, will be added in later versions)

## Satellite tables

### Normal Satellite on a hub
```json
"fields": [
		      {"field_name": "PRODUCT_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_hub"}]}
		      {"field_name": "NAME",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_sat"}]}
		      {"field_name": "CLASS",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_sat"}]}
	],
"tables": [
		      {"table_name": "product_sat", "table_stereotype": "sat",  "satellite_parent_table": "product_hub",
			  													"diff_hash_column_name": "DIFF_PRODUCT_SAT"},

			  {"table_name": "product_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_PRODUCT"}

		]
```
### multiple satellites on a hub
```json
"fields": [
		      {"field_name": "PRODUCT_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_hub"}]}
		      {"field_name": "NAME",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_slow_sat"}]}
		      {"field_name": "CLASS",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_slow_sat"}]}
		      {"field_name": "PRICE",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_fast_sat"}]}
		      {"field_name": "PRIORITY",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_fast_sat"}]}
	],
"tables": [
		      {"table_name": "product_slow_sat", "table_stereotype": "sat",  "satellite_parent_table": "customer_hub",
			  													"diff_hash_column_name": "DIFF_PRODUCT_SLOW_SAT"}
		      {"table_name": "product_fast_sat", "table_stereotype": "sat",  "satellite_parent_table": "customer_hub",
			  													"diff_hash_column_name": "DIFF_PRODUCT_FAST_SAT"},

			  {"table_name": "product_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_PRODUCT"}

		]
```
### Satellite on a link, with a driving key declaration
```json
"fields": [
		      {"field_name": "ORDER_ID",  "field_type": "integer", "targets": [{"table_name": "order_hub"}]},
		      {"field_name": "PRODUCT_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_hub"}]},
			  {"field_name": "PRICE",  "field_type": "DECIMAL(16,2)", "targets": [{"table_name": "order_product_sale_sat"}]},
			  {"field_name": "QUANTITY",  "field_type": "DECIMAL(8,0)", "targets": [{"table_name": "order_product_sale_sat"}]},
	],
"tables": [
			  {"table_name": "order_product_sale_sat", "table_stereotype": "sat",   "satellite_parent_table": "order_product_link",
			  													"driving_keys": ["HK_ORDER"],
																"diff_hash_column_name": "DIFF_ORDER_PRODUCT_SALES_SAT",},
			
			  {"table_name": "order_product_link", "table_stereotype": "lnk",  "link_parent_tables": ["order_hub","product_hub"]},
		      {"table_name": "order_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_ORDER"},
		      {"table_name": "product_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_PRODUCT"}
		]
```

### Multi-Active Satellite
```json
"fields": [
		      {"field_name": "PRODUCT_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_hub"}]}
		      {"field_name": "CATEGORY",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_msat"}]}
		      {"field_name": "WEIGHT",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_msat"}]}
	],
"tables": [
		      {"table_name": "product_msat", "table_stereotype": "sat",  "is_multiactive":"true", "satellite_parent_table": "product_hub",
			  													"diff_hash_column_name": "DIFF_PRODUCT_MSAT"},

			  {"table_name": "product_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_PRODUCT"}

		]
```

### Tracking Satellite 1
In this example, the CDC information contains a change timestamp from the source system. This is used prevent reloading CDC information, already received. We skip the creation of a diff hash, since the data is very small.
```json
"fields": [
		      {"field_name": "PRODUCT_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_hub"}]}
		      {"field_name": "CHANGE_TIMESTAMP",  "field_type": "timestamp", "targets": [{"table_name": "product_tracksat"}]}
		      {"field_name": "OPERATION",  "field_type": "Varchar(3)", "targets": [{"table_name": "product_tracksat"}]}
	],
"tables": [
		      {"table_name": "product_tracksat", "table_stereotype": "sat",  "satellite_parent_table": "product_hub",
			  													"uses_diff_hash":"false"},

			  {"table_name": "product_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_PRODUCT"}

		]
```

### Tracking satellite 2
In this example, the CDC information contains no data about the sequence of events. Duplication of data by reloading the same events must be prevented by orchestration.
```json
"fields": [
		      {"field_name": "PRODUCT_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_hub"}]}
		      {"field_name": "OPERATION",  "field_type": "Varchar(3)", "targets": [{"table_name": "product_tracksat"}]}
	],
"tables": [
		      {"table_name": "product_tracksat", "table_stereotype": "sat",  "satellite_parent_table": "product_hub",
			  													"insert_criteria":"none"},

			  {"table_name": "product_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_PRODUCT"}

		]
```

### Effectivity satellite on a link
An effectivity satellite is a sattellite on a link without any field mappings. The compiler will detect this and provide this assumption in the is_effectivity_sat table attribute.
```json
"fields": [
		      {"field_name": "ORDER_ID",  "field_type": "integer", "targets": [{"table_name": "order_hub"}]},
		      {"field_name": "PRODUCT_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_hub"}]},
	],
"tables": [
			  {"table_name": "order_product_sale_esat", "table_stereotype": "sat",   "satellite_parent_table": "order_product_link",
			  													"driving_keys": ["HK_ORDER"]},
			
			  {"table_name": "order_product_link", "table_stereotype": "lnk",  "link_parent_tables": ["order_hub","product_hub"]},
		      {"table_name": "order_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_ORDER"},
		      {"table_name": "product_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_PRODUCT"}
		]
```

### Normalized record tracking satellites
Record tracking information must be inserted every time we get it
```json
"fields": [
		      {"field_name": "PRODUCT_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_hub"}]}
		      {"field_name": "APPERANCE",  "field_type": "integer", "targets": [{"table_name": "product_rectracksat"}]}
	],
"tables": [
		      {"table_name": "product_rectracksat", "table_stereotype": "sat",  "satellite_parent_table": "product_hub",
			  													"insert_criteria":"none"},

			  {"table_name": "product_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_PRODUCT"}

		]
```


### Normalized record tracking satellites keeping only last record
Record tracking information must be inserted every time we get it, but previous recordings are removed to keep the table small.
```json
"fields": [
		      {"field_name": "PRODUCT_ID",  "field_type": "Varchar(20)", "targets": [{"table_name": "product_hub"}]}
		      {"field_name": "APPERANCE",  "field_type": "integer", "targets": [{"table_name": "product_rectracksat"}]}
	],
"tables": [
		      {"table_name": "product_rectracksat", "table_stereotype": "sat",  "satellite_parent_table": "product_hub",
			  													"insert_criteria":"none","history_depth_criteria":"versions","history_depth_limit":0},

			  {"table_name": "product_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_PRODUCT"}

		]
```

## "ref" tables

### "ref" simple {DV-6.3.1}
```json
"fields": [
		      {"field_name": "ISO_3166_ALPHA_2",  "field_type": "Varchar(2)", "targets": [{"table_name": "country_code_ref"}]}
		      {"field_name": "ISO_3166_ALPHA_3",  "field_type": "Varchar(2)", "targets": [{"table_name": "country_code_ref"}]}
		      {"field_name": "ISO_3166_NUMERIC",  "field_type": "Varchar(3)", "targets": [{"table_name": "country_code_ref"}]}
	],
"tables": [
		      {"table_name": "country_code_ref", "table_stereotype": "ref","is_enddated": "false"},
		]
```

### "ref" historized (hub/sat) {DV-6.3.2}
```json
"fields": [
		      {"field_name": "DAY_DATE",  "field_type": "DATE", "targets": [{"table_name": "calender_hub"}]},
		      {"field_name": "FISCAL_YEAR",  "field_type": "integer", "targets": [{"table_name": "calender_sat"}]},
			  {"field_name": "FISCAL_QUATER",  "field_type": "integer", "targets": [{"table_name": "calender_sat"}]}
	],
"tables": [
		      {"table_name": "calender_sat", "table_stereotype": "sat",  "satellite_parent_table": "calender_hub","uses_diff_hash":false},
			  {"table_name": "calender_hub", "table_stereotype": "hub",  "hub_key_column_name": "HK_CALENDER"}
		]
```

### "ref" historized (single table)
This is a non historized reference table extendet by an enddate. The enddate is set by a load, where the specific value combination is not present in the source. 
```json
"fields": [
		      {"field_name": "ISO_3166_ALPHA_2",  "field_type": "Varchar(2)", "targets": [{"table_name": "country_code_ref"}]}
		      {"field_name": "ISO_3166_ALPHA_3",  "field_type": "Varchar(3)", "targets": [{"table_name": "country_code_ref"}]}
		      {"field_name": "ISO_3166_NUMERIC",  "field_type": "Varchar(3)", "targets": [{"table_name": "country_code_ref"}]}
	],
"tables": [
		      {"table_name": "country_code_ref", "table_stereotype": "ref"},
		]
```

### "ref" - code and descriptions {DV-6.3.3}
```json
"fields": [
		      {"field_name": "GROUP",  "field_type": "Varchar(20)", "fiels_value":"StdOpCode",
			  			"is_partitioning":true,"targets": [{"table_name": "codes_ref"}]}
		      {"field_name": "STANDARD_OPERATIONS_CODE",  "field_type": "Varchar(20)", "targets": [{"table_name": "codes_ref","column_name":"CODE"}]}
		      {"field_name": "DESCRIPTION",  "field_type": "Varchar(255)", "targets": [{"table_name": "codes_ref"}]}
	],
"tables": [
		      {"table_name": "codes_ref", "table_stereotype": "ref","is_enddated": "false"},
		]
```

### "ref" - code and descriptions, historized (hub/sat) {DV-6.3.3.1}
```json
"fields": [
		      {"field_name": "GROUP",  "field_type": "Varchar(20)", "fiels_value":"StdOpCode",
			  			"is_partitioning":true,"targets": [{"table_name": "code_hub"}]}
		      {"field_name": "STANDARD_OPERATIONS_CODE",  "field_type": "Varchar(20)", "targets": [{"table_name": "code_hub","column_name":"CODE"}]}
		      {"field_name": "DESCRIPTION",  "field_type": "Varchar(255)", "targets": [{"table_name": "code_sat"}]}
	],
"tables": [
		      {"table_name": "code_hub", "table_stereotype": "hub", "hub_key_column_name": "HK_CODE"},
		      {"table_name": "code_sat", "table_stereotype": "sat", "satellite_parent_table": "code_hub","uses_diff_hash":false}
		]
```

### "ref" - code and descriptions, historized (single table)
This is a non historized reference table extendet by an enddate. The enddate is set by a load run, where the specific value combination of the group is not present in the source. Declaration to restrict enddating to the group is done with the "is_partitioning" property.
```json
"fields": [
		      {"field_name": "GROUP",  "field_type": "Varchar(20)", "fiels_value":"StdOpCode",
			  			"is_partitioning":true, "targets": [{"table_name": "codes_ref"}]}
		      {"field_name": "STANDARD_OPERATIONS_CODE",  "field_type": "Varchar(20)", "targets": [{"table_name": "codes_ref","column_name":"CODE"}]}
		      {"field_name": "DESCRIPTION",  "field_type": "Varchar(255)", "targets": [{"table_name": "codes_ref"}]}
	],
"tables": [
		      {"table_name": "codes_ref", "table_stereotype": "ref","diff_hash_column_name": "DIFF_CODES_REF"},
		]
```

## Snapshot tables
*The syntax for snapshot tables (point in time tables, bridge tables) will be added in future versions. From the current perspective this will be a new stereotype "snapshot" with properties to declare the participating links and satellites, the definition of the source for the timeline, the management of the time windoe and granularity and the structural assets (naming of the  columns, columnset for every connected asset (loaddate, key, flag))*

### Point in time tables
*to be defined later*

### Bridge tables
*to be defined later*
