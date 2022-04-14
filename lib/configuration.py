from configparser import ConfigParser
from pathlib import Path,PurePath
import os
import sys
import datetime
from enum import Enum


def error_print(*args, **kwargs):
    """Print a message to stderr"""
    print(*args, file=sys.stderr, **kwargs)


def configuration_load_ini(filename=None, section=None):
    """Reads the section in the ini file, that has to be located in the
        config directory and returns a dictionary with all found key values"""

    # read config file
    file_path = Path(os.path.dirname(os.path.realpath(__file__))+'/../config').joinpath(filename)
    if not os.path.exists(file_path):
        raise Exception(f'could not find configuration file: {file_path}')
    parser = ConfigParser()
    parser.read(file_path)

    # get section, default to postgresql
    key_value_list = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            key_value_list[param[0]] = param[1]
            # print(param[0], param[1])
    else:
        raise Exception('Section {0} not found in the {1} file'.format(section, filename))

    return key_value_list


if __name__ == '__main__':
    print('small test of', __name__)
    my_list = configuration_load_ini('pg_connection.ini', 'postgresql')
    for key in my_list:
        print(key, '->', my_list[key])

    print("***************************")

