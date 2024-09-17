# DVPD Core Element Syntax Reference
DVPD additional elements described here are recommended to be used with the purpose, described here to gain high compatibility between different tools

The syntax is an extention of the core syntax. For the main structures, please look into   [Reference_of_core_syntax_elements.md](Reference_of_core_syntax_elements.md)


# Root 

**analysis_full_row_count**
(optional)
*purpose: analysis documentation, test set generation*
<br> The number of rows in the source, available during the content analysis

**analysis_sample_row_count**
(optional)
*purpose: analysis documentation, test set generation*
<br> The number of rows, used for the conent analysis of the source

## fields[]
json path: /

**cardinality**
(optional)
*purpose: analysis documentation, test set generation*
<br>Contains the number of distinct values, that have been found in this field during analysis. This number might be determined
from a representative sample of the source data set. 

**duplicates**
(optional)
*purpose: analysis documentation, test set generation*
<br>Contains the number of duplicate value entries.  This number might be determined
from a representative sample of the source data set. 

**is_primary_key** (optional)
*purpose: analysis documentation, test set generation*
<br>Default: false. 
<br>Set to true, when the source object attributes this field as part of its primary key

**is_foreign_key**
*purpose: analysis documentation, test set generation*
<br>Default: false. 
<br>Set to true, when the source object attributes this field as part of a foreign key declaration

**null_values** (optional)
*purpose: analysis documentation, test set generation*
<br>Number of rows, having a  NULL value in the field.This number might be determined
from a representative sample of the source data set. 


# License and Credits

(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)