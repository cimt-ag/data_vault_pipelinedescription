import os
import psycopg2
import sys
from lib.configuration import configuration_load_ini

def error_print(*args, **kwargs):
    """Print a message to stderr"""
    print(*args, file=sys.stderr, **kwargs)

def pg_getConnection_via_inifile(filename,section):
    """Reads configuration for the resource from environment and returns a new connection"""
    database = None
    user = None
    host = None
    port = None
    try:
        # for LOCAL postgres
        params = configuration_load_ini(filename, section,['database','user','password','host'])
        host = params['host']
        database = params['database']
        user = params['user']
        password = params['password']
        if 'port' in params:
            port = params['port']
        else:
            port=5432 # postgresql default port
        connection = psycopg2.connect(database=database, user=user, host=host, port=port, password=password)
    except Exception as error:
        error_print('Connection Error in pg_getConnection_via_inifile:', error)
        error_print('ini file used:', filename)
        error_print('ini section used:', section)
        raise
    return connection


if __name__ == '__main__':
    # small test
    conn = pg_getConnection_via_inifile("connection_pg_dev.ini","willibald_source")