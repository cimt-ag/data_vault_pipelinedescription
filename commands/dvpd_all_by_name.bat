@echo off
python "%~dp0/../processes/dvpdc/__main__.py" %1.dvpd.json 

if errorlevel 1 goto end

python "%~dp0/../processes/render_ddl/main.py" %1.dvpi.json 
python "%~dp0/../processes/render_documentation/__main__.py" %1.dvpd.json 
python "%~dp0/../processes/render_operations_list/__main__.py" %1.dvpi.json 
python "%~dp0/../processes/render_dev_sheet/main.py" %1.dvpi.json


:end