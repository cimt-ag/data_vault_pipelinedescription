Data Vault - Catalog of field mappings in relations
==============================
(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)

---------

To create a toolset for loading data into a data vault model, we need to
determine the completeness of the toolset. 
This article investigates the different possibilites how the source fields are mapped,
when multiple relations to the same hub are delivered in one row. Example to this
requirement are:
- order, referring the customer in different roles (delivery and invoice).
- flight, referring the start and destination airport

# Definitions
When describing the data we classify the elements as follows:

**field:** smallest element of source data. Will always be processed as unity. Will be stored in one or multiple columns in the data vault.

**source row:** the fixed structure of fields, containing the data of one or more business-objects and their relation in a single row/unit. 

**table/hub/sat/link:** a table in the data vault model

**column:** a column in a table of the data vault model

**business key:** data, used to identify business objects

**table key/hub key/link key:** The join key of data vault model tables

**content:** Data that is not used for identification, and just stored in the data model

# Property of the source data

## Tabelarized + Normalized
Data can be complex in multiple ways, especially when it comes
to hierarchical data or document formats. The following approach uses
the source data representation after its transformaion into a single relational
table model(all data is organized in Rows, every row contains all fields).
Hierarchical data formats might need multiple transformations(one for each array).

Also data might not be fully normalized. 
This is given when there are fields, that target the same 
data vault columns **without** a different relational context. 
(e.g. a row with (PersonID1, Name1, PersonID2, Name2) or (Airportid,Runway1Length, Runway2Lenght)).
This kind of incoming datasets need to be normalized when extracting the, creating appropriate multiple rows.

# Informationtypes of data
To define the variety of mappings, it is necessary to clarify the types of information, represented by a field.

- Identification of an object
- Attribution or Measure of an object
- relation between objects (might be “self” relating, hierarchical)
- Attribution or Measure in a relation

*Note: The data vault main stereotypes map to this classification as follows.  hub=object / link=relation / satellite=attribution.*

*2nd Note: data that is stored in dependent child key columns of a link is also an identification type, since it is needed to identify attributes, that are attached with the satellite*


# Scenario combinatotions
Scenarios are described from the perspective of the hub, of the major object loaded. 

The model structure variations depend on:
- satellites with data on the major hub (0-2)
- number of partner hubs
     - linked individually to the major object hub (P1-P2)
     - linked together to the major object hub (T2)
- Link with dependent child key (D)
- satellites with data on links (Sl)
- effectivity satellite on link (E)
- satellites with data on partner hubs (Sh)
- modelling approach for multiple relations to the same hub 
    - multiple relations in the link (Rn)
    - multiple links (and effectivity satellites) (Ln)
    - multiple effectivity satellites on the same link (En)
- recursive link to the major object (C)

For fields in the source row, we can identify different mapping constellations
- all fields are mapped to one or more exclusive targets 
- some fields share target columns due to different relations to the same partner
- some fields with exclusive targets are only valid for specific relations (VS)
- some fields share target columns due to lack of normalization in the source.
This can be ignored in the mapping variations, since it should be eliminated by generating multiple rows during extraction and staging. Nevertheless DVPD needs a declaration for normalization to instruct the process to do so. 
    
## Notation and calatog
    <Hub and Hub satellite specification>-<link&sat for partner 1>-<link&sat for partner 2>
```
HS
HS2
HS-E-H
HS-DE-H
HS-S-H
HS-S-HS

HS-2RE-H
HS-2E-H
HS-2LE-H

HS-2RE-HS
HS-2RE-HSVs


HS-2S-HSVs
HS-ES-HSVs

1P2ShVS-R2E-E
1T2-E
1T2VS-E
1T2ShVS-E
1T2ShVS-R2E

Recursive
1VS-C


```

# Taxonomy 

## Single relation scenarios

### (1) M1 Single main object with content only 
The source row contains

- 1 set of fields with the business key of object A
- 1 set of fields with content of object A

![m1 mapping](./images/source_mapping_m1.drawio.png)

Example source: Table with product data

### (2) Single main object with content divided to two satellites

The source row contains

- 1 set of fields with the business key of object A
- 1 set of fields with content of object A, some for sat1 , some for sat2 and
somefor both

![fig pending](./images/figure_pending.drawio.png)


### (1P1-E) M1E1 Single main object with partner relation 
The source row contains

- 1 set of fields with the business key of object A
- 1 set of fields with content of object A
- 1 set of fields with the business key of object B

![m1e1 mapping](./images/source_mapping_m1e1.drawio.png)

Example source: Table with employee data including the current department he is working

### (1P1Sh-E)M1E1P1 Single main object and single partner object,both with content
The source row contains

- 1 set of fields with the business key of object A
- 1 set of fields with content of object A
- 1 set of fields with the business key of object B
- 1 set of fields with content of object B

![m1e1p1 mapping](./images/source_mapping_m1e1p1.drawio.png)

