from processes.dvpdc.__main__ import dvpdc
from processes.dvpdc.__main__ import get_name_of_youngest_dvpd_file
from processes.dvpdc.__main__ import print_the_brain
from processes.dvpdc.__main__ import DvpdcError

from processes.render_ddl.main import parse_json_to_ddl
from processes.render_ddl.main import get_name_of_youngest_dvpi_file

from processes.render_documentation.__main__ import main as render_documentation

from processes.render_dev_sheet.main import render_dev_cheat_sheet

from processes.render_operations_list.__main__ import process_file as render_op_list

from lib.configuration import configuration_load_ini

import argparse
from pathlib import Path

########################   MAIN ################################
if __name__ == '__main__':
    description_for_terminal = "Process dvpi at the given location to render the ddl statements."
    usage_for_terminal = "Add option -h for further instruction"

    parser = argparse.ArgumentParser(
        description=description_for_terminal,
        usage= usage_for_terminal
    )
    # input Arguments
    parser.add_argument("dvpd_filename", help="Name of the dvpd file to compile. Set this to '@youngest' to compile the youngest file in your dvpd directory")
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    parser.add_argument("--model_profile_directory",help="Name of the model profile directory")
    parser.add_argument("--print", help="print the generated ddl to the console",  action='store_true')
    parser.add_argument("--add_ghost_records", help="Add ghost record inserts to every script",  action='store_true')
    parser.add_argument("--no_primary_keys", help="omit rendering of primary key constraints ",  action='store_true')
    parser.add_argument("--stage_column_naming_rule", help="Rule to use for stage column naming [stage,combined]", default='#notset#')

    # output arguments
    parser.add_argument("--dvpi_directory",  help="Name of the dvpi file to write (defaults to filename +  dvpi.json)")
    parser.add_argument("--report_directory", help="Name of the report file (defaults to filename + .dvpdc.log")
    parser.add_argument("--print_brain", help="When set, the compiler will print its internal data structure to stdout", action='store_true')
    parser.add_argument("--verbose", help="Log more information about progress", action='store_true')

    args = parser.parse_args()
    dvpd_filename = args.dvpd_filename

    # DVPDC
    if dvpd_filename == '@youngest':
        dvpd_filename = get_name_of_youngest_dvpd_file(ini_file=args.ini_file)

    try:
        dvpdc(dvpd_filename=dvpd_filename,
              dvpi_directory=args.dvpi_directory,
              dvpdc_report_directory=args.report_directory,
              ini_file=args.ini_file,
              model_profile_directory=args.model_profile_directory,
              verbose_logging=args.verbose
              )
        if args.print_brain:
            print_the_brain()
    except DvpdcError:
        if args.print_brain:
            print_the_brain()
        print("*** stopped compilation due to errors in input ***")
        exit(5)

    except Exception :
        if args.print_brain:
            print_the_brain()
        raise

    # RENDER DDLs
    params = configuration_load_ini(args.ini_file, 'rendering', ['ddl_root_directory', 'dvpi_default_directory'])

    if args.stage_column_naming_rule =='#notset#':
        stage_column_naming_rule=params.get('stage_column_naming_rule','stage')
    else:
        stage_column_naming_rule=args.stage_column_naming_rule

    if args.no_primary_keys == False:
        no_primary_keys=params.get('no_primary_keys',False) == ('True' or 'true')
    else:
        no_primary_keys=args.no_primary_keys

    ddl_render_path = Path(params['ddl_root_directory'], fallback=None)
    dvpi_default_directory = Path(params['dvpi_default_directory'], fallback=None)
    
    dvpi_file_name=dvpd_filename.replace('.json','').replace('.dvpd','')+".dvpi.json"
    if dvpi_file_name == '@youngest':
        dvpi_file_name = get_name_of_youngest_dvpi_file(params['dvpi_default_directory'])
        print(f"Rendering from file {dvpi_file_name}")

    dvpi_file_path = Path(dvpi_file_name)
    if not dvpi_file_path.exists():
       dvpi_file_path = dvpi_default_directory.joinpath(dvpi_file_name)
       if not dvpi_file_path.exists():
            print(f"could not find file {args.dvpi_file_name}")

    ddl_output = parse_json_to_ddl(dvpi_file_path, ddl_render_path
                                        , add_ghost_records=args.add_ghost_records
                                        , add_primary_keys=not no_primary_keys
                                   , stage_column_naming_rule=stage_column_naming_rule)
    if args.print:
        print(ddl_output)

    print("--- ddl render complete ---")

    # RENDER DOCUMENTATION
    render_documentation(dvpd_filename=dvpd_filename,
              ini_file=args.ini_file,
                print_html=args.print)

    print("--- documentation render complete ---")

    # RENDER OPERATIONS LIST
    params = configuration_load_ini(args.ini_file, 'rendering', ['operations_list_directory', 'dvpi_default_directory'])
    op_list_dir = Path(params['operations_list_directory'])
    dvpi_default_directory = Path(params['dvpi_default_directory'], fallback=None)

    print(f"Rendering OP LIST from file {dvpi_file_name}")

    render_op_list(dvpi_file_path,op_list_dir,args.print)

    print("--- operations list render complete ---")

    # RENDER DEV SHEET
    params = configuration_load_ini(args.ini_file, 'rendering', ['dvpi_default_directory','documentation_directory'])

    dvpi_default_directory = Path(params['dvpi_default_directory'], fallback=None)
    documentation_directory = Path(params['documentation_directory'], fallback=None)

    render_dev_cheat_sheet(dvpi_file_path, documentation_directory
                                        , stage_column_naming_rule=stage_column_naming_rule)

    print("--- dev developers sheet render complete ---")