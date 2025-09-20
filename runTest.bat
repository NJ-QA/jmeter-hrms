@echo off
REM ============================================================================
REM runTest.bat - Run JMeter test and generate HTML report (Jenkins compatible)
REM ============================================================================

REM --- Accept WORKSPACE from Jenkins as first arg ---
if "%~1"=="" (
  set "WORKSPACE=%CD%"
) else (
  set "WORKSPACE=%~1"
)

REM --- Setup paths ---
set "JMETER_HOME=C:\apache-jmeter-5.6.3"
set "TEST_PLAN=%WORKSPACE%\HRMS_MB.jmx"
set "RESULTS_DIR=%WORKSPACE%\results"
set "REPORTS_DIR=%WORKSPACE%\reports"
set "REPORT_LATEST=%REPORTS_DIR%\latest"

REM --- Cleanup old results ---
if exist "%RESULTS_DIR%" rmdir /s /q "%RESULTS_DIR%"
if exist "%REPORTS_DIR%" rmdir /s /q "%REPORTS_DIR%"

mkdir "%RESULTS_DIR%"
mkdir "%REPORTS_DIR%"
mkdir "%REPORT_LATEST%"

REM --- Generate unique results file ---
set "RESULTS_FILE=%RESULTS_DIR%\results-%DATE:~-4%%DATE:~3,2%%DATE:~0,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.csv"
set "RESULTS_FILE=%RESULTS_FILE: =0%"

echo Running JMeter test plan: %TEST_PLAN%
echo Results file: %RESULTS_FILE%
echo Report dir: %REPORT_LATEST%

REM --- Run JMeter test ---
"%JMETER_HOME%\bin\jmeter.bat" ^
  -n -t "%TEST_PLAN%" ^
  -l "%RESULTS_FILE%" ^
  -e -o "%REPORT_LATEST%"

REM --- Verify report created ---
if exist "%REPORT_LATEST%\index.html" (
  echo ✅ JMeter HTML report generated successfully.
  exit /b 0
) else (
  echo ❌ ERROR: JMeter report not found!
  exit /b 1
)
