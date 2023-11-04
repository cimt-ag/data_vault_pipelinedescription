#  =====================================================================
#  Part of the Cimt Data Vault Python Framework
#
#  Copyright 2023 cimt ag
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
# =====================================================================

from configparser import ConfigParser
from pathlib import Path,PurePath
import os
import sys
import datetime
from enum import Enum


def error_print(*args, **kwargs):
    """Print a message to stderr"""
    print(*args, file=sys.stderr, **kwargs)


def configuration_load_ini(filename=None, section=None, mandatory_elements=None):
    """Reads the section in the ini file, that has to be located in the
        config directory and returns a dictionary with all found key values"""
    # todo move responsibility for full path to caller

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

    if mandatory_elements != None:
        for keyword in mandatory_elements:
            if keyword not in key_value_list:
                raise Exception('Mandtatory parameter "{0}" not found in the configuration file "{1}"'.format(keyword, filename))

    return key_value_list


if __name__ == '__main__':
    print('small test of', __name__)
    my_list = configuration_load_ini('pg_connection.ini', 'postgresql')
    for key in my_list:
        print(key, '->', my_list[key])

    print("***************************")

