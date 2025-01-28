@echo off
echo ==================== build all essentials for %1  =========================

python "%~dp0/../processes/dvpdc/__main__.py" %1.dvpd.json 

if errorlevel 1 goto abort

python "%~dp0/../processes/dvpi_crosscheck/main.py" @youngest

if errorlevel 8 goto abort
if errorlevel 1 goto end

python "%~dp0/../processes/render_ddl/main.py" %1.dvpi.json 
python "%~dp0/../processes/render_documentation/__main__.py" %1.dvpd.json 
python "%~dp0/../processes/render_operations_list/__main__.py" %1.dvpi.json 
python "%~dp0/../processes/render_dev_sheet/main.py" %1.dvpi.json
python "%~dp0/../processes/render_load_vault_snippet/__main__.py" %1.dvpi.json

echo ---------------- build all essentials for %1 complete  -----------------

goto end

:abort

echo **************** build all essentials for %1 aborted *******************


:end