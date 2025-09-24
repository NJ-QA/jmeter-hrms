pipeline {
    agent any

    environment {
        JMETER_HOME = "C:\\apache-jmeter-5.6.3"
        TEST_PLAN   = "${WORKSPACE}\\HRMS_MB.jmx"
        RESULTS_DIR = "${WORKSPACE}\\results"
        REPORTS_DIR = "${WORKSPACE}\\reports"
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Debug Paths') {
            steps {
                echo "JMeter Home: ${env.JMETER_HOME}"
                echo "Workspace : ${env.WORKSPACE}"
                echo "Test plan : ${env.TEST_PLAN}"
                echo "Results   : ${env.RESULTS_DIR}"
                echo "Reports   : ${env.REPORTS_DIR}"
                echo "Build No  : ${env.BUILD_NUMBER}"
            }
        }

        stage('Clean Old Reports') {
            steps {
                bat '''
                    if exist "%REPORTS_DIR%\\latest" (
                        echo Removing old 'latest' folder
                        rmdir /s /q "%REPORTS_DIR%\\latest"
                    )
                '''
            }
        }

        stage('Run JMeter Test') {
            steps {
                echo "Running JMeter test plan..."
                bat '"%WORKSPACE%\\runTest.bat"'
            }
        }

        stage('Copy Report to Latest') {
            steps {
                bat '''
                    echo Copying build report to latest...
                    set REPORT_FOLDER=%REPORTS_DIR%\\build-%BUILD_NUMBER%
                    mkdir "%REPORTS_DIR%\\latest"
                    xcopy /E /I /Y "%REPORT_FOLDER%\\*" "%REPORTS_DIR%\\latest\\"
                    echo Latest report contents:
                    dir "%REPORTS_DIR%\\latest"
                '''
            }
        }

        stage('Publish JMeter HTML Report') {
            steps {
                publishHTML(target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: "${env.REPORTS_DIR}\\latest",  // folder containing index.html + subfolders
                    reportFiles: "index.html",
                    reportName: "JMeter-HTML-Report",                  
                    includes: "**/*"   // 👈 <- important! includes all subfolders and resources
                ])
                echo "Reports dir: ${env.REPORTS_DIR}\\latest"
                echo "Report published at: ${env.WORKSPACE}\\reports\\latest\\index.html"
                echo "Full HTML report path: ${env.REPORTS_DIR}\\latest\\index.html"
            }
        }

        stage('Archive Results & Reports') {
            steps {
                archiveArtifacts artifacts: 'results/**, reports/build-*/**, reports/latest/**', fingerprint: true
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
        failure {
            echo "❌ JMeter test failed!"
        }
        success {
            echo "✅ JMeter test & report generated successfully!"
        }
    }
}
