Data Vault Pipeline Description - Introduction and orientiation
==============================
(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)

---------

Data Vault Pipeline Description is a concept and syntax to provide a central data format, that can be 
used by all tools, needed and used during the design and implementation of data vault platforms.

Even though it is generally an easy to use concept, the description of all provided
elements and how to apply them needs some amount of words. Therefore the documentation is distributed 
over multiple articles.

This articles provides the overview, what you will find here.

PLEASE NOTE: **Knowledge about Data Vault modelling and loading procedures
is essential to understand the concept.**

Please consult approriate literature, to learn Data Vault first.

## The main articles

### [DVPD The Concept](./DVPD_The_Concept.md) 
The main article about the concept
* motivation of the concept
* Data Vault model and load requirements covered by the concept
* design descisions that have been made and are driving the syntax
* concepts behind the "non obvious purpose" syntax elements
* benefits of the concept for projects / consultants / tool developers

### [Data Vault method coverage and syntax examples](./Data_Vault_method_coverage_and_syntax_examples.md) 
Provides examples for Data Vult model, especially all model elements from the book "Building A Scalable Data Warehouse With Data Vault 2.0" by Dan Linstedt and Michael Olschimke from 2016. This is to prove the 
completness of the concept.

Besides from that, this is a good entry point to understand the core syntax by looking on examples.

### [Reference of code syntax elements](./Reference_of_core_syntax_elements.md) 
Defines and explains syntax and structure of the DVPD core syntax.

This article is highly formalized. The order of elements
is not always supporting a learing process.

### [Reference of model profile syntax](./Reference_of_model_profile_syntax.md) 
Defines and explains syntax and structure of the model profile syntax.

## Additional appliance descriptions

### [DVPD development workflows](./dvpd_developmment_workflow_scenarios.md) 
Descibes different project scenarios, how the DVPD should be integrated in the development workflow.

## Model and method investigations
Some requirements of the Data Vault Method are not directly described 
in the books, but are hidden as imlplicit conclusions. The following articles are investigating different aspects in the data vault method and explain the requirements that lead to some syntax concepts and design descisions.

### [Model topologies and basic field mapping variations](./Model_topologies_and_basic_field_mapping_variations.md)
This article provides a complete set of model topologies. The described topologies are ab
aggregation and combination of the basic patterns, described by the Data Vault modelling method. 

Also it explains the basic variations how fields of the source
record can be mapped.

Understanding both aspects is neessary to prove the completness of the syntax via test cases.

### [Catalog of field mappings in relations](./catalog_of_field_mappings_in_relations.md) 
Loading relations to the data vault model is getting complex, when the same hub, link or satellite must be loaded more then once for a single record (e.g. when loading hierachical link structures). This article investigates the scenarios and provides all the background needed to understand the relation concept in DVPD.

It also is one of the main drivers of testcases.

### [Deletion detection catalog](./deletion_detection_catalog.md)
Deletion detection is a complex problem on its own. 
The full investigation about all possible variationts
of deletion detection and how to describe it in a syntax is
placed in this document to shorten the central concept article.
