import argparse
import json
import os
import sys

from pathlib import Path

project_directory = os.path.dirname(os.path.dirname(sys.path[0]))
sys.path.insert(0,project_directory)

from lib.configuration import configuration_load_ini

def parse_json_file(file_path):
    try:
        with open(file_path, 'r') as file:
            data = json.load(file)
            return (data["pipeline_name"], data["fields"])
    except FileNotFoundError:
        return f"File not found: {file_path}"
    except json.JSONDecodeError as e:
        return f"Error parsing JSON: {str(e)}"

# catch the usual suspects
def is_json_true(json):
    return json==True or json=="true" or json=="True"

def parse_target(target):
#    print(f"parse({target}):")
    result = target["table_name"]
    
    result += f".[{target['column_name']}]" if 'column_name' in target else ""

    in_brackets = []
    if 'exclude_from_key_hash' in target and is_json_true(target['exclude_from_key_hash']):
        # print(f"exclude_from_key_hash: {target['exclude_from_key_hash']}")  
        in_brackets.append("not in key hash") 
    if 'exclude_from_change_detection' in target and is_json_true(target['exclude_from_change_detection']):
        in_brackets.append("not in comparison")
    if 'relation_names' in target:
        relation_names = target["relation_names"] 
        if len(relation_names) == 1:
            in_brackets.append(f"relation: {relation_names[0]}")
        else: 
            in_brackets.append(f"relations: {relation_names}")

    if len(in_brackets) > 0:
        result += " (" + ", ".join(in_brackets) + ")"
    
#    print(f"result: {result}")
    return result



def create_documentation(pipeline_name, column_labels, fields):
    header_text=column_labels.split(',')
    if len(header_text)<3:
        print(f"Not enough header labels given in 'documentation_column_labels'. Need 3 got {len(header_text)}: >>{column_labels}<< ")
        exit()
    html = "<!DOCTYPE html>\n<html>\n"
    html += "<head>\n"
    html += "<style>\n"
    html += "table, th, td {border: 1px solid;}\n"
    html += "table {border-collapse: collapse;}\n"
    html += "body { font-family: Verdana, Geneva, Tahoma, sans-serif;}"
    html += "</style>\n"
    html += f"   <title>{pipeline_name}</title>\n"
    html += "</head>\n"
    html += "<body>\n"
    html += f"<h1>Pipeline: {pipeline_name}\n</h1>"
    html += "   <table>\n"
    html += "       <tr>\n"
    html += f"           <th>{header_text[0]}</th>\n"
    html += f"           <th>{header_text[1]}</th>\n"
    html += f"           <th>{header_text[2]}</th>\n"
    html += "       </tr>\n"
    for field in fields:
        field_name = field["field_name"]
        field_type = field["field_type"]
        targets = field["targets"]

        html += "       <tr>\n"
        html += f"           <td>{field_name}</td>\n"
        html += f"           <td>{field_type}</td>\n"
        if len(targets) == 1:
            html += f"           <td>{parse_target(targets[0])}</td>\n"
        else:
            t = []
            for target in targets:
                t.append(parse_target(target))
            html += "               <td>[" + ", ".join(t) + "]</td>\n"
        html += "       </tr>\n"

    html += "   </table>\n"
    html += "</body>\n</html>"
    return html



def main(dvpd_filename,
              ini_file,print_html):

    params = configuration_load_ini(ini_file, 'rendering',['dvpd_default_directory','documentation_directory'])
    dvpd_file_path = Path(params['dvpd_default_directory']).joinpath(dvpd_filename)
    print(params['dvpd_default_directory'])
    if not dvpd_file_path.exists():
        raise Exception(f"file not found {dvpd_file_path.as_posix()}")
    print(f"Rendering documentation from {dvpd_file_path.name}")

    column_labels='Field Type,Field Name,Data Vault Target(s)'
    if 'documentation_column_labels' in params:
        column_labels=params['documentation_column_labels']


    (pipeline_name, fields) = parse_json_file(dvpd_file_path)
    if isinstance(fields, (dict, list)):
        html = create_documentation(pipeline_name,column_labels,fields)
        if print_html:
            print(html)
        target_directory=Path(params['documentation_directory'])
        if not target_directory.exists():
            target_directory.mkdir(parents=True)
        out_file_Path = target_directory.joinpath(f'{pipeline_name}.html')
        with open(out_file_Path, "w") as file:
            file.write(html)
    else:
        print(fields)

    print (f"Completed rendering documentation from {dvpd_file_path.name}")

def get_name_of_youngest_dvpd_file(ini_file):
    params = configuration_load_ini(ini_file, 'dvpdc',['dvpd_model_profile_directory'])

    max_mtime=0
    youngest_file=''

    for file_name in os.listdir( params['dvpd_default_directory']):
        file_mtime=os.path.getmtime( params['dvpd_default_directory']+'/'+file_name)
        if file_mtime>max_mtime:
            youngest_file=file_name
            max_mtime=file_mtime

    return youngest_file

########################################################################################################################

if __name__ == "__main__":

    parser = argparse.ArgumentParser(
            description="Create specification documentation snippet from DVDP file",
            usage = "Add option -h for further instruction"
    )
    parser.add_argument("dvpd_file_name", help="Path to the DVPD file to parse. Use @youngest to parse the youngest.")
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    parser.add_argument("--print", help="Print html to console",  action='store_true')

    args = parser.parse_args()
    dvpd_filename = args.dvpd_file_name

    if dvpd_filename == '@youngest':
        dvpd_filename = get_name_of_youngest_dvpd_file(ini_file=args.ini_file)

    main(dvpd_filename=dvpd_filename,
              ini_file=args.ini_file,
                print_html=args.print)
