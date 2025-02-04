@echo off
set SCRIPTNAME=%~n0
echo ================ %SCRIPTNAME% for %1  ================

if %1x==x goto usage

if %DVPDC_BASE%x==x goto step01
goto step02

:step01
rem If there is no environment setting for dvpdc_base we assume it is the parent directory of this script
set DVPDC_BASE=%~dp0/..

:step02
rem room for more environment checking

:step10
rem Assemble file names, depending if parameter is @youngest or not
set DVPD_FILE=%1
set DVPI_FILE=%1

if %DVPD_FILE%==@youngest goto step20
set DVPD_FILE=%1.dvpd.json
set DVPI_FILE=%1.dvpi.json


:step20
rem Compile
python "%DVPDC_BASE%/processes/dvpdc/__main__.py" %DVPD_FILE%

if errorlevel 1 goto abort

:step30
rem crosscheck
set DVPD_CROSSCHECK_WARNING=0
python "%DVPDC_BASE%/processes/dvpi_crosscheck/main.py" %DVPI_FILE%

if errorlevel 8 goto abort
if errorlevel 5 goto step30_1
if errorlevel 1 goto end
goto step40

:step30_1
set DVPD_CROSSCHECK_WARNING=1

:step40
rem render all results we want
python "%DVPDC_BASE%/processes/render_documentation/__main__.py" %DVPD_FILE%

python "%DVPDC_BASE%/processes/render_ddl/main.py"  %DVPI_FILE%
rem python "%DVPDC_BASE%/processes/render_ddl/main.py"  %DVPI_FILE% --add_ghost_records --ddl_file_naming_pattern lUl --no_primary_keys --stage_column_naming_rule combined

python "%DVPDC_BASE%/processes/render_dev_sheet/main.py"  %DVPI_FILE%
rem python "%DVPDC_BASE%/processes/render_dev_sheet/main.py"  %DVPI_FILE% --stage_column_naming_rule combined

python "%DVPDC_BASE%/processes/generate_dbt_models/__main__.py"  %DVPI_FILE% --use-all-dvpis

:step90
if %DVPD_CROSSCHECK_WARNING%==0 GOTO step90_2
echo ---! There have been similarity warnings from the crosscheck !---

:step90_2
echo ---------------- %SCRIPTNAME% for %1 complete ----------------

goto end

:usage
echo no parameter given
echo usage: %SCRIPTNAME% {name of dvpd without .dvpd.json py}

:abort
echo **************** %SCRIPTNAME% aborted ****************

:end