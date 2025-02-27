Conclusions and Observerations about Data Vault models and loading 
==============================
(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)

---------

The rules, defined by the Data Vault concept itself, allow various kinds of models but also 
imply constraints an behaviors, that are not explicitly formulated.
 
The design of the DVPD syntax, takes the conclusions and obeserveraions about these variations and constraints 
are taken into account to provide necessary properties or reduce the expression effort where possible.

This article explains these aspects, to provide a better understanding about the 
decisions of the syntax design.

##  Deletion detection variations
Deletion detection is a complex problem. 
See [Deletion detection catalog](./deletion_detection_catalog.md)
for a full investigation about all possible variations
of deletion detection and how to describe it in a syntax
<br>The document contains explanations about: partitioned deletion detection


## Driving keys for a satellite must be applied by all loading processes
From the perspective of the data consumer, it es expected, that the satellite provides a consistent
representation of the relation, it stands for. When the satellites contains a 1:n relation, managed 
through driving keys, this must be true for all elements. 
Therefore, when multiple loading processes write to the same link satellite,
all processes must apply the same driving key rule. To help, keeping consistency between 
different DVPD the driving key directive is part of the satellite table definition (good chance
of copy/paste repitition)

Why do we discuss this so intense:

The procedure to manage a driving key constraint might look like a partitioned deletion detection,
where the driving key is the partition criteria.
But seeing the driving key deletion as a variation of deletion detection means,
that the appliance of it is source specific
and that there could be sources, which would explicitly provide the setting of the new and removal 
of the old relation.
This is not the case. When driving key logic is applied, the source is providing the change
of the relation by setting the foreign key value in the record to the new target. This implicitly 
ends the old relation.
The need for the extra deletion operation in the satellite comes from the data vault mechanics,
not from the source delivery behaviour. 

## preseving order of multi active data

For multi active data it might be necessary to preserve the order of the data in the transmission format, since there
might be a meaning to it.

To preserve the order of multi active data in the satellite, when the incoming data sets have no field with the order,
an artifical field with the "row number" must be added during the parsing.  

This lead to the syntax of the ${ROW_NUMBER...} placeholders for the "field_value" parameter.

## historization patterns for multi active data

Depending on the final pattern, how to separate
the data versions, when reading the satellite, the loading process needs additional declarations beside the normal satellite loading parameters.
The following options of historical data separations for multi active satellites are possible:
- every *value set*(expressed by the diff hash) for a key *is enddated* individually.  
- every *value set*(expressed by the diff hash) for a key is evaluated and managed individually during retrieval when there is no enddate  
- some columns have the property to be a subkey(multi active key). Evaluation and insertion/deletion for a key is done individually on subkey level
- every full group of value sets from a specific load for a key has the same load date  (and optionally the same end date)

Be aware, although the multiactive data loading procedure is able to grow and shrink the set of rows for a specific key, it is not
able to manage the reduction to zero rows for the key. Like for normal satellites, this event must be managed by the deletion detection.

### Individual enddating
With individual enddating, retrieving the valid data for a specific point in time is the same as reading from a 
normal enddated satellite: check the validity interval. 

```
hub key| load date |end date  |diff|  content 1    | content 2 

9a78raf| 2023-05-01|2999-09-09|qw2j| 1st delivery | still in the set
9a78raf| 2023-05-01|2023-05-05|k301| 1st delivery | gets changed in 5th delivery
9a78raf| 2023-05-05|2023-05-08|f298| 1st delivery | gets removed in 8th delivery
9a78raf| 2023-05-05|2999-09-09|asd9| 5th delivery | still in the set

gfo1721| 2023-05-07|2023-05-10|8faj| 7th delivery | gets totally removed in 10th delivery
```
The loading procedure needs an efficient way to 
- insert unknown data. This can be an additional value set or an *additional repition* of an already known value set
- enddate missing: This can be a value set, that is not in the source data anymore, or *with less repititions*

Managing the repetitions can be challenging.

Only the usual satellite parameters are needed to run this procedure. An enddate must be configured.

### Individual diff hash insertion
Without an enddate the valid data for a specific point in time is determined by
following the chain of load dates for every key **and diff hash** and excluding deletion flagged rows. This differs from 
a normal insert only satellite, that only needs to follow the key and deletion flag.

```
hub key| load date |deleted   |diff|  content 1   | content 2 

9a78raf| 2023-05-01|false     |qw2j| 1st delivery | still in the set
9a78raf| 2023-05-01|false     |f298| 1st delivery | removed in 8th delivery
9a78raf| 2023-05-08|true      |k301| #missing#    | #missing#
9a78raf| 2023-05-05|false     |asd9| 5th delivery | still in the set

dk29c43| 2023-05-01|false     |m3da| 1st delivery | adding repition on 2nd
dk29c43| 2023-05-02|false     |m3da| 1st delivery | adding repition on 2nd
dk29c43| 2023-05-02|false     |m3da| 1st delivery | adding repition on 2nd

dk29c43| 2023-05-01|false     |b2h9| 1st delivery | reducing repition on 2nd
dk29c43| 2023-05-01|false     |b2h9| 1st delivery | reducing repition on 2nd
dk29c43| 2023-05-02|false     |b2h9| 1st delivery | reducing repition on 2nd


gfo1721| 2023-05-07|false     |8faj| 7th delivery | gets totally removed in 10th delivery
gfo1721| 2023-05-10|true      |8faj| #missing#    | #missing#
```
The loading procedure needs an efficient way to 
- insert unknown data = Additional diff hash 
- insert changed repititions: since all valid repitions must have the same load date, the whole set of rows with the diff hash where repition has changed must be inserted

