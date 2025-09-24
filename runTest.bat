@echo off
REM ===============================
REM Jenkins-ready JMeter Run Script (Improved Debug)
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
REM Clean previous results for this build
REM ------------------------------
if exist "%RESULT_FILE%" del "%RESULT_FILE%"

REM ------------------------------
REM Ensure fresh report folder
REM ------------------------------
if exist "%REPORT_FOLDER%" rmdir /s /q "%REPORT_FOLDER%"
mkdir "%REPORT_FOLDER%"

REM ------------------------------
REM Run JMeter CLI with HTML report
REM ------------------------------
echo ======================================
echo Running JMeter test plan: %TEST_PLAN%
echo Results file: %RESULT_FILE%
echo Report folder: %REPORT_FOLDER%
echo ======================================

"%JMETER_HOME%\bin\jmeter.bat" -n -t "%TEST_PLAN%" -l "%RESULT_FILE%" -e -o "%REPORT_FOLDER%" -q "%JMETER_HOME%\bin\user.properties"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: JMeter test failed!
    exit /b %ERRORLEVEL%
)

REM ------------------------------
REM Debug: show result file contents
REM ------------------------------
echo.
echo ===== Checking results CSV =====
if exist "%RESULT_FILE%" (
    echo RESULT_FILE is: %RESULT_FILE%
    dir "%RESULT_FILE%"
    echo First 20 lines of results:
    type "%RESULT_FILE%" | more
) else (
    echo ERROR: Results file not created!
)

REM ------------------------------
REM Debug: show report folder contents
REM ------------------------------
echo.
echo ===== Checking HTML report =====
if exist "%REPORT_FOLDER%\index.html" (
    echo HTML report generated successfully in %REPORT_FOLDER%
    dir "%REPORT_FOLDER%"
) else (
    echo ERROR: No index.html found in %REPORT_FOLDER%
)

REM ------------------------------
REM Refresh "latest" folder for Jenkins HTML publisher
REM ------------------------------
echo.
echo Creating/updating latest report folder...
if exist "%REPORTS_DIR%\latest" rmdir /s /q "%REPORTS_DIR%\latest"
xcopy /e /i /y "%REPORT_FOLDER%" "%REPORTS_DIR%\latest"

echo.
echo ======================================
echo Test completed successfully!
echo JMeter CSV: %RESULT_FILE%
echo HTML report: %REPORTS_DIR%\latest\index.html
echo ======================================
