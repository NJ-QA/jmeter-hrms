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

REM ------------------------------
REM Run JMeter test plan
REM ------------------------------
echo Running JMeter test plan: %TEST_PLAN%
"%JMETER_HOME%\bin\jmeter.bat" -n -t "%TEST_PLAN%" -l "%RESULTS_DIR%\results-%TS%.csv" -e -o "%REPORTS_DIR%\latest"

REM Check if JMeter run succeeded
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: JMeter test failed!
    exit /b %ERRORLEVEL%
)
echo Test completed successfully!
echo HTML report is here:
echo %REPORTS_DIR%\latest\index.html
