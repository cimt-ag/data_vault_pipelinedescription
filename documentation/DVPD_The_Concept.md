# Data Vault Pipeline Description - The Concept
(C) Matthias Wegner, cimt ag

Creative Commons License [CC BÝ-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)

# Introduction

Most Data Warehouse Platforms have unique properties and implementations depending on available budget, technology, types of data, types of usecases. Therefore the variety of tools for analyzing, modelling and implementing Data Warehouses ist large and will not get smaller in the future.

Even though the data vault approach provides a hugh leap to unifiy, generalize and standardize the modelling and loading of data, the toolset to implement data vault is fragmented and has mostly no interoperability.

At cimt ag we developed and adapted multiple variants of tools and frameworks to support the modelling and loading, depending on the needs and capabilities of our customers. Exchangebilty of our tools between different teams/projects was very limited. One major issue was the lack of a technology independent approach to describe the major asset, we always create: **The Data Vault Pipeline**

This concept defines a data structure with all necessary information to generate/implement/execute a data vault loading process. The structure is independent from any technology/product. It can be produced, converted and consumed by any tool, that wants to support it. This will allow development of tools with excellent functional support for a specific step in the implementation process rather then to trying solve all problems of a data warehouse more at once (and therefore more or less bad).

# DVPD as information base in the ecosystem of a data vault plattform
DVPD will act as the full information base to aggregate and transport all the information, collected or used in the various tasks to design, implement and operate a data warehouse plattform:
- fetch and parse the source data to get information about technical structure, content and increment pattern
- Design the Data Vault Model. Probably in a graphical form. 
- Define the mapping of all source fields to the Data Vault tables
- Add Data Vault specific columns to the table definitions (Hub/Link keys, Meta data,...)
- Check the model regarding compliance to conventions
- Check the new parts of the model about conflicts or redundancy with the existing model
- Generate ddl and deploy the final data base objects
- Implement the fetch/stage/load process 
- Create/Generate test cases/ test data
- Operate and monitor the loading processes
- Monitor technical indicators about the Data Vault content (Referential coherence, history depth and anomalies)
- Monitor business data quality (Nothing we would define in the DVPD)

![Fig1](./images/Grundidee_DVPD.drawio.png)

By using the DVPD as central exchange and information media, the tools are more loosly coupled. Adding or exchaning tools is more easy. Also the DVPD can be managed as an artifact, that can be versioned and processed in  CI/CD workflows (Testing, deployment).

# Requirements
In this chapter, we define the requirements for the DVPD to fullfill.

## Data Vault is the base
The Data Vault modelling and loading concept define are the major requirements about the necessary informataion, DVPD has to provide. The following Data Vault rules are taken into account, during the design:
- Data Vault Models consist of 4 main table stereotypes
    - **Hub Tables**: Keep the identification of the data objects by storing their business key columns. It is not forbidden (but not recommended) to put additional data columns in a hub,that have no impact to the identification.
	- **Link Tables**: Represent the relations between data objects. Sometimes the link table might have additional columns (dependent child keys) to provide extra identificational data for the relation, that is not creating a new business object. As like in hubs,it is not forbidden (but not recommended) to put additional data columns in a link, that have no impact on the identification.
	- **Satellite Table**: Store the attributes of data objects or relations. The data is generally historized to provide former states of the data.  Depending on the source, a sattelites might contain multiple rows for the same object (multiactive sattelite). For data that will change over time or gets deleted later, the satellites are the only source about the existence of objects and relations over time.
	- **Reference Table**: Store simple value lookup tables to expand or translate "codes". This is also often historized to provide former states
- Releations between Hub - Link -Sat Tables are implemented with single artificial key columns (Hub Keys, Link Keys).  The key values are determined by hashing the concatenated busineskeys/dependent child keys. To achieve consistent hash values for the same key column over different sources, the order of the columns must be configurable
- Relations between the stereotypes can only be the following
	- Hubs don't have any releation information by itself. They only provide the Hub Key together with the business key attributes
    - A Sattelite is related to exacly one hub or link by containing its Hub Key / Link Key
	- A Link is related to one or more hubs by containing their Hub Keys. Relations of two hubs are the most common case. Multiple relations to the same hub are possible (recursive relation) resuling in multiple columns for Hub Keys of the same Hub.
	- A Reference Table does not have any relation information by itself but is joined via the column depending on the transformation.
- All Tables must contain essential meta data columns
    - **Load_date**: Time, when the data was loaded to a specific table
	- **record source**: String, describing the source of the data
	- **load process id**: Identification of the process instance, that loaded the data to the table
