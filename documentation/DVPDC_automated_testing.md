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

# test data
All testsets are stored in the repository directory "testsets_and_example" as follows
- dvdp: all dvpd files
- model_profiles: the model profiles used by the dvpd of the testset
- reference: the logfile of the compiler for every test and the expected dvpi file, for valid dvpd

## test process
Execution and evaluaton of the tests is implemented in the modul "test_dvpdc", wich is configured via "dvpdc.ini"
section "dvpdc_test".
The process calls the dvpdc for every test case, and compares the result log and dvpi with the reference data.

- With the parameter -t <testnumber> you can run the automated test for a specific test number.
- With the parameter -f <dvpd filename> you can run the automated test for a specific file in the test cases.
- Without explicit declaration of a file, dvpcd_test runs all tests, that are declared in its internal list.

# Conventions for tests content
The content of all  core testsets must follow the naming rules, described below. The goal of the rules is
to express the expected result, so it can be checked by eyesight very easy.

**test names / identifiers**
- All tests have a unique number
- The file names follow the pattern: t\<4 digit number>\[c]_\<essential description>.json.dvpd
    - \[c]: c after the number indicates this test to be only adressing the compiler check rules. No dvpi will be created.
    - examples t1000
- There are some legacy patterns we will transform over time: "test\<2 digit number>", "test_\<3digit number>"

The following number ranges are defined (a legacy from the proof the development):

| Range     | Focussed Features                            | 
|-----------|----------------------------------------------|
| 00 - 19   | Violation of validation rules                |
| 20 - 39   | Varations of basic data vault modelling      |
| 40 - 49   | Reference tables                             |
| 50 - 59   | multiple features in many variations at once |
| 60- 89    | relation variations (might be replaces by 100-999 later|
| 90 - 99   |model profile usage|
| 100-999   | relation process generation tests|
| 1000-1999 | any thing, that is not yet covered. Has no internal groups (yet) |


**pipeline declarations**
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
- format \<field position>\[\<rename trigger>]_\<target table identifier>_\<column class>\<sequence>\[F]\[_\<identifier for relation>]
    - \<field position>: F + position in the field array (e.g. F1, F2). This allows immediate identification of the field
    - \<rename trigger>: XX is added to the field position, when renameing in the column mapping is expected
    - \<target table identifier>: see identifer above in the table names 
    - \<column_class>: BK= Businesskey, DC= dependent child key, C= content, UC=untracked content
    - <sequence>: Sequence of the field in the target for the same columns classe
    - F: Is tagging the the field of a column class in the table (F=Finally) 
- Fields that are adressing 2 to 3 targets, concatinate the table identifiers and colummns classes, separated by "_" 
- Fields that are addressing more then 3 tragets, need more thinking about a good naming strategy
- Column renaming is done by removing XX from the name to the table identifier column class, sequence and F marking
- Columns that are adressed by multiple fields, will concatenate all field postions as prefix

Examples:
- F1_AAA_BK1F - Businesskey in Hub AAA. This is the final business key field for hub aaa
- F2_BBB_BK2  - Businesskey in Hub BBB. There must be a BK1 and at least one additional BK mapped to BBB
- F3_AAA_P1_C3 - Content in sattelite AAA_P1. There will be more content, and also there must be C1 and C2 in the sattelite
- F4_CCC_BK1F_DDD_BK2 - Field is mapped to CCC and DDD as business key. It is the final business key column in CCC
- F5XX_AAA_P2_C2 - Field is mapped to AAA P2 Satellite but must be renamed to AAA_BK2 
- F6F7_BBB_P1_C1 - Two fields are mapped to the same column in BBB Satellite P1

# test list
The following number ranges are defined (a legacy from the proof the development):

| Number        | Focussed Features                                                                           | 
|---------------|---------------------------------------------------------------------------------------------|
| **00 - 19**   | **Violation of validation rules**                                                           |
| 00            | Compiler must complain about missing essential syntax elements                              |
| 01            | Compiler must complain about bad model relations                                            |
| 02            | Compiler must complain about bad fiels mapping                                              |
| 03            | Compiler must complain about sattlite specifc violations                                    |
|               |                                                                                             |
| **20 - 39**       | **Varations of basic data vault modelling**                                                 |
|               |                                                                                             |
| **40 - 49**       | Reference tables**                                                                          |
|               |                                                                                             |
| **50 - 59**       | **multiple features in many variations, used in compiler development**                      |
|               |                                                                                             |
| **60- 89**        | **relation variations (might be replaces by 100-999 later**                                 |
|               |                                                                                             |
| **90 - 99**       | **model profile usage**                                                                     |
|               |                                                                                             |
| **100-999**     | see  [catalog_of_field_mappings_in_relations.md](catalog_of_field_mappings_in_relations.md) |                                                        |
| **1000-1999** | **Collection without central topic**                                                        |
|               |                                                                                             |
| **7xxx-9xxx** | **Compiler rule checks, based on cases in 100-999. Using the same 3 digit numbers**         |
|               |                                                                                             |

