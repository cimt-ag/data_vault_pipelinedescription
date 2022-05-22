Data Vault Pipeline Description proof of concept and reference
==============================================================

This is an implementation of the "Data Vault Description Pipeline" concept. 
It is used for
* testing and extending the core concept
* providing a implementation reference and testcases for other implementations

The detailed concept is documented in the [cimt confluence](https://cimtag.atlassian.net/wiki/spaces/CW/pages/3159719975/Data+Vault+Pipeline+Description+Standard+DVPD)

# Installation Guide
## Full setup with postgreSQL and Python  
This project can be installed nearly automated on a PostgreSQL Database
by using the provided python scripts
### prepare the database
Installation operations are using a database user which is owner of the target database
or at least is allowed to create schemas on the database.
* connect to the postgres instance as admin (eg. user "postgres")
* Create the necessary user by adapting and executing the provided script "datamodel/database_creation/users/owener_dwh.sql"
* Create the database by adapting and executing the provided script "datamodel/database_creation/create_database.sql"
### configure python script environment
The pyhton project needs some environment information for execution
* create a copy of the directory "config_template" as "config"
* further changes are done in the "config" directory
* edit "basic.ini" and adapt the full path to the "datamodel" directory. 
This depends on the location of the procect.
* edit "pg_connect.ini" and adapt all connection parameters to your setup
### Deploy the project to the database
* execute the python script "processes/jobless_deployment/\_\_main__.py"
* Check the end of the log output. The report should list only successfully deployed files
* in case of errors, you can target the deployment to a specific deployment file by 
adapting the \_\_main__.py. The alphabetical order of deployment is essential due to dependencies
* open the view dvpd_atmtst_catalog. This should list more then 40 tests
* open the view dvpd_atmsts_issue_all. 
This should list only a tests with number 99 (Test, that have issues on purpose)
## Manual Minimal setup on DB of your choice
to be formulated. First notes:
* necessary tables and views (base tables, derivation logic, checks) 
* adaption of views (aggregation functions sometimes differ from postgreSQL implementation)
* loading from json to base tables

