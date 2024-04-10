DVPDC Reference Implementation Installation And Users Guide
===========================================================

## Licence and Credits

(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)

# Introduction
The reference implementation serves two major goals:

- Test and prove the concept of the DVPD
- Provide reference about the transformation ruleset for other implementations
- Provide examples for model and mapping variation
- Provide examples / templates for code and documentation generators

It is implemented completly in python

# Architecture and content of the reference implementation
tbd

# Installation Guide
## Requirements
- python 3.10 or higher must be available
- please install missing pyhton packages on demand (via python pip or equivalent package manager)
Optionally
- A text editor, capable of JSON syntax highlitging and hierarchie folding
- A ide, capable of rendering Markdown documentation
- "Draw.io" for opitmal view of diagrams

## Decisions about File locations
You need to decide, where to place the following artifacts
- the DVDP project, that includes the compiler
- configuration file(=ini file) for the compiler
- your DVPD files (probably inside of a git repository of your project)
- your "model profile" configuration files (probably inside of a git repository of your project)
- compiler results files (Reports, dvpi files)
- results from generators (e.g. the generated DDL files should also go into the git reposotory of your project)

Example structure
```
\dvpd_compiler             <- the compiler project
\dwh_resources             <- the git repository of the dwh project
     \dvdc_config          <- dvpdc ini file
     \dvpd_model_profiles  <- dvpd model profiles
     \dvpd                 <- dvpd files
     \dvpi                 <- dvpi files
     \model_ddl            <- genrated DDL files
\var\dvpdc_report          <- log output of dvpdc
```

## Download and setup the compiler
- Download or clone the DVPD repository in the directory for the DVPD project
- copy the file "dvpdc.ini" from the "config_template" directory of the project to you desired location for configuration files
- adapt all properties of the \[dvpdc] section in the "dvpdc.ini" file entries to point to the desired directions
- adapt all properties "ddl_root_directory" and "dvpi_default_directory" of the \[rendering] section in the "dvpdc.ini" file entries to point to the desired directions
- copy the file default.model_profile.json from "testset_and_examples\model_profiles" to your desired location for model profiles
- adapt the model profile to your project needs (see [Reference_of_model_profile_syntax.md](Reference_of_model_profile_syntax.md))
- add the directory "/processes/dvpdc" from the compiler project to your path environment variable
- add the directory "/processes/render_ddl" from the compiler project to your path environment variable
- open a command line and run "dvpdc -h" in any directory. This should show the help text of the compiler

### Test the compiler
- place a dvpd file in the directory for the dvpd files
- open a command line
- run "dvdpc <name of the dvpd file> --ini_file="<path to the ini file>"
- This should write out its messages and success state to the console and a log file in the log output directory
- if the compile is successfull you should have a dvpi file in the directory for dvpi

### Test the ddl generator
- run "dvdp_ddl_render <name of the dvpi file> --ini_file="<path to the ini file>"
- all ddl scripts for the pipeline in the dvpi file should be written to subdirectoreis of th configured "ddl_root_directory"

# Usage Guide
## dvpd compiler (dvpdc)
The dvpdc compiler is started on the command line with

```dvdpc <name of the dvpd file> options```

Options:
- --ini_file=<path of ini file>:Defines the ini file to use (default is dvpdc.ini in the local directory)
- --model_profile_directory=<directory>: Sets the location of the model profile directory (instead of the location configured by the ini file)
- --dvpi_directory=<directory>: Sets the location for the output of the dvpi file (instead of the location configured by the ini file)
- --report_directory=<directory>: Sets the location for the log and report file (instead of the location configured by the ini file)
- --verbose: prints some internal progress messages to the console 
- --print_brain: prints the internal "memory" of the compiler

## result
The compiler creates a log file and, when compilation is successfull 2 result files
- report directory
    - log file: Contains the same messages, that have been written to the console
    - dvpisum.txt: Contains a summarized version of the dvpi data for fast overview about all essentials, created by the compiler
- dvpi directory:
    - dvpi file: Contains the dvpi json file, that has been generated from the dvpd. This can be used as a base for all further generators (see [Reference_and_usage_of_dvpi_syntax.md](Reference_and_usage_of_dvpi_syntax.md))
    
## ddl_generator
The ddl generator creates all create statement ddl for a given dvpi file. Since this is an example and not
core part of the dvpd concept, syntax and structure are also only example (mainly taken from a current project).
To adapte this to your needs, you should copy and adapt the script.

The ddl generator is started on the command line with

```dvdp_ddl_render <name of the dvpi file> options```

Options:
- --ini_file=<path of ini file>:Defines the ini file to use (default is dvpdc.ini in the local directory)
