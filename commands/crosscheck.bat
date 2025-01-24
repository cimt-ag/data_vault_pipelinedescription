@echo off

cd /d "C:\git_ordner\dvpd\processes\dvpi_crosscheck"

py main.py "C:\\git_ordner\\dvpd\\processes\\dvpi_crosscheck"

if %errorlevel% equ 8 (
    exit /b 8
) else (
    exit /b 0
)