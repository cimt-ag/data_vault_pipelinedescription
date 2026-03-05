# XENC - Extension for encryption


## Credits and license
(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)

# Disclaimer
This is an example, how to document extention keywords.

# Overview

The cimt datavault framework is a collection of python libararies and job pattern to implement datavault loading
processes. DVPD/DVPI are  used to provide the documentation and DDL scripts and to generate code snippets
that are copied into the final python code.

## Notation in this document
All keywords are prefixed with **xcdvf** as abreviation of **c**imt **d**ata**v**ault **f**ramework

The syntax description uses the same document structure like the "reference_of_core_syntax_elements".
The placement of a keyword in a section defines the possible position in the DVPD.

# Root

## tables[]
json path: /table

**xcdvf_msat_diff_logic**
(optional)
<br>*controls: loading function call, (diff hash calculation code block)*
<br>Declare the method, how a difference between staged data and actual data in the data vault can be
detemined in the loading procedure. The following options are available.

* ```group_hash``` (default):all rows of the same vault key have a diff hash column with the same value, calculated over the 
content of all rows of one key
* ```row_hash```: every row has a diff hash column, with a hash, caclulated over the content of just the row

Group hash is the default due to code legacy of the framework. The group hash method was the first and 
only method for many years.

