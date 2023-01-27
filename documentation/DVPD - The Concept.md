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

![Bild](./images/Grundidee_DVPD.drawio.png)

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
	- A Link is related to one or more hubs by containing their Hub Keys. Relations of two hubs are the most common case. Multiple relations to the same hub are possible (recursive relation) resulinh in multiple columns for Hub Keys of the same Hub.
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

## Loading processes
Beside the pure structural description of the Data Vault modell, the full loading process (or at least the coding of it) needs some more information, that has to be stored in the DVPD.
To determine these requirements, the following overall phase structure of a loading process is assumed:

!(images/General_pipeline_process.drawio.png)

The approach is not restricted to raw vault loading. Busieness Vault loading works the same by using the transformation/aggregation resultset as input for the staging step.

# Information content of the DVPD
In general terms: A DVPD conatins all parameters to describe the source and target data modell and the loading process. By reliing on rules and conventions in the data vault method, many elements 

- necessary elements 
	 - Basic declarations about names of meta columns, data types for hash values, hash algorhythm, hash  separator and more (Modell Profile) 
	 - data vault model on table level (name, stereotype, relation, special columns)
	 - technical transportation protocol and parameters for contacting the data source
	 - parameters for the incremental loading pattern
	 - description to parse the incoming data structure into rows and fields
	 - mapping of the field to the tables of the data vault model
	
- Optional elements, that will be needed for specific data constellations
	- Mapping multiple fields to the same target column
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
- Link: Name of the Link Key, names of the Hubs, related by the link. Names for recursive releations to hubs
- Satellite: Name of the Hub or Link, the Satellite is connected to, Name of the diff hash column(if used for change detection by the load module)
- Reference Table: Name of the diff hash column (if used for change detection by the load module)

Just using names to reference other tables in the model, requires unique table names over all tables in the data vault model, even when distributed over different systems and technologies. If that is not applicable in the data bases, the physical table names needs to be annotated as a property of the table declaration and have to be used in the DDL an processing.

## technical transportation protocol
Elements to declare here, depend completly on the required method of transport. Therefor the core DVPD only will define a property to provide the name of the fetching module. Further parameters for the fetching module can be added into the DVPD document. 

## Incremental pattern parameters
For fetching modules that support multiple incremental pattern or need some specification about its pattern. Names and meaning of the paramenters depend on the fetch module.

## Description to parse the incoming data structure into rows and fields
For staging and mapping, the incoming data must be split up in data rows with a field structure. A field needs at least an identification/name and a data type to be used in the further process. Necessary properties to parse the field from the incoming data stream depend on the fetch or parsing module and should be declared at the field. 

## mapping of the fields to the tables of the data vault model
Every field must be mapped to one or more tables in the data vault model. This will result in equivalent columns in the target tables. Name and type of the target column might be changed by additional declarations. Also the participation and ordering of the column in key hashes and diff hashes can be modified.

## Mapping multiple fields to the same target column
Sources with multiple columns targeting the same column in the data vault are an edge case appearing in mostly in every project. The most common data constellations are
- parent/child relations = Having two sets of businiesskeys for objects hub and resulting in a recursive link
- multiple releations to a partner hub in the same row (e.g. different role relations from a contract to customer). This also provides multiple sets of the business key of the related hub that
In [Data Mapping taxonomie](./data_mapping_taxonomie.md) the complete variety of theses mapping constellation is investigated. DVPD will support all constellations described.

## Definition of deletion detection processing
The methods of detection deleted entities in the source, depend on the increment pattern. All methods reling on special retrieval and parsing of source data will need special implementations. Parameters for this depend on the execution module. For cases, where the deletion detecion can be applied by cross checking the currently staged data against the data vault content, a generic approach and set of parameters will be provided.


## Essential best practices for Data Vault models
Data Vault has no further rules about structuring and naming of the objects in the modell. So in general, the DVPD must be open to support any kind von naming. Nevertheless. there are some best practices, which are highly recommended to support orientation in the model. 
- Have uniqe table names over the whole modell, regardless of spreading the model over multiple databases or database schemas
- Have uniqe names for the key columns (hub key/link key), and use the same name on all tables that are related

	

	