- Satellite Table might contain also 
    - **deletion flag**: To provide explicit rows to indicat deletion of data in the source
    - **Load End date**: To provide the Load date of the replacing record during historization. This reduces query times when determining the valid version for a given point in time 
	- **diff hash**: Hash value of all columns in a satellite, that have to be compared to determine if incoming data has to be inserted or is already loaded
- Satellites releated to a link, determine the validity of the relation over time. In the common case, when a data source provides all valid relations of an object in the current load, it is necessary to mark obsolete relations as deleted, when relations change. This is achieved by declaring the Hub Keys of the loaded Object as "**driving keys**"

The approach is not restricted to raw vault loading. **Business Vault** loading works the same by using the transformation/aggregation resultset as input for the staging step. 


## Scope limitation
To enforce independency between loading processes and allow highly paralellized development, one DVPD  is restricted to describe the loading of only **one tablulated dataset** (every entity is represented by one row, all rows have the same field structure). Many common data source objects (DB table, CSV files) fullfill this requirement by definition. 

The Transformation of hierachical structured data (XML, JSON, ...), that has to be broken down into multiple tablulated subsets, needs to be described by one DVPD for each subset. Handling these related DVPDs as a coupled set is not required by the concept. It is up to the implementation process, to organize a kind of grouping, by adding a custom property or with simple naming convention.

The datavault model, described in one DVPD, should only contain the tables, necessary to load the source. The overall compatibilty of modells between different DVPDs in the project must be achieved by using an appropriate modelling process/toolset and/or some (automated) QA checking during the development process. 

## Mapping capabilites
Beside the simple singluar mapping of one field to one or more tables columns, also the of multiple fieldsto the same tables/columns must be supported. Common scenarios are mulitple foreign keys to the same partner, representing different releation types or havin two seperate data sets interwaeved in the same row. Last but not least the mapping for recursive links must be supported.
A complete set of require combinations is specified seperatly in  [Data Mapping taxonomie](./data_mapping_taxonomie.md).

## Loading processes
Beside the pure structural description of the Data Vault modell and the source data, the full loading process (or at least the coding of it) needs some more information, that has to be stored in the DVPD.
To determine these requirements, the following overall phase structure of a loading process is assumed:

![Fig2](images/General_pipeline_process.drawio.png)

### Deletion detection
Also not every kind of deletion detection can be described by a general set of parameters, the following common patterns must be supported
- Receiving an explicit "deletion" event from the source -> creating deletion stage records for the deleted key, announced in the event
- Comparing full or partioned lists of existing keys between source and vault -> creating deletion stage records for now missing keys
- Retreiving the full or partitioned dataset -> creating deletion records by comparing stage with vault

The term "partitioned" in this context means, that only a part of the full dataset is delivered and compared. The part is defined by the content of some classifing fields (e.g. "All contracts of a single company"). The partitions mostly correlate with the increment pattern of the source.


# Information content of the DVPD
In general terms: A DVPD conatins all parameters to describe the source and target data modell and the loading process. By relying on rules and conventions in the data vault method, many elements can be derived, wicht reduces the amount of declaration in many cases.
With the upper requirements in mind, the folling informations need to be described in the DVPD.

- necessary elements 
	 - Basic declarations about names of meta columns, data types for hash values, hash algorhythm, hash  separator and more (Modell Profile) 
	 - data vault model on table level (name, stereotype, relation, special columns)
	 - technical transportation protocol and parameters for contacting the data source
	 - parameters for the incremental loading pattern
	 - description to parse the incoming data structure into rows and fields
	 - mapping of the fields to the tables of the data vault model
	
- Optional elements, that will be needed for specific data constellations
	- Mapping of multiple fields to the same target column
	- Definition of deletion detection processing

- Optional elements, that will be derived from above if not declared
	- table structure of the data vault model column names and types
    - data content and order for calculation of all hash values

- Completly derived elements
    - structure of the staging table
	- mapping of source fields to the staging columns
	- list of process steps needed to load every target table
	- mapping of stage columns to target columnss for every process step

## Basic declarations
To model and load a Data Vault, some basic decisions about general rules and conventions have to be made. These main properties have to be declared for every DVPD to allow changes over time or different settings for different environments or technologies (even within the same platform). To enforce conformity over multiple DVPD, these settings are referenced as model profile by the DVPD. 

## data vault model on table level 
All tables in the data vault, that will be loaded by the DVPD must be declared by name, stereotype and stereotype specific properties.
- Hub: Name of the Hub Key
- Link: Name of the Link Key, names of the Hubs, related by the link. Names of recursive releations to hubs
- Satellite: Name of the Hub or Link, the Satellite is connected to, Name of the diff hash column(if used for change detection by the load module)
- Reference Table: Name of the diff hash column (if used for change detection by the load module)

Just using names to reference other tables in the model, requires unique table names over all tables in the data vault model, even when distributed over different systems and technologies. If that is not applicable in the data bases, the physical table names needs to be annotated as a property of the table declarations and have to be used during DDL generation an load processing.

## technical transportation protocol
Elements to declare here depend completly on the required method of transport. Therefore the core DVPD only will define a property to provide the name of the fetching module. Further parameters for the fetching module can be added into the DVPD. 

## Incremental pattern parameters
For fetching modules that support multiple incremental patterns or need some specification about its pattern. Names and meaning of the paramenters depend on the fetch module implementation.

## Description to parse the incoming data structure into rows and fields
For staging and mapping, the incoming data must be split up in data rows with a field structure. A field needs at least an identification/name and a data type to be used in the further process. Necessary properties to parse the field from the incoming data stream depend on the fetch or parsing module and should be declared at the field. 

## mapping of the fields to the tables of the data vault model
Every field must be mapped to one or more tables in the data vault model. This will result in equivalent columns in the target tables. Name and type of the target column might be changed by additional declarations. Also the participation and ordering of the column in key hashes and diff hashes can be modified.

## Mapping multiple fields to the same target column
- parent/child relations = Having two sets of businiesskeys for an objects hub and resulting in a recursive link
- multiple releations to a partner hub in the same row (e.g. different role relations from a contract to customer).

## Definition of deletion detection processing
The methods to detect deleted entities in the source, depends on the increment pattern. All methods reling on special retrieval and parsing of source data will need special implementations. Parameters for this depend on the execution module. For cases, where the deletion detecion can be applied by cross checking the currently staged data against the data vault content, a generic approach and set of parameters will be provided.

# Design priciple
- The DVPD should be selfdescribing for everybody familiar with Data Vault modelling and loading
- The description is driven primarily by the source structure. Changes to the source during the development should be easy editable, while ensuring consistency over all tables and processes. To achieve this the data vault model will be described only on table level as long as possible.
- The most common model constallations and field mappings should be described with the least effort. This is achieved by using proper default values for many options, so you can leave out these declaration in most cases.
- It should be possible to implement plausibility checks on the DVPD
- It must be maintainable with a text editor
   - human readable and arrangable to support readablity
   - Copy/paste friendly = structure prevents accidential copy of critical properties without thinking about the necessary changes
- Nearly free from conventions according naming and structure in sources and targets
   - Conventions should be enforced or applied by the toolchain (Modelling tool, Generators)
   - Not every tool in the design phase must support all necessary properties, as long as the DVPD is complete (contains all information) when it enters the Code Generation/Deployment/Execution phase.
- Parsing should be possible with a wide range of existing tools/frameworks

# Main Syntax structure

One DVDP is represented by a single json document. The root element contains general properies of the pipeline with subobjects to keep the details about fields, table model and more.

![fig](./images/dvpd_object_model.drawio.png)

The naming and description of all attributes in the structure is documented in [Reference of core syntax](./Reference_of_core_syntax_elements.md)

# Design decisions

- **Table names must be unique** over the full model regardless of spreading the model over multiple databases or database schemas. Beside of this to be a good practice for Data Vault models in general, this simplifies identfication of the tables in the various references in the DVDP and during the processing
- **Parent key column names are used in child tables**. Another good practice for Data Vault models is to use the same column name for hub/link keys in all connected child tables (links/satellites). This allows derivation of the key column names by using the parent relations and removes the necessity of multiple delarations for the same element. To prevent name collision of hub keys in the link table it is also best practice to have unique column names for the hub/link keys over the complete model. Enforcing any naming convention here (e.g. using the uniqe table name somehow) is left over to the implemention process and toolset.
- Links, that relate multiple times to the same hub (Hierarchial Link, Same As Link) are defined as **recursive link**. Since this a rare constellation, some more complex annotations are acceptable.  (see chapter below) 
- Mapping different fields from the source to the same table column in the target is achievd by using the **field group** (see chapter below)
- Basic declarations about names and types of the technical columns, hashing rules, ghost records, far future date etc. will be provided in a separate **Model profile** document. The DVPD must reference the Model Profile with its name.
- Configuration of the **Deletion Detection** is separated on purpose from the pure model definition to prevent accidential copy/paste errors. Also the inclusion of tables in the deletion detecion mechanics needs an explicit declaration. Deriving the tables would lead to complex investigations about the behaviour, when something goes not as expected
- JSON syntax
    - all objects and property names in DVPD are written in **lower case with underscores** (snake case)
	- For simple attributes and objects, key names are chosen in singular form. Only key to adress arrays are named in plural form
	- Identfication of DVPD objects(tables, fields etc) in the JSON text are expressed as attributes or array elements in the JSON object. This simplifies parsing, since there is no need to parse object names to get content. It also allows well formed JSON documents with intended DVPD inconsistencies  during during the design process of a pipeline. These inconsistencies must be catched later by QA checking


