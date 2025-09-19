@echo off
REM ===============================
REM Local JMeter Run Script
REM ===============================

set JMETER_HOME=C:\apache-jmeter-5.6.3
set TEST_PLAN=%~dp0HRMS_MB.jmx
set RESULTS_DIR=%~dp0results
set REPORTS_DIR=%~dp0reports

echo Cleaning old results...
if exist "%RESULTS_DIR%" rmdir /s /q "%RESULTS_DIR%"
if exist "%REPORTS_DIR%" rmdir /s /q "%REPORTS_DIR%"
mkdir "%RESULTS_DIR%"
mkdir "%REPORTS_DIR%"

echo Running JMeter test plan: %TEST_PLAN%
"%JMETER_HOME%\bin\jmeter.bat" -n -t "%TEST_PLAN%" -l "%RESULTS_DIR%\results.csv" -e -o "%REPORTS_DIR%\latest"

echo.
echo Done! Open report: %REPORTS_DIR%\latest\index.html
pause