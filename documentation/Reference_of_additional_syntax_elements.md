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

## Data Extraction
json path: /

### for Module "json_array"
json path: /data_extraction

**json_array_path**
(optional)
*purpose: parsing of source*
<br>*this syntax is a proposal and has not been used in code yet*
<br>Json path of the object, that contains the array with the final row granularity. When the array is nested into parent
arrays, that also need to be iterated over, these parent arrays must be declared with [*]. 

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

**json_path** (optional)
*purpose: parsing of source*
<br>*this syntax is a proposal and has not been used in code yet*
<br>Contains the json path, to determine the data of the field in a json document. 
Depending on the parsing module, this declaration can be left out, when the field name is the same as the json path.

The expression always starts on the "looped" Element (see json_loop_level). 
The expression must lead to a single value or a Json subobject.
Even though a path staring at the json document root can be declare by starting using "$" it
is recommended to express all hierarchy navigation with the "json_loop_level"


**json_loop_level** (optional)
*purpose: parsing of source*
<br>*this syntax is a proposal and has not been used in code yet*
<br>Defines the loop level, the json path is beginning. Level 0 (= the default) is the loop of the row granularity. To address elements of parent objects to the row object, the level must be decreased. -1 = direct parent, -2 = Parent of parent and so on.
(Loop levels are used to iterate over hierarchical stacked arrays)


# License and Credits

(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)