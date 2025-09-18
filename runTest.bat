@echo off
REM ==========================================================
REM JMeter Test Runner with CSV/IMG Paths + Report Generation
REM ==========================================================

setlocal

REM 🔹 Define JMeter home (update if installed in different path)
set JMETER_HOME=C:\apache-jmeter-5.6.3
set JMETER_BIN=%JMETER_HOME%\bin

REM 🔹 Define repo workspace (Jenkins/Git checkout folder)
set WORKSPACE=%~dp0

REM 🔹 Define paths
set TEST_PLAN=%WORKSPACE%HRMS_MB.jmx
set RESULT_DIR=%WORKSPACE%results
set REPORT_DIR=%WORKSPACE%reports\latest
set CSV_DIR=%WORKSPACE%csvs
set IMG_DIR=%WORKSPACE%images

REM 🔹 Cleanup old results
if exist "%RESULT_DIR%" rmdir /s /q "%RESULT_DIR%"
if exist "%REPORT_DIR%" rmdir /s /q "%REPORT_DIR%"

mkdir "%RESULT_DIR%"
mkdir "%REPORT_DIR%"

REM 🔹 Run JMeter test plan
echo Running JMeter test plan: %TEST_PLAN%
"%JMETER_BIN%\jmeter.bat" ^
  -n ^
  -t "%TEST_PLAN%" ^
  -l "%RESULT_DIR%\results.jtl" ^
  -e -o "%REPORT_DIR%" ^
  -Jcsv.dir="%CSV_DIR%" ^
  -Jimg.dir="%IMG_DIR%" %*

REM 🔹 Exit with last error level
if %ERRORLEVEL% neq 0 (
    echo ❌ JMeter execution failed!
    exit /b %ERRORLEVEL%
) else (
    echo ✅ JMeter execution completed successfully.
)

endlocal