Example source: Table with data of manufactured items and the product+product description, the item belongs to

### (1P1-Sl) M1LS1 Single main object with content on single relation
The source row contains

- 1 set of fields with the business key of object A
- 1 set of fields with content of object A
- 1 set of fields with the business key of object B
- 1 set of field with content about relation of A and B

![m1ls1 mapping](./images/source_mapping_m1ls1.drawio.png)

### (1P1-DE) M1En Single main object with dependend child key relation
The source row contains

- 1 set of fields with the business key of object A
- 1 set of fields with content of object A
- more then 1 set of fields with the business key of object B representing another or the same relation

![fig pending](./images/figure_pending.drawio.png)



## Multiple relations between 2 hubs

### Single main object with multiple relations, separated businieskeys
The source row contains

- 1 set of fields with the business key of object A
- 1 set of fields with content of object A
- 2 set of fields with the business key of object B representing 
different relations

Example source: Table with contract data including the id of the person,that receives the delivery and the id of the person that pays the bill

#### (1P1-R2E) Modeled with multiple relations from 1 link

![fig pending](./images/figure_pending.drawio.png)

#### (1P1-E2) Modeled with 2 effectivity satellites

![m1en mapping](./images/source_mapping_m1en.drawio.png)

#### (1P1-E2) Modeled with 2 links and

![m1en mapping](./images/source_mapping_m1en.drawio.png)

###  (1P1-Sl2) M1LSn Single main object with content on multiple relations
The source row contains

- 1 set of fields with the business key of object A
- 1 set of fields with content of object A
- 2 sets of fields with the business key of object B representing 
different relations
- 2 sets of field with content about different the relations of A and B

![m1lsn mapping](./images/source_mapping_m1lsn.drawio.png)

Example source: Table with contract data including the id and current delivery rating of the person,that receives the delivery and the id and current credibilty rating of the person that pays the bill

### M1E1P1 Single main object and single partner object, both with content
The source row contains

- 1 set of fields with the business key of object A
- 1 set of fields with content of object A
- 1 set of fields with the business key of object B
- 1 set of fields with content of object B

![m1e1p1 mapping](./images/source_mapping_m1e1p1.drawio.png)

Example source: Table with data of manufactured items and the product+product description, the item belongs to



### M1EnP1 Single main object with multiple relations and content for one partner
The source row contains

- 1 set of fields with the business key of object A
- 1 set of fields with content of object A
- 2 or more sets of fields with the business key of object B representing another or the same relation
- 1 set of fields with content of object B for one specific set of business keys

![m1enp1 mapping](./images/source_mapping_m1enp1.drawio.png)

Example source: Table with contract data including the id, name and current delivery rating of the person,that receives the delivery and the id and current credibilty rating of the person that pays the bill

### MR1 single main object with self relation
The source row contains

- 1 set of fields with the business key of object A
- 1 set of fields with content of object A
- 2nd set of fields with the business key of object A (may share some field of first set) 

![mr1 mapping](./images/source_mapping_mr1.drawio.png)

Example source: Table with company data and the id of the company that owns this company


### Mn Multiple object sets 
The source row contains

- 2 or more sets of dedicated businesskey fields for every delivered object
- 2 or more sets of dedicated content fields for every delivered object
- optionally: shared set of fields with businesskey data, that is the same for all objects
- optionally: shared set of fields with content data, that is the same for all objects

![mn mapping](./images/source_mapping_mn.drawio.png)


## Combination Matrix

The following table shows all of the upper combinations in a comprehensive way.

| business key fieldsets of object A(main object) | Content fieldsets of object A | business key fieldsets of object B(related object) | Content fieldsets of B  | Content fieldsets for relation | Estimated ocurrence in regular projects | Covered by pattern  |
|:---------------------------------------------:|:-----------------------:|:-------------------------------:|:-----------------------:|:------------:|:-----------:|---------------------|
|                        1                        |                1                 |                         0                          |            0            |               0                |                   15%                   | M1                  |
|                        1                        |                1                 |                         1                          |            0            |               0                |                   55%                   | M1E1                |
|                        1                        |                1                 |                         1                          |            0            |               1                |                   10%                   | M1LS1               |
|                        1                        |                1                 |                         1                          |            1            |               0                |                   20%                   | M1E1P1              |
|                        1                        |                1                 |                         1                          |            1            |               1                |                   <1%                   | M1LS1+M1E1P1        |
|                        1                        |                1                 |                         2+                         |            0            |               0                |                   2%                    | M1En                |
|                        1                        |                1                 |                         2+                         |            0            |       same as ident of B       |                   <1%                   | M1LSn               |
|                        1                        |                1                 |                         2+                         |            1            |               0                |                   <1%                   | M1EnP1              |
|                       2+                        |                1                 |                         0                          |            0            |               0                |                   2%                    | MR1                 |
|                       2+                        |        same as ident of A        |                         0                          |            0            |               0                |                   <1%                   | Mn                  |

