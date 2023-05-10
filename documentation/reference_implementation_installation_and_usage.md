DVPD Reference Implementation Installation And Users Guide
=======================================================

The reference implementation serve to major goals:

- Test and prove the concept
- Provide orientation for other implementations

# Architecture and content of the reference implementation

The reference implementation focuses on the interpretation of the DVPD. The implementation platform is a postgreSQL Database extended by a small python script for automatic deployment of the data base objects.
The following elements are provided:

- Loading and compiling of a DVPD
    - Loading and parsing the JSON into a relational Model (Transform)
	- Checking the DVPD structure about completeness and consistency (Check)
	- Compiling the DVPD to provide all information to generate the model and drive the fetch/load processes (main views and tables)
- Automatic test of the compiler logic
    - Load reference data about the expected results of the compiler
	- compare compiler resultes with exoected results
	- Testsets
- Automatic deployment of compiler and automatic tests
- cimt framework for job execution logging

# Installation Guide

This project can be installed nearly automated on a PostgreSQL Database
by using the provided python scripts. 
**Knowledge about adminstration of postgreSQL and using Phython is required.**

Due to the huge number and the complex dependencies between the various data base objects, it is recommended, to use the automatic deployment. 
It is definitly requiered, when you need to prepare releases of the DVPD, since a full automatic deployment is a mandatory step before releasing.


### prepare the database
Installation operations are using a database user which is owner of the target database or at least is allowed to create schemas on the database. If you don't alreday have a user and database to be used, create it as follows:
* connect to the postgres instance as admin (eg. user "postgres")
* If not already in place, create a user, that will own the database "datamodel/database_creation/user_owner_data_vault.sql"
* ICreate the database by adapting and executing the provided script "datamodel/database_creation/database_data_vault.sql"
### configure python script environment
The python project needs some environment information for connecting 
* create a copy of the directory "config_template" as "config"
* further changes are done in the "config" directory
* edit "basic.ini" and set "ddl_root_path" to the full path pointing to the "datamodel" directory of the repository. This depends on the location of the procect.
* edit "pg_connect.ini" and adapt all connection parameters to your setup (DB, user, password)
* the following steps depend on your python environment/ide:
    * install psycopg2 module to your python environment
    * add the full path to the directory "data_vault_pipeline_description_poc" to the environment variable PYTHONPATH
### Deploy the project to the database
* execute the python script "processes/jobless_deployment/\_\_main__.py". This will deploy all objects listed in the files in datamodel/jobless_deployment in alphabetical order of the file names and the row order in the files.
* Check the end of the log output. The final summary should list only successfully deployed files
* in case of errors, you can target the deployment to a specific deployment file by 
adapting the \_\_main__.py. Check out the commented examples at the bottom of the script.
* in the database open the view dvpd_atmtst_catalog. This should list more then 40 tests
* open the view dvpd_atmsts_issue_all. 
This should list only a tests with number 99 (Test, that have issues on purpose)


# Procedures

## Compile a DVPD

## Add / Change DB objects, that belong to the implementation

## Add a new test case

## Prepare a new release

# Licence and Credits

(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)