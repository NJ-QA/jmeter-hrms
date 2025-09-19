@echo off
REM ===============================
REM Jenkins-Friendly JMeter Run Script
REM ===============================

REM Set JMeter Home and Test Plan
set JMETER_HOME=C:\apache-jmeter-5.6.3
set TEST_PLAN=%WORKSPACE%\HRMS_MB.jmx

REM Results and Reports Directories
set RESULTS_DIR=%WORKSPACE%\results
set REPORTS_DIR=%WORKSPACE%\reports

REM Generate timestamp (YYYYMMDD_HHMMSS)
for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set ldt=%%I
set TS=%ldt:~0,8%_%ldt:~8,6%

REM Clean old results/reports
if exist "%RESULTS_DIR%" rmdir /s /q "%RESULTS_DIR%"
if exist "%REPORTS_DIR%" rmdir /s /q "%REPORTS_DIR%"

REM Recreate directories
mkdir "%RESULTS_DIR%"
mkdir "%REPORTS_DIR%"

REM Run JMeter in non-GUI mode with user.properties
echo Running JMeter test plan...
"%JMETER_HOME%\bin\jmeter.bat" -p "%JMETER_HOME%\bin\user.properties" -n -t "%TEST_PLAN%" -l "%RESULTS_DIR%\results-%TS%.csv" -e -o "%REPORTS_DIR%\latest"

REM Check if JMeter run succeeded
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: JMeter test failed!
    exit /b %ERRORLEVEL%
)

echo Test completed successfully!
echo Report available at: %REPORTS_DIR%\latest\index.html
