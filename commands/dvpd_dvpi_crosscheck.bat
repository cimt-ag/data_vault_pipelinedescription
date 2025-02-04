@echo off
python "%~dp0/../processes/dvpi_crosscheck/main.py" %*

if %errorlevel% equ 8 (
    echo Exit Code 8
    exit /b 8
) else (
    exit /b 0
)