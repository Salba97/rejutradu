@echo off
setlocal

timeout /t 3 >nul 2>&1

echo Finishing engine update.

if "%~1"=="" goto no_args
if "%~2"=="" goto no_args
if "%~3"=="" goto no_args
if "%~4"=="" goto no_args
if "%~5"=="" goto no_args

set "sourceDir=%~1"
set "destDir=%~2"
set "bootstrap=%~3"
set "constant=%~4"
set "value=%~5"

if not exist "%sourceDir%" (
    echo Error: Source directory "%sourceDir%" does not exist.
    exit /b 1
)

if not exist "%destDir%" (
    echo Destination directory "%destDir%" does not exist.
    exit /b 1
)

echo Moving contents from "%sourceDir%" to "%destDir%"
robocopy "%sourceDir%" "%destDir%" /E /MOVE /R:1 /W:1 /NFL /NDL /NJH /NJS

echo Deleting "%sourceDir%"
rmdir /S /Q "%sourceDir%"

echo Changing "%constant%" to "%value%" in "%bootstrap%"
cscript //nologo "%~dp0replace.js" "%bootstrap%" "%constant%" "%value%"

echo Done.
exit /b 0

:no_args
echo Missing arguments
exit /b 1
