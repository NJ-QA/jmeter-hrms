pipeline {
    agent any

    environment {
        JMETER_HOME = 'C:\\apache-jmeter-5.6.3'
        TEST_PLAN = "${env.WORKSPACE}\\HRMS_MB.jmx"
        RESULTS_DIR = "${env.WORKSPACE}\\results"
        REPORTS_DIR = "${env.WORKSPACE}\\reports"
    }

    stages {
        stage('Run JMeter Test') {
            steps {
                echo "Running JMeter Test Plan..."
                bat """
                REM Generate timestamp
                for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set ldt=%%I
                set TS=%%ldt:~0,8%%_%%ldt:~8,6%%
                
                REM Run JMeter
                "%JMETER_HOME%\\bin\\jmeter.bat" -p "%JMETER_HOME%\\bin\\user.properties" -n -t "%TEST_PLAN%" -l "%RESULTS_DIR%\\results-%TS%.csv" -e -o "%REPORTS_DIR%\\latest"
                
                if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
                """
            }
        }

        stage('Publish JMeter HTML Report') {
            steps {
                publishHTML(target: [
                    reportDir: 'reports/latest',
                    reportFiles: 'index.html',
                    reportName: "JMeterTestReport-${env.BUILD_NUMBER}",
                    keepAll: true,
                    alwaysLinkToLastBuild: true,
                    allowMissing: false
                ])
            }
        }

        stage('Archive CSV + Images') {
            steps {
                archiveArtifacts artifacts: 'results/*.csv, csvs/**, images/**', fingerprint: true
            }
        }
    }

    post {
        always {
            echo "Cleaning workspace..."
            deleteDir()
        }
        failure {
            echo "JMeter test failed! Check console output for details."
        }
    }
}
