# Crosscheck implementation details

The crosscheck process involves three main phases:

#### 1. Loading Pipeline Data
- Scans all DVPI files in the specified directory.
- Extracts tables, columns, and their associated properties from the focussed DVPI file (this can be all if declared as argument).
- From all other dvpi files, extract columns, and their associated properties for tables of the focussed DVPI file
- This might lead to an exception, when multiple dvpi files contain the same pipeline

#### 2. Conflict Analysis
- Compares properties across pipelines.
- Identifies conflicts in column properties, table structures, and schema definitions.
- Highlights columns missing in certain pipelines in hash definitions.

#### 3. Conflict Reporting
- Generates detailed reports summarizing inconsistencies.
- Provides insights into conflicts such as column presence, data types, and schema mismatches.

## Summary
The crosscheck  provides as well additional insights into the scope and complexity of the analysis:
- **DVPI analyzed** - Number of DVPI that are involved, either since we scan everything or they share tables with the focussed dvpi
- Tables analyzed: - Number of tables loaded for the crosscheck
- Tables created by multiple DVPI: - Number of tables that are addressed by multiple DVPI
- Tables with conflicts: - Number of tables, with a conflict
- Number of conflicts: - Totel Number of conflicts found 

