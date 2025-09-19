@echo off
REM ========================================
REM Universal JMeter Run Script for Windows
REM Works on any Jenkins Windows node
REM ========================================

REM ------------------------------
REM Use environment variables from Jenkins if available
REM ------------------------------
if "%JMETER_HOME%"=="" set JMETER_HOME=C:\apache-jmeter-5.6.3
if "%TEST_PLAN%"=="" set TEST_PLAN=%WORKSPACE%\HRMS_MB.jmx
if "%RESULTS_DIR%"=="" set RESULTS_DIR=%WORKSPACE%\results
if "%REPORTS_DIR%"=="" set REPORTS_DIR=%WORKSPACE%\reports
if "%BUILD_NUMBER%"=="" set BUILD_NUMBER=local

set REPORT_FOLDER=%REPORTS_DIR%\jmeter-report-%BUILD_NUMBER%

REM ------------------------------
REM Ensure results and reports directories exist
REM ------------------------------
if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"
if not exist "%REPORTS_DIR%" mkdir "%REPORTS_DIR%"

REM ------------------------------
REM Generate timestamp (YYYYMMDD_HHMMSS)
REM ------------------------------
for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set ldt=%%I
set TS=%ldt:~0,8%_%ldt:~8,6%
set RESULT_FILE=%RESULTS_DIR%\results-%TS%.csv

REM ------------------------------
REM Step 1: Run JMeter test plan (CSV results)
REM ------------------------------
echo Running JMeter test plan: %TEST_PLAN%
"%JMETER_HOME%\bin\jmeter.bat" -n -t "%TEST_PLAN%" -l "%RESULT_FILE%"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: JMeter test failed!
    exit /b %ERRORLEVEL%
)

REM ------------------------------
REM Step 2: Generate HTML dashboard
REM ------------------------------
echo Generating HTML report from %RESULT_FILE%
if exist "%REPORT_FOLDER%" rmdir /s /q "%REPORT_FOLDER%"
"%JMETER_HOME%\bin\jmeter.bat" -g "%RESULT_FILE%" -o "%REPORT_FOLDER%"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: HTML report generation failed!
    exit /b %ERRORLEVEL%
)

REM ------------------------------
REM Step 3: Update "latest" folder
REM ------------------------------
if exist "%REPORTS_DIR%\latest" rmdir /s /q "%REPORTS_DIR%\latest"
xcopy /e /i /y "%REPORT_FOLDER%" "%REPORTS_DIR%\latest"

echo ✅ Test completed successfully!
echo HTML report is here: %REPORTS_DIR%\latest\index.html
