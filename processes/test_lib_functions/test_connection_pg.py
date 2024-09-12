from lib.connection_pg import pg_getConnection_via_inifile

conn = pg_getConnection_via_inifile("connection_pg_dev.ini","willibald_source")
