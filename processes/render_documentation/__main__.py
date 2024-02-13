import argparse
import json
from pathlib import Path
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



def create_documentation(pipeline_name, fields):
    html = "<!DOCTYPE html>\n<html>\n"
    html += "<head>\n"
    html += "<style>\n"
    html += "table, th, td {border: 1px solid;}\n"
    html += "table {border-collapse: collapse;}\n"
    html += "</style>\n"
    html += f"   <title>{pipeline_name}</title>\n"
    html += "</head>\n"
    html += "<body>\n"
    html += "   <table>\n"
    html += "       <tr>\n"
    html += "           <th>field name</th>\n"
    html += "           <th>field type</th>\n"
    html += "           <th>data vault target(s)</th>\n"
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



def main():
    parser = argparse.ArgumentParser(description="Create specification documentation snippet from DVDP file")
    parser.add_argument("dvpd_file_name", help="Path to the DVPD file to parse")
    args = parser.parse_args()
    dvpd_filename = args.dvpd_file_name

    params = configuration_load_ini('dvpdc.ini', 'rendering',['dvpd_default_directory','documentation_directory'])
    dvpd_file_path = Path(params['dvpd_default_directory']).joinpath(dvpd_filename)

    if not dvpd_file_path.exists():
        raise Exception(f"file not found {dvpd_file_path.as_posix()}")
    print(f"Rendering documentation from {dvpd_file_path.name}")

    (pipeline_name, fields) = parse_json_file(dvpd_file_path)
    if isinstance(fields, (dict, list)):
        html = create_documentation(pipeline_name,fields)
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

if __name__ == "__main__":
    main()