Only the usual satellite properties are needed to run this procedure. A diff hash should be configured.

### subkey (multi active key) evaluation and insertion/deletion 
This pattern will only be available on data sources, where you can define a subkey, that
will create uniqueness between rows of the same key. 

Without an enddate the valid data for a specific point in time is determined by
following the chain of load dates for every **sub key in a key of the satellite** and excluding deletion flagged rows.
This *needs knowledge about the subkey columns* while quering the data. How this is expressed or documented
depends on the project.

```
hub key| load date |deleted |diff|subkey|  content 1   | content 2 
9a78raf| 2023-05-01|false   |qw2j| 1.1  | 1st delivery | still in the set
9a78raf| 2023-05-01|false   |k301| 1.2  | 1st delivery | gets changed in 5th delivery 
9a78raf| 2023-05-05|false   |f298| 1.2  | 1st delivery | gets removed in 8th delivery
9a78raf| 2023-05-08|true    |----| 1.2  | #missing#    | #missing#
9a78raf| 2023-05-05|false   |asd9| 2.1  | 5th delivery | still in the set

gfo1721| 2023-05-07|false   |8faj| 3.1  | 7th delivery | gets totally removed in 10th delivery
gfo1721| 2023-05-10|true    |----| 3.1  | #missing#    | #missing#
```
The loading procedure needs an efficient way to 
- insert unknown data. This can be an additional subkey, or changed diff hash for a known subkey
- insert deletion record for missing, when a subkey isn't delivered any more

Since the combination of key and subkey is expected to be unique, repetitions are not possible.

For this procedure to work,  the fields, that belong to the subkey in the satellite must be
declared. This done with to the "is_muli_active_key" syntax in the target table mapping.

Beside this special handling during loading, the same information about the columns with key roles is
needed during retreival of the data, since it is needed to determin, wich row belongs to
actual data and wich to historized data.

### full group insertion
Without an enddate, retrieving the valid data for a specific point is the same as reading from a 
normal insert only satellite: Follow the chain of distinct load dates for the key of the sattellite
and exclude deletion flagged rows.

```
hub key| load date |deleted   |diff|  content 1   | content 2 

9a78raf| 2023-05-01|false     |qw2j| 1st delivery | still in the set
9a78raf| 2023-05-01|false     |k301| 1st delivery | gets changed in 5th delivery
9a78raf| 2023-05-05|false     |qw2j| 1st delivery | still in the set
9a78raf| 2023-05-05|false     |f298| 1st delivery | gets removed in 8th delivery
9a78raf| 2023-05-05|false     |asd9| 5th delivery | still in the set
9a78raf| 2023-05-08|false     |qw2j| 1st delivery | still in the set
9a78raf| 2023-05-08|false     |asd9| 5th delivery | still in the set

gfo1721| 2023-05-07|false     |8faj| 7th delivery | gets totally removed in 10th delivery
gfo1721| 2023-05-10|true      |----| #missing#    | #missing#
```
Loading procedure:
- determine if there is any change between current data and stage data for a key (compare and count diff hashes for a key)
- insert all rows for keys with changes (event if not all have changed)

As a result all valid rows in the interval will have the same loaddate.

This covers changes in repitions.

A diff hash is needed for efficient execution.

As with normal satellites the load procedure or data projectsion can be extendet to provice an enddate 
and therefore be much easier to query.

#### full group insertion with group diff hash
The full group insertion pattern can be optimized in execution by using a group diff hash load pattern. 
- calculate a group hash for every incoming satellite key, by concatenating all rows of the same satellite key
- use the group hash as diff hash for loading
- insert the whole group, when the last group hash in the satellite differs from the group hash in stage for a key

Resulting satellite will only differ in the pattern of the diff hashes, since all rows of the same load will have the same diff hash. 

```
hub key| load date |deleted   |diff|  content 1   | content 2 

9a78raf| 2023-05-01|false     |e1r1| 1st delivery | still in the set
9a78raf| 2023-05-01|false     |e1r1| 1st delivery | gets changed in 5th delivery
9a78raf| 2023-05-05|false     |h235| 1st delivery | still in the set
9a78raf| 2023-05-05|false     |h235| 1st delivery | gets removed in 8th delivery
9a78raf| 2023-05-05|false     |h235| 5th delivery | still in the set
9a78raf| 2023-05-08|false     |whsu| 1st delivery | still in the set
9a78raf| 2023-05-08|false     |whsu| 5th delivery | still in the set

gfo1721| 2023-05-07|false     |8faj| 7th delivery | gets totally removed in 10th delivery
gfo1721| 2023-05-10|true      |----| #missing#    | #missing#
```

To keep the group hashes constant, when the incoming data has different row order for
every delivery, an artifical ordering must be applied before hashing. This is supported by the syntax elements:
"prio_for_row_order" and "row_order_direction".

# more documents about model variations
### [Model topologies and basic field mapping variations](./Model_topologies_and_basic_field_mapping_variations.md)
This article provides a complete set of model topologies. The described topologies are an
aggregation and combination of the basic patterns, described by the Data Vault modelling method. 

Also it explains the basic variations how fields of the source
record can be mapped.

Understanding both aspects is neessary to prove the completeness of the syntax via test cases.

### [Catalog of field mappings in relations](./catalog_of_field_mappings_in_relations.md) 
Loading relations to the data vault model is getting complex, when the same hub, link or satellite must be loaded more then once for a single record (e.g. when loading hierachical link structures). This article investigates the scenarios and provides all the background needed to understand the relation concept in DVPD.

It also is one of the main drivers of testcases.

