import argparse
import json

def parse_json_file(file_path):
    try:
        with open(file_path, 'r') as file:
            data = json.load(file)
            return data["fields"]
    except FileNotFoundError:
        return f"File not found: {file_path}"
    except json.JSONDecodeError as e:
        return f"Error parsing JSON: {str(e)}"

def create_documentation(fields):
    html = "<!DOCTYPE html>\n<html>\n<body>\n"
    html += "   <table>\n"
    html += "       <tr>\n"
    html += "           <th>field name</th>\n"
    html += "           <th>field type</th>\n"
    html += "           <th>data vault target(s)</th>\n"
    html += "       </tr>\n"
    for field in fields:
        print(field)
        field_name = field["field_name"]
        field_type = field["field_type"]
        targets = field["targets"]

        html += "       <tr>\n"
        html += f"           <td>{field_name}</td>\n"
        html += f"           <td>{field_type}</td>\n"
        html += f"           <td>{targets}</td>\n"
        html += "       </tr>\n"

    html += "   </table>\n"
    html += "</body>\n</html>"
    return html



def main():
    parser = argparse.ArgumentParser(description="Parse a JSON file")
    parser.add_argument("file_path", help="Path to the JSON file to parse")
    args = parser.parse_args()

    fields = parse_json_file(args.file_path)
    if isinstance(fields, (dict, list)):
        print("Parsed JSON data:")
        html = create_documentation(fields)
        with open("processes/render_documentation/output.html", "w") as file:
            file.write(html)
    else:
        print(fields)

if __name__ == "__main__":
    main()