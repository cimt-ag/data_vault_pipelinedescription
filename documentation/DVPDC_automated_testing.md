DVPDC - Automtated testing
==============================
(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)

---------

To verify the DVPD usablitiy and DVPDC functionality, various scenarios are implemented
as testsets. Paired with a referece resultset, these allow to check 
- if DVDP syntax is able to express all variants of data vault modells and mappings
- if the DVPDC is able to transform all valid DVPD into a DVPI
- if the DVPDC is able to detect and report rule violations in the DVPD

# Setup 
All testsets are stored in the repository directory "testsets_and_example" as follows
- dvdp: all dvpd files
- model_profiles: the model profiles used by the dvpd of the testset
- reference: the logfile of the compiler for every test and the expected dvpi file, for valid dvpd

Execution and evaluaton of the tests ins implemented in the modul "test_dvpdc", wich is confgured via "dvpdc.ini"
section "dvpdc_test".

# Conventions for tests content
The content of all  core testsets must follow the naming rules, described below. The goal of the rules is
to express the expected result, so it can be checked by eyesight very easy.

**test names / identifiers**
- All tests have a unique number
- The file names start with
    - test: for valid DVPD
    - ctest: for invalid DVPD, where the comipile should deliver specific error messages
- The following number ranges are defined (a legacy of the developtment):

**Pipeline declarations**
- pipeline_name: identical to the filename
- pipeline_comment: "Test for " + Description of the usecase / constellation /  this tests is targeting
- data_extraction/fetch_module_name: "none - this is a pure generator test case"

**Names in the data model**
- the main schema is "rlvt_text_jj" with the shortcut "rtjj"
- for multi schema test cases, additional schemas are named by progressing in the alphabet (kk,ll,mm)
- table names are structured as follows: \<schema shortcut>_\<testnumber>_\<identifier>_\<stereotype>
    - \<schema_shortcut>: rtjj, rtkk, rtll ...
    - \<identifier for hubs> 3 times a letter from A to G (e.g. AAA,BBB)
    - \<identifier for links> identifiers of all connected hubs separated by "_" + optional \<identifier for relation>
    - \<identifier for sattelites> identifier of parent + part identification (p1, p2, ...) or optional \<identifier for relation>
    - \<identifier for relations> 3 times a letter from T to W (e.g. TTT,UUU)
    - \<stereotype> extended stereotype postfix (e.g. hub, sat, lnk, dlnk, esat,msat,...)
    - **examples: rtjj_55_aaa_hub, rtjj_22_aaa_bbb_lnk, rtjj_20_aaa_p1_sat, rtjj_55_aaa_bbb_ttt_esat**
- name for the key columns are equal to their table as follows.
    - a 2 letter prefix declares if it is a key of a hub (HK) or a key of a link (LK)
    - name of the table, without the stereotype postfix
    - **examples**: HK_rtjj_64_aaa, LK_rtjj_22_aaa_bbb
    - 
**Field names and mappings**
Fieldnames express the target of the field, to provide easy control of the correct mapping.  
- format \<field position>\[\<rename trigger>]_\<target table identifier>_\<column class>\<sequence>\[F]\[_<identifier for relation>]
    - \<field position>: F + position in the field array (e.g. F1, F2). This allows immediate identification of the field
    - \<rename trigger>: XX is added to the field position, when renameing in the column mapping is expected
    - \<target table identifier>: see identifer above in the table names 
    - \<column_class>: BK= Businesskey, DC= dependent child key, C= content, UC=untracked content
    - <sequence>: Sequence of the field in the target for the same columns classe
    - F: Is tagging the the field of a column class in the table (F=Finally) 
- Fields that are adressing 2 to 3 targets, concatinate the table identifiers and colummns classes, separated by "_" 
- Fields that are addressing more then 3 tragets, need more thinking about a good naming strategy
- Column renaming is done by reducing the name to the table identifier column class, sequence and F marking

Examples:
- F1_AAA_BK1F - Businesskey in Hub AAA. This is the final business key field for hub aaa
- F2_BBB_BK2  - Businesskey in Hub BBB. There must be a BK1 and at least one additional BK mapped to BBB
- F3_AAA_P1_C3 - Content in sattelite AAA_P1. There will be more content, and also there must be C1 and C2 in the sattelite
- F4_CCC_BK1F_DDD_BK2 - Field is mapped to CCC and DDD as business key. It is the final business key column in CCC
- F5XX_AAA_P2_C2 - Field is mapped to AAA P2 Satellite but must be renamed to AAA_BK2 
