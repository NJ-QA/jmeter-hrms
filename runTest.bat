@echo off
REM ==========================
REM Minimal JMeter Batch Script
REM ==========================

REM ---- CONFIG ----
set JMETER_HOME=C:\apache-jmeter-5.6.3
set TEST_PLAN=HRMS_MB.jmx
set RESULT_FILE=results.csv
set REPORT_FOLDER=reports\report
set LATEST_FOLDER=reports\latest

REM ---- CLEAN OLD FILES ----
if exist "%RESULT_FILE%" del "%RESULT_FILE%"
if exist "%REPORT_FOLDER%" rmdir /s /q "%REPORT_FOLDER%"
if exist "%LATEST_FOLDER%" rmdir /s /q "%LATEST_FOLDER%"

REM ---- RUN TEST ----
echo Running JMeter test plan...
"%JMETER_HOME%\bin\jmeter.bat" -n -t "%TEST_PLAN%" -l "%RESULT_FILE%"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: JMeter test failed!
    exit /b %ERRORLEVEL%
)

REM ---- GENERATE HTML REPORT ----
echo Generating HTML dashboard...
"%JMETER_HOME%\bin\jmeter.bat" -g "%RESULT_FILE%" -o "%REPORT_FOLDER%"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Report generation failed!
    exit /b %ERRORLEVEL%
)

REM ---- COPY TO LATEST ----
xcopy /e /i /y "%REPORT_FOLDER%" "%LATEST_FOLDER%"

echo ✅ Done! HTML report at %LATEST_FOLDER%\index.html
exit /b 0