## Declaration of recursive parents
Declaraion of a recursive parent relation consist of multiple elements
- In the **recursive_parents** array of the link, the hub (already defined as parent) must be declared again. This additional relation must be identified with a **recursion_name**. 
- The "recursion_name" should describe the kind of relation and be useable to generate the name of the  additional hub key in the link and the additional stage column. (This is the only element, where the name of a relation describing element of the dvpd will be used in a generated name of the *final data vault data modell*)
- The mapping of fields, that contain the additional businesskeys, must be marked with the same "recursion_name". 
- Target_column name in the mapping of the "recursion busniess key fields" must be adapted via "target_column_name" to point to the correct business key column of the hub (probably the name of the fields keeping the main businiess key)

## Field groups	
Field groups are used to specify the mapping of multiple fields, that are targeting the same table columns.  
- For every "field to target mapping", the participation of this mapping in one or more field group can be declared using the **field_groups** array
- Tables without content (links/esat) can be limited to processed only with keys of specific field groups by declaring **tracked_field_groups**
- Mappings without a field group delclaraion belong to the implicit field group "_A_" and participate in all field groups declared on other mappings in the DVPD
- A single field group must only contain a set of fields, that do not overlap in their targets.
- Tables will be loaded for every field group they get related with. This is determined by
    - Explicit field_group declaration in the field mapping to the table
	- Explicit tracked_field_group declaraion at the table definition
	- Derived from the field groups, detected on connected satellites
	- Derived from the field groups of the parent

## Model Profile
All **basic properties of the data vault model and loading**, are defined in a model profile.
- Hashing properties
    - methods for keys and diff hashes
	- DB data types for the keys and diff hashes
	- Constants for ghost records and missing values
	- Separator to use in the concatenation
- Time values for far future and far past
- Names and types for meta data columns

These definitions might change over time or between different technical platforms. Therefore multiple model profiles can be declared. To support high consistency over the whole system, model profiles are kept seperatly from the DVPD document. The DVPD must refer to at least one model profile. When necessary, the model profile can be declared for every table, to enable the mixing of different settings.

All expected properties of the model profile are specifiend in [Model Profile reference](./reference_of_model_profile.md).


# Derivation of target model an processing
DVPD minimizes the amount of declaraions to describe model and load processing, by focussing on the source data structure and the target table model. This section describes how all other assest are derived from this base.

![derivation tree](./images/Ableitung.png)

## Data Vault model tables ##
The following elements are derived
- data columns of a table = all mapped fields deduplicated on target_column_name which defaults to the field name. Data type is target_column_type, which defaults to the field type and must be the same for all fields mapped to this target_column_name.
    - business key columns = columns mapped to a hub an not explicitly excluded from hash key
	- dependend child key columns = columns mapped to a link and not explicitly excluded from hash key
- Key column of satellites = Key column of its parent
- Hub Key columns in link = Key columns of all parents + recursive parents. Hub Key column names for recursive parents are created by concatenating the orginale hub key column and the recursion name
- meta data columns are created depending on the table stereotype 
	- deletion flag will be added for satellites
	- load enddate column will be added when "is_endated" is set to true
	
It is recommended to order the columns during table creation in a convinient arragement (e.g. Meta->key->parent_key in alphabetical order ->diff hash->data columns in alphabetical order ).

## Process steps ##
For every table to load, there will be at least one process step. Multiple steps are needed for loading multiple fields to the same Data Vault Table column. Steps are determined as follows:
- For all tables with field mappings that are restriced to a field group, plan a step for every field group
- Plan a normal and an extra load step for hubs, that are recursivly linked 
- Plan specific load steps for  satellites, where the parent has a field group specific step
- Plan specific load steps for links, where their childs have a specfic field group step
- Plan specific load steps for hubs, where their childs have a specfic field group step
- Plan general steps for all tables, that have no specific load step

The following figure shows differen scenarios, that must be solved and should be covered by an test setupts for the DVPD implementation.






	

# Glossary

**Business key**<br>
One or multiple ->fields containing data that identifies a business object

**Column**<br>
A column in a table of the data vault model

**DVPD = Data Vault Pipeline Description**<br>
Data Vault Pipeline Description - JSON document, describing one parsing and loading process in the specified JSON notation	

**Field**<br>
Smallest addressable element in the source data. Will always be processed as a unit. 

 







