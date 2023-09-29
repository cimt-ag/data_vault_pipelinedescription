# XENC - Extention for encryption


## Credits and license
(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)

# Overview

DVPD is open for extentions, to allow to add features. XENC is a first applience of this concept.

The encryption extention adds syntax and compiler transformations, that allow the declaration, generation and loading
of encryption key shadows tables. 

# Encryption key shadow table concept in a nutshell
The encryption key shadow table concept extends the data model with additional tables for every data vault table that
keeps one or more columns, that have to be encrypted. Main reason to do this, is to reach compliance to the
European General Data Protection Regulation (GDPR).

Source fields, that need to be protected, will be encrypted with row specific enryption keys. The encyption keys are stored in
a shadow table, with one table for every data vault table. The data vault model will only keep the encrypted values, where
it is treated like any other data and will never be touched again.
To proviede the encryption key for decryption, the Data Vault table only has to be joined to the corresponding 
encryptionkey table.

To delete data, from specific objects, the encryption keys are overwritten in the shadow tables, leaving the data vault
untouched.

There are some more technical constraints and rules, that have to be followed for fast and reliable
processing, but this goes beyond scope of this documentation. Please contact cimt-ag.de for further 
information.

# Description of the DVPD Extention for encryption keys
The extention provides new stereotypes and key words, to declare the shadow tables and connect them to their partner.

The transformation provides the following:
- full column declaration for the shadow tables
    - meta columns, depending on stereotype and settings
    - key and diff hash columns, with names derived from source
    - encryption key column
    - encryption key index column on satellites
    - hash columns and hash rules to support fast loading of recurring data to hubs and links
- Additional columns in the main tables of the dv model
    - encryption key index column on satellites
- Extended mappings from stage to target
- Additional stage table to prepare the loading of the keys into the key tables


# Extention of DVPD Syntax  

### tables[]
subelement of data_vault_model[] 

**table_stereotype**
(mandatory)
<br>The xenc extention adds the following stereotypes: xenc_hub-ek, xenc_lnk-ek, xenc_sat-ek
<br>Depending on the stereotype, different properties have to be provided.
The stereotype controls the processing for the load. 

Tables with xenc sterotype follow a strict column structure and must not be the target of any field 

| Column                                            | hub   | lnk   | sat                |  
|---------------------------------------------------|-------|-------|--------------------|
| load date                                         | yes   | yes   | yes                |
| record source                                     | yes   | yes   | yes                |
| run id                                            | yes   | yes   | yes                |
| load end date                                     | no    | no    | depends on setting |
| deletion flag                                     | no    | no    | depends on setting |
| active flag                                       | no    | no    | depends on setting |
| key column of partner table                       | yes   | yes   | yes                |
| encrpytion key                                    | yes   | yes   | yes                |
| encryption key index                              | no    | no    | yes                |
| hash of not encrypted business keys               | yes   | no    | no                 |
| salted_hash of not encrypted business keys        | yes   | no    | no                 |
| hash of not encrypted dependent child keys        | no    | yes   | no                 |
| salted hash of not encrypted dependent child keys | no    | yes   | no                 |

The xenc stereotypes support some key words of their native data vault stereotype


**xenc_content_table_name**
(mandatory)
<br>Name of the table, this encryption key table is attached to. This must be a valid hub, link or 
satellite table, that has at least one "needs_encryption"=true field mapped.

xenc_encryption_key_column_name
(optional)
<br>Name of the column, that keeps the encryption key. 
The default is: "EK_"<name of the connected table>

xenc_encryption_key_index_column_name
(optional)
<br>Name of the column, that keeps the encryption key index. 
The default is: "EKI_"<name of the connected table>

xenc_content_hash_column_name
(optional)
<br>Name of the column, that keeps the hash of the not encrypted content (business keys, dependent child keys). 
<br>The default for Hubs is: "BKH_"<name of the connected table>
<br>The default for Links is: "DCH_"<name of the connected table>

xenc_content_salted_hash_column_name
(optional)
<br>Name of the column, that keeps hash of the the salted not encrypted content (business keys, dependent child keys). 
<br>The default for Hubs is: "BKH_"<name of the connected table>"_st"
<br>The default for Links is: "DCH_"<name of the connected table>"-st"

xenc_table_key_column_name
<br>Name of the key in the table. 
The default is the name of the key column in the connected table


# Extention of Model profile key words

**xenc_encryption_key_column_type**
(mandatory, when using the encryption extention)<br>
SQL datatype of the column, to store the encryption keys.
<br>*CHAR(28)*

**xenc_encryption_key_index_column_type**
(mandatory, when using the encryption extention)<br>
SQL datatype of the column, to store the encryption key index.
<br>*INT8*

**xenc_content_hash_column_type**
(mandatory, when using the encryption extention)<br>
SQL datatype of the column, to store the content diff hash in the encryption key tables.
<br>*CHAR(28)*

**xenc_content_hash_function**
(mandatory, when using the encryption extention)<br>
Name of the hash function to use when hashing diff for the encryption key tables. Valid names depend on the implementation of the staging. Recommended values are common lowercase names of the functions(md5, sha-1, sha-256) 
<br>*sha-1*

**xenc_content_hash_encoding**
(mandatory, when using the encryption extention)<br>
Name of the method to encode the content hash value. This can be "binary" (default) or any other method supported by the database and implementation of the staging.
Recommended values are common lowercase names of methods for encoding binary values: (binary, hex, base64)
<br>*BASE64*

