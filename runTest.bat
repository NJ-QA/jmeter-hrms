@echo off
REM ===============================
REM Jenkins-ready JMeter Run Script (Fresh CSV & HTML report)
REM ===============================

REM ------------------------------
REM Environment variables (override from Jenkins if needed)
REM ------------------------------
if "%JMETER_HOME%"=="" set JMETER_HOME=C:\apache-jmeter-5.6.3
if "%TEST_PLAN%"=="" set TEST_PLAN=%WORKSPACE%\HRMS_MB.jmx
if "%RESULTS_DIR%"=="" set RESULTS_DIR=%WORKSPACE%\results
if "%REPORTS_DIR%"=="" set REPORTS_DIR=%WORKSPACE%\reports
if "%BUILD_NUMBER%"=="" set BUILD_NUMBER=local

set REPORT_FOLDER=%REPORTS_DIR%\build-%BUILD_NUMBER%
set RESULT_FILE=%RESULTS_DIR%\results-%BUILD_NUMBER%.csv

REM ------------------------------
REM Ensure results and reports directories exist
REM ------------------------------
if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"
if not exist "%REPORTS_DIR%" mkdir "%REPORTS_DIR%"


REM ------------------------------
REM Clean previous report folder for this build
REM ------------------------------
if exist "%REPORT_FOLDER%" rmdir /s /q "%REPORT_FOLDER%"
if exist "%RESULT_FILE%" del "%RESULT_FILE%"

REM ------------------------------
REM Find the latest CSV (if any) and use it
REM ------------------------------
set "LATEST_CSV="
for /f "delims=" %%i in ('dir /b /a-d /o-d "%RESULTS_DIR%\*.csv" 2^>nul') do (
    set "latestCsv=%%i"
    goto :found_csv
)
:found
if defined latestCsv (
    set RESULT_FILE=%RESULTS_DIR%\%latestCsv%
    echo Latest CSV file: %RESULT_FILE%
) else (
    echo No CSV file found in %RESULTS_DIR%
    set RESULT_FILE=%RESULTS_DIR%\results-%BUILD_NUMBER%.csv
)

REM ------------------------------
REM Run JMeter CLI with HTML report
REM ------------------------------
echo Running JMeter test plan: %TEST_PLAN%
"%JMETER_HOME%\bin\jmeter.bat" -n -t "%TEST_PLAN%" ^
    -l "%RESULT_FILE%" ^
    -e -o "%REPORT_FOLDER%" ^
    -q "%JMETER_HOME%\bin\user.properties" ^
    -JCLEAR_CSV_CACHE=true

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: JMeter test failed!
    exit /b %ERRORLEVEL%
)

REM ------------------------------
REM Verify report generation
REM ------------------------------
echo ✅ Verify JMeter report generation
echo JMeter CSV: %RESULT_FILE%
echo JMeter HTML Report: %REPORT_FOLDER%\index.html
dir "%REPORT_FOLDER%"
if not exist "%REPORT_FOLDER%\index.html" (
    echo ERROR: HTML report was not generated!
    exit /b 1
)


REM ------------------------------
REM Refresh "latest" folder for Jenkins HTML publisher
REM ------------------------------
if exist "%REPORTS_DIR%\latest" rmdir /s /q "%REPORTS_DIR%\latest"
xcopy /e /i /y "%REPORT_FOLDER%" "%REPORTS_DIR%\latest"

echo.
echo ==============================
echo ✅ Test completed successfully!
echo HTML report is here: %REPORTS_DIR%\latest\index.html
