# Module to connect to an external resource
#
# Resource: Postgresql database containing the major data warehouse tables and the metadata
import os
import sys
from enum import Enum

import psycopg2

from lib.configuration import configuration_load_ini


def error_print(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


class DwhConnectionType(Enum):
    owner = 'owner'
    metadata = 'metadata'
    raw_vault = 'raw_vault'
    business_vault = 'business_vault'
    mart_general = 'mart_general'


INI_CONF_CONNECTION_TYPE_DICT = {'owner': {'user': 'owner_user', 'password': 'owner_password'},
                                 'metadata': {'user': 'metadata_user', 'password': 'metadata_password'},
                                 'raw_vault': {'user': 'raw_vault_user', 'password': 'raw_vault_password'},
                                 'business_vault': {'user': 'business_vault_user',
                                                    'password': 'business_vault_password'},
                                 'mart_general': {'user': 'mart_general_user', 'password': 'mart_general_password'}}


def pg_data_warehouse_get_connection(connection_type: DwhConnectionType):
    """Reads configuration for the resource from environment and returns a new connection"""
    database = None
    user = None
    host = None
    port = None
    try:
        # for LOCAL postgres
        params = configuration_load_ini('pg_connection.ini', 'postgresql')
        database = params['database']
        user = params[INI_CONF_CONNECTION_TYPE_DICT[connection_type.value]['user']]
        host = params['host']
        port = params['port']
        password = params[INI_CONF_CONNECTION_TYPE_DICT[connection_type.value]['password']]
        connection = psycopg2.connect(database=database, user=user, host=host, port=port, password=password)
    except Exception as error:
        error_print('Connection Error in pg_data_warehouse_getConnection:', error)
        error_print('E_CONF_AVAILABLE = ', os.getenv('E_CONF_AVAILABLE'))
        error_print('HOST =', host)
        error_print('PORT =', port)
        error_print('USER =', user)
        error_print('DATABASE =', database)
        raise
    return connection


if __name__ == '__main__':
    # small test
    conn = pg_data_warehouse_get_connection(DwhConnectionType.raw_vault)
