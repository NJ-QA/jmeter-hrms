@echo off
setlocal enabledelayedexpansion

REM ==============================
REM Environment variables
REM ==============================
set JMETER_HOME=C:\apache-jmeter-5.6.3
set TEST_PLAN=%WORKSPACE%\HRMS_MB.jmx
set RESULTS_DIR=%WORKSPACE%\results
set REPORTS_DIR=%WORKSPACE%\reports
set RESULT_FILE=%RESULTS_DIR%\results-%BUILD_NUMBER%.csv
set REPORT_FOLDER=%REPORTS_DIR%\build-%BUILD_NUMBER%

echo -------------------------------------
echo Running JMeter Test Plan...
echo WORKSPACE: %WORKSPACE%
echo RESULT_FILE: %RESULT_FILE%
echo REPORT_FOLDER: %REPORT_FOLDER%
echo -------------------------------------

REM ==============================
REM Prepare folders
REM ==============================
if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"
if not exist "%REPORTS_DIR%" mkdir "%REPORTS_DIR%"

REM Clean previous build folder
if exist "%REPORT_FOLDER%" rmdir /s /q "%REPORT_FOLDER%"
if exist "%RESULT_FILE%" del "%RESULT_FILE%"

REM ==============================
REM Run JMeter
REM ==============================
"%JMETER_HOME%\bin\jmeter.bat" ^
    -n -t "%TEST_PLAN%" ^
    -l "%RESULT_FILE%" ^
    -e -o "%REPORT_FOLDER%"

if errorlevel 1 (
    echo JMeter execution failed!
    exit /b 1
)

REM ==============================
REM Verify report generation
REM ==============================
echo JMeter CSV: %RESULT_FILE%
echo JMeter HTML Report: %REPORT_FOLDER%\index.html
dir "%REPORT_FOLDER%"

REM ==============================
REM Refresh "latest" for Jenkins publisher
REM ==============================
if exist "%REPORTS_DIR%\latest" rmdir /s /q "%REPORTS_DIR%\latest"
xcopy /e /i /y "%REPORT_FOLDER%" "%REPORTS_DIR%\latest"

echo -------------------------------------
echo Test completed successfully!
echo HTML report: %REPORTS_DIR%\latest\index.html
echo -------------------------------------

endlocal
