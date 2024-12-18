@echo off
python "%~dp0/../processes/dvpdc/__main__.py" @youngest %*

if errorlevel 1 goto end

python "%~dp0/../processes/render_ddl/main.py" @youngest %*
python "%~dp0/../processes/render_documentation/__main__.py" @youngest %*
python "%~dp0/../processes/render_operations_list/__main__.py" @youngest %*
python "%~dp0/../processes/render_dev_sheet/main.py" @youngest %*
python "%~dp0/../processes/render_load_vault_snippet/__main__.py" @youngest %*

:end