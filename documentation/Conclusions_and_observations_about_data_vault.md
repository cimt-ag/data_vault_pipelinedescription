Conclusions and Observerations about Data Vault models and loading 
==============================
(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)

---------

The rules, defined by the Data Vault concept itself, allow various kinds of models but also 
imply constraints, that are not explicitly formulated
 
Conclusions and obeserveraions about these variations and constraints 
are taken into account, when designing the DVPD syntax.

This article explains these aspects, to provide a better understanding about the 
decisions of the syntax design.

###  Deletion detection variations
Deletion detection is a complex problem. 
See [Deletion detection catalog](./deletion_detection_catalog.md)
for a full investigation about all possible variations
of deletion detection and how to describe it in a syntax
<br>The document contains explanations about: partitioned deletion detection


### Driving keys for a satellite must be applied by all loading processes
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

