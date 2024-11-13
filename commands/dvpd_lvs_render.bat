@echo off
set PYTHONPATH=%~dp0\..
python "%~dp0/../processes/render_load_vault_snippet/__main__.py" %*