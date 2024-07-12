 # DVPDC Code Structure
 
## dvpdc:

### Purpose
This is a function that initializes the log file and calls the worker function to do the compilation.

### Parameters
- dvpd_filename
- dvpi_directory
- dvpdc_report_directory
- ini_file
- model_profile_directory
- verbose_logging

### Steps
1. Load configuration parameters from the ini file.
2. Create the report directory if it doesn't exist.
3. Initialize the log file and write log entries.
4. Call the dvpdc_worker function to do the compilation.

## dvpdc_worker:

### Purpose
This function performs the main compilation tasks.

### Parameters
- dvpd_filename
- dvpi_directory
- dvpdc_report_directory
- ini_file
- model_profile_directory
- verbose_logging

### Steps
1. Initialize global dictionaries and variables.
2. Load the DVPD file and handle JSON parsing errors.
3. Load model profiles.
4. Create the DVPI document from the DVPD.

## assemble_dvpi:

### Purpose
This function assembles the DVPI document from the DVPD object.

### Parameters
- dvpd_object
- dvpd_filename

### Steps
1. Initialize the DVPI document with meta information.  
2. Add tables to the DVPI document.
3. Add data extraction.

## assemble_dvpi_table_entry:

### Purpose
To create an entry for each table in the DVPI document.

### Parameters
- table_name
- table_entry

### Steps
1. Copy table properties to the DVPI table entry.  
2. Add meta columns and hash columns to the DVPI table entry.
3. Check for double column names.

## assemble_dvpi_parse_set

### Purpose
To add rules for parsing data to the DVPI document.

### Parameters
- parse_sets
- dvpi_document

### Steps
1. Create a section for parse sets in the DVPI document. 
2. Loop through each parse set in the DVPD.

## assemble_dvpi_hash_mappings

### Purpose
To create hash mappings in the DVPI document using hash keys.

### Parameters
- hash_mappings
- dvpi_document

### Steps
1. Create a section for hash mappings in the DVPI document. 
2. Loop through each hash mapping definition in the DVPD.

## assemble_dvpi_data_mappings

### Purpose
To map data fields in the DVPI document.

### Parameters
- data_mappings
- dvpi_document

### Steps
1. Create a section for data mappings in the DVPI document. 
2. Loop through each data mapping definition in the DVPD.

## assemble_dvpi_stage_columns

### Purpose
To define columns for keeping data in the DVPI document.

### Parameters
- dvpi_stage_columns
- dvpi_document

### Steps
1. Create a section for staging columns in the DVPI document.
2. Loop through each staging column definition in the DVPD.
3. Check for double stage column names.

## writeDvpiSummary

### Purpose
To write a summary of the DVPI to a file.

### Parameters
- dvpdc_report_path
- dvpd_file_path

### Steps
1. Write headers to the summary files. 
2. Write the content of the DVPI to the summary file. 
3. Handle any errors during writing.

## get_name_of_youngest_dvpd_file

### Purpose
To find the most recently modified DVPD file.

### Parameters
- ini_file

### Steps
1. Load the directory path from the configuration.
2. Iterate over files in the directory and find the one with the latest modification time.

## print_the_brain

### Purpose
To give a summary of data structures.

### Steps
1. Create a summary structure. 
2. Add keys and values from global dictionaries. 
3. Print the summary.























