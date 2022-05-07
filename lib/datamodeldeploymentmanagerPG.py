import os

from psycopg2 import Error

from lib.configuration import configuration_load_ini


# define a function that handles and parses psycopg2 exceptions
def print_psycopg2_exception(err):
    print("\npsycopg2 Diagnostic:")
    print("\nextensions.Diagnostics:", err.diag)
    print("pgerror:", err.pgerror)
    print("pgcode:", err.pgcode, "\n")


class DataModelDeploymentManager:
    """Object to setup datamodel objects in a target database"""

    def __init__(self, db_connection):
        self._db_connection = db_connection
        self._ddl_root_path = ""

        params = configuration_load_ini('basics.ini', 'ddl_deployment')
        self.ddl_root_path = params['ddl_root_path']

    def deploy_schema(self, schema_name):
        """Deploy create schema script from DDL repository if necessary (will deploy schema if missing)"""
        check_cursor = self._db_connection.cursor()
        check_cursor.execute(f"""select count(1) from information_schema.schemata
                                where lower(schema_name)=lower(%s)""", (schema_name,))
        result_row = check_cursor.fetchone()
        if result_row[0] == 0:  # schema is not present in DB
            self._deploy_normal_script(schema_name, f"schema_{schema_name.upper()}.sql")
            self._apply_default_grants()

    def deploy_table(self, schema_name: str, table_name: str):
        """Deploy create table script from DDL repository if necessary (will deploy schema if missing)"""
        check_cursor = self._db_connection.cursor()
        check_cursor.execute("""select count(1) from information_schema.tables
                                where lower(table_schema)=lower(%s)
                                and lower(table_name)=lower(%s)""", (schema_name, table_name))
        result_row = check_cursor.fetchone()
        if result_row[0] == 0:  # table is not present in DB
            self.deploy_schema(schema_name)
            self._deploy_normal_script(schema_name.lower(), f"table_{table_name.upper()}.sql")
        else:
            print("DDL Deployment Manager: Table already deployed:", table_name)

    def deploy_stage_table(self, schema_name, table_name):
        """Deploy create table script from DDL repository if necessary (will deploy schema if missing)"""
        if schema_name[0].lower() == 'r' or schema_name.lower() == 'template':
            stage_schema = 'stage_rvlt'
        elif schema_name[0].lower() == 'b':
            stage_schema = 'stage_bvlt'
        else:
            raise Exception("Could not determine stage schema. Unknown prefix")

        check_cursor = self._db_connection.cursor()
        check_cursor.execute("""select count(1) from information_schema.tables
                                where lower(table_schema)=lower(%s)
                                and lower(table_name)=lower(%s)""", (stage_schema, table_name))
        result_row = check_cursor.fetchone()
        if result_row[0] == 0:  # table is not present in DB
            self.deploy_schema(schema_name.lower())
            self._deploy_stage_script(schema_name.lower(), stage_schema, f"table_{table_name.upper()}.sql")
        else:
            print("DDL Deployment Manager: Stage Table already deployed:", table_name)

    def deploy_stage_view(self, schema_name, view_name, force_deploy=False):
        """Deploy view script from DDL repository if necessary (will deploy schema if missing). Script must include
           "drop view if exists ... cascade;" statement"""
        if schema_name[0].lower() == 'r' or schema_name.lower() == 'template':
            stage_schema = 'stage_rvlt'
        elif schema_name[0].lower() == 'b':
            stage_schema = 'stage_bvlt'
        else:
            raise Exception("Could not determine stage schema. Unknown prefix")

        check_cursor = self._db_connection.cursor()
        check_cursor.execute("""select count(1) from information_schema.views
                                where lower(table_schema)=lower(%s)
                                and lower(table_name)=lower(%s)""", (schema_name, view_name))
        result_row = check_cursor.fetchone()
        if result_row[0] == 0 or force_deploy:  # table is not present in DB
            self.deploy_schema(schema_name)
            self._deploy_stage_script(schema_name.lower(), stage_schema, f"view_{view_name.upper()}.sql")
        else:
            print("DDL Deployment Manager: View already deployed:", view_name)

    def deploy_view(self, schema_name, view_name, force_deploy=False):
        """Deploy view script from DDL repository if necessary (will deploy schema if missing). Script must include
           "drop view if exists ... cascade;" statement"""
        try:
            check_cursor = self._db_connection.cursor()
            check_cursor.execute("""select count(1) from information_schema.views
                                    where lower(table_schema)=lower(%s)
                                    and lower(table_name)=lower(%s)""", (schema_name, view_name))
            result_row = check_cursor.fetchone()
        except Error as err:
            print('ERROR during dictionary check')
            print("pgerror:", err.pgerror)
            print("pgcode:", err.pgcode, "\n")
            raise
        if result_row[0] == 0 or force_deploy:  # table is not present in DB
            self.deploy_schema(schema_name)
            self._deploy_normal_script(schema_name, f"view_{view_name.upper()}.sql")
        else:
            print("DDL Deployment Manager: View already deployed:", view_name)

    def deploy_matview(self, schema_name, matview_name, force_deploy=False):
        """Deploy materialized 'matview' script from DDL repository if necessary (will deploy schema if missing).
            Script must include "drop materialized view if exists ... cascade;" statement"""
        check_cursor = self._db_connection.cursor()
        # --for mat_views
        # --select * from pg_matviews;
        check_cursor.execute("""select count(1) from pg_matviews
                                where lower(schemaname)=lower(%s)
                                and lower(matviewname)=lower(%s);""", (schema_name, matview_name))
        result_row = check_cursor.fetchone()
        if result_row[0] == 0 or force_deploy:  # table is not present in DB
            self.deploy_schema(schema_name)
            self._deploy_normal_script(schema_name, f"matview_{matview_name.upper()}.sql")
        else:
            print("DDL Deployment Manager: Materialized View already deployed:", matview_name)

    def deploy_function(self, schema_name, function_name):
        """Deploy functionm script from DDL repository if necessary"""
        self.deploy_schema(schema_name)
        self._deploy_normal_script(schema_name, f"function_{function_name.lower()}.sql")

    def execute_testdata_insert(self, schema_name, test_name):
        """Execute the insert script that resides in testdata directory"""
        self._execute_testdata_insert_script(schema_name, f"insert_{test_name.lower()}.sql")

    def execute_data_insert(self, schema_name, data_name):
        """Execute the insert script that resides in deployment directory"""
        self._execute_data_insert_script(schema_name, f"data_{data_name.lower()}.sql")

    def _deploy_normal_script(self, schema_name, file_name):
        full_path = f"{self.ddl_root_path}/{schema_name.lower()}/{file_name}"
        print("Deploying:", schema_name, file_name)
        self._deploy_script(schema_name, full_path)

    def _deploy_stage_script(self, schema_name, stage_schema, file_name):
        full_path = f"{self.ddl_root_path}/{schema_name}/stage_tables/{file_name}"
        print("Deploying Stage :", schema_name, file_name)
        self._deploy_script(stage_schema, full_path)

    def _execute_testdata_insert_script(self, schema_name, file_name):
        full_path = f"{self.ddl_root_path}/{schema_name}/tests_and_demos/{file_name}"
        print("Executing testdata insert script :", schema_name, file_name)
        self._deploy_script(schema_name, full_path)

    def _execute_data_insert_script(self, schema_name, file_name):
        full_path = f"{self.ddl_root_path}/{schema_name}/{file_name}"
        print("Executing data insert script :", schema_name, file_name)
        self._deploy_script(schema_name, full_path)

    def _deploy_script(self, schema_name, file_path):
        if not os.path.exists(file_path):
            raise Exception("Could not find script:" + file_path)
        current_statement = ""
        in_dollar_quote = False
        deploy_cursor = self._db_connection.cursor()
        with open(file_path) as file:
            script_line = file.readline()
            while script_line:
                if not script_line.strip().startswith("--"):
                    current_statement += script_line
                    if script_line.strip().startswith("$$"):
                        in_dollar_quote = not in_dollar_quote
                    if script_line.rfind(";") >= 0 and not in_dollar_quote:  # One Statement complete
                        print("Script Execute: vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv")
                        print(current_statement)
                        print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
                        try:
                            deploy_cursor.execute(current_statement)
                        except Error as err:
                            # pass exception to function
                            print_psycopg2_exception(err)
                            raise
                        current_statement = ""
                script_line = file.readline()

        if len(current_statement.strip()) > 0:  # still some letters in the buffer
            print("Script Execute: vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv")
            print(current_statement)
            print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
            try:
                deploy_cursor.execute(current_statement)
            except Error as err:
                # pass exception to function
                print_psycopg2_exception(err)
            raise

        self._db_connection.commit()

    def _apply_default_grants(self):
        full_path = f"{self.ddl_root_path}/database_creation/users/grant_schema_defaults_basics.sql"
        if not os.path.exists(full_path):
            raise Exception("Could not find DDL script:" + full_path)
        self._deploy_script('', full_path)

        full_path = f"{self.ddl_root_path}/database_creation/users/grant_schema_defaults_generic.sql"
        if not os.path.exists(full_path):
            raise Exception("Could not find DDL script:" + full_path)

        print("adding default grants")
        generator_statement = ""
        with open(full_path) as file:
            script_line = file.readline()
            while script_line:
                if not script_line.strip().startswith("--"):
                    generator_statement += script_line
                script_line = file.readline()
        deploy_cursor = self._db_connection.cursor()
        deploy_cursor.execute(generator_statement)
        statement_array = deploy_cursor.fetchall()
        for grant_statement in statement_array:
            print(grant_statement[0])
            deploy_cursor.execute(grant_statement[0])

        self._db_connection.commit()


def demonstration_and_test_of_datamodeldeploymentmanager():
    from lib.config_pg_data_warehouse import pg_data_warehouse_get_connection, DwhConnectionType
    my_connection = pg_data_warehouse_get_connection(DwhConnectionType.owner)
    my_deployment_manager = DataModelDeploymentManager(my_connection)

    # my_deployment_manager.deploy_table("rvlt_sellout_weekly", "RSOWK_FEELUNIQUE_STANDARD_EXTRANET_IMPORT_P1_L10_MSAT")
    # my_deployment_manager.deploy_view("mart_business_sales_order_sellout",
    #                                   "sellout_monthly_product_report",
    #                                   force_deploy=True)
    # my_deployment_manager.deploy_table("bvlt_business_sales_order_sellout", "BBSSO_SELLOUT_MONTHLY_B10_DLNK")
    # my_deployment_manager.deploy_table("bvlt_business_sales_order_sellout", "BBSSO_SELLOUT_MONTHLY_P1_B10_SAT")
    # my_deployment_manager.deploy_table("rvlt_general", "RGNRL_GLOBAL_PRODUCT_HUB")
    # my_deployment_manager.deploy_view("mart_business_sales_order_sellout", "sellout_monthly_product_report",
    #                                   force_deploy=True)

    # my_deployment_manager.deploy_stage_table("RVLT_FACEBOOK_PANDATA", "SRFBPD_ADSET")
    my_deployment_manager.deploy_stage_table("template", "TMPL_TEMPLATE_P1")
    my_deployment_manager.deploy_table("template", "TMPL_TEMPLATE_P1_SAT")
    my_deployment_manager.deploy_view("monitoring", "RAW_META_JOB_INSTANCE")


#    my_deployment_manager.deploy_function('public','dwh_remove_whitespace')


if __name__ == '__main__':
    print('Standalone')
    demonstration_and_test_of_datamodeldeploymentmanager()
