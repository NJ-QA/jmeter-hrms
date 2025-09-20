pipeline {
    agent any

    environment {
        JMETER_HOME = "C:\\apache-jmeter-5.6.3"
        TEST_PLAN = "${WORKSPACE}\\HRMS_MB.jmx"
        RESULTS_DIR = "${WORKSPACE}\\results"
        REPORTS_DIR = "${WORKSPACE}\\reports"
    }

    stages {
        stage('Debug Paths') {
            steps {
                echo "JMeter Home: ${env.JMETER_HOME}"
                echo "WORKSPACE path: ${env.WORKSPACE}"
                echo "Test plan path: ${env.TEST_PLAN}"
                echo "Results dir:   ${env.RESULTS_DIR}"
                echo "Reports dir:   ${env.REPORTS_DIR}"
            }
        }

        stage('Run JMeter Test + Generate Report') {
            steps {
                echo "Running JMeter Test Plan: ${env.TEST_PLAN}"

                bat """
                set RESULTS_DIR=%WORKSPACE%\\results
                set REPORTS_DIR=%WORKSPACE%\\reports
                set REPORT_FOLDER=%REPORTS_DIR%\\build-%BUILD_NUMBER%

                if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"
                if not exist "%REPORTS_DIR%" mkdir "%REPORTS_DIR%"

                rem === Clean report folder before generating ===
                if exist "%REPORT_FOLDER%" rmdir /s /q "%REPORT_FOLDER%"

                rem === Run JMeter test with CSV + HTML report ===
                "%JMETER_HOME%\\bin\\jmeter.bat" -n -t "%TEST_PLAN%" ^
                   -l "%RESULTS_DIR%\\results-%BUILD_NUMBER%.csv" ^
                   -e -o "%REPORT_FOLDER%"

                rem === Copy report to 'latest' for Jenkins publish ===
                if exist "%REPORTS_DIR%\\latest" rmdir /s /q "%REPORTS_DIR%\\latest"
                xcopy /e /i /y "%REPORT_FOLDER%" "%REPORTS_DIR%\\latest"
                """
            }
        }

        stage('Publish JMeter HTML Report') {
            steps {
                publishHTML(target: [
                    allowMissing: false,
                    keepAll: true,
                    alwaysLinkToLastBuild: true,
                    reportDir: "reports/latest",
                    reportFiles: "index.html",
                    reportName: "JMeter HTML Report"
                ])
            }
        }

        stage('Archive Results & Reports') {
            steps {
                archiveArtifacts artifacts: 'results/**, reports/build-*/**', 'csvs/**', 'images/**', fingerprint: true
            }
        }
    }

    post {
        always {
            echo "Cleaning up old workspaces..."
            // cleanWs()  // optional
        }
        failure {
            echo "❌ JMeter test failed! Check logs."
        }
        success {
            echo "✅ JMeter test & report generated successfully!"
        }
    }
}
