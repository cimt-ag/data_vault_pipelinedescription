@echo off
echo ==================== build all essentials for youngest dvpd  =========================

python "%~dp0/../processes/dvpdc/__main__.py" @youngest %*

if errorlevel 1 goto end

python "%~dp0/../processes/dvpi_crosscheck/main.py" @youngest

if errorlevel 8 goto abort
if errorlevel 1 goto end

python "%~dp0/../processes/render_ddl/main.py" @youngest %*
python "%~dp0/../processes/render_documentation/__main__.py" @youngest %*
python "%~dp0/../processes/render_operations_list/__main__.py" @youngest %*
python "%~dp0/../processes/render_dev_sheet/main.py" @youngest %*

echo ---------------- build all essentials for youngest complete  -----------------

goto end

:abort

echo **************** build all essentials aborted *******************


:end