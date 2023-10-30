import argparse
import json

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
        in_brackets.append("not in diff hash") 
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
    parser = argparse.ArgumentParser(description="Parse a JSON file")
    parser.add_argument("file_path", help="Path to the JSON file to parse")
    args = parser.parse_args()

    (pipeline_name, fields) = parse_json_file(args.file_path)
    if isinstance(fields, (dict, list)):
        html = create_documentation(pipeline_name,fields)
        print(html)
        with open(f"processes/render_documentation/{pipeline_name}.html", "w") as file:
            file.write(html)
    else:
        print(fields)

if __name__ == "__main__":
    main()