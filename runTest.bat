@echo off
REM ========================================
REM Universal JMeter Run Script for Windows
REM ========================================

if "%JMETER_HOME%"=="" set JMETER_HOME=C:\apache-jmeter-5.6.3
if "%TEST_PLAN%"=="" set TEST_PLAN=%WORKSPACE%\HRMS_MB.jmx
if "%RESULTS_DIR%"=="" set RESULTS_DIR=%WORKSPACE%\results
if "%REPORTS_DIR%"=="" set REPORTS_DIR=%WORKSPACE%\reports
if "%BUILD_NUMBER%"=="" set BUILD_NUMBER=local

set REPORT_FOLDER=%REPORTS_DIR%\jmeter-report-%BUILD_NUMBER%

if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"
if not exist "%REPORTS_DIR%" mkdir "%REPORTS_DIR%"

for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set ldt=%%I
set TS=%ldt:~0,8%_%ldt:~8,6%
set RESULT_FILE=%RESULTS_DIR%\results-%TS%.csv

echo Running JMeter test plan: %TEST_PLAN%
"%JMETER_HOME%\bin\jmeter.bat" -n -t "%TEST_PLAN%" -l "%RESULT_FILE%"
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

echo Generating HTML report from %RESULT_FILE%
if exist "%REPORT_FOLDER%" rmdir /s /q "%REPORT_FOLDER%"
"%JMETER_HOME%\bin\jmeter.bat" -g "%RESULT_FILE%" -o "%REPORT_FOLDER%"
 
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: JMeter test failed!
    exit /b %ERRORLEVEL%
)

REM Maintain "latest" copy
if exist "%REPORTS_DIR%\latest" rmdir /s /q "%REPORTS_DIR%\latest"
xcopy /e /i /y "%REPORT_FOLDER%" "%REPORTS_DIR%\latest"

echo Test completed successfully!
echo HTML report is here:
echo %REPORT_FOLDER%\index.html
