pipeline {
    agent any

    environment {
        JMETER_HOME = "C:\\apache-jmeter-5.6.3"
        TEST_PLAN = "${WORKSPACE}\\HRMS_MB.jmx"
        RESULTS_DIR = "${WORKSPACE}\\results"
        REPORTS_DIR = "${WORKSPACE}\\reports"
        BUILD_NUMBER = "${env.BUILD_NUMBER}"        
    }

    stages {
        stage('Debug Paths & Latest CSV') {
            steps {
                echo "JMeter Home: ${env.JMETER_HOME}"
                echo "WORKSPACE path: ${env.WORKSPACE}"
                echo "Test plan path: ${env.TEST_PLAN}"
                echo "Results dir: ${env.RESULTS_DIR}"
                echo "Reports dir: ${env.REPORTS_DIR}"
                echo "Build Number: ${env.BUILD_NUMBER}"
            }
        }

       
        stage('Clean Reports') {
            steps {
                bat '''
                    if exist "%REPORTS_DIR%\\build-%BUILD_NUMBER%" (
                        echo Cleaning old report folder: %REPORTS_DIR%\\build-%BUILD_NUMBER%
                        rmdir /s /q "%REPORTS_DIR%\\build-%BUILD_NUMBER%"
                    )
                    if exist "%REPORTS_DIR%\\latest" (
                        echo Cleaning old latest report folder
                        rmdir /s /q "%REPORTS_DIR%\\latest%"
                    )
                '''
            }
        }
        
       stage('Run JMeter Test + Generate Report') {
            steps {
                echo "Running JMeter Test Plan..."
                bat '"%WORKSPACE%\\runTest.bat"'
            }
        }

       stage('Copy Report to Latest') {
            steps {
                bat '''
                    echo Creating/Updating latest report folder...
                    if exist "%REPORTS_DIR%\\latest" rmdir /s /q "%REPORTS_DIR%\\latest"
                    mkdir "%REPORTS_DIR%\\latest"
                    xcopy /e /i /y "%REPORTS_DIR%\\build-%BUILD_NUMBER%" "%REPORTS_DIR%\\latest"
                '''
            }
        }

        stage('Publish JMeter HTML Report') {
            steps {
                publishHTML(target: [
                    reportDir: "${env.REPORTS_DIR}/latest",
                    reportFiles: "index.html",
                    reportName: "JMeter-HTML-Report",
                    keepAll: true,
                    alwaysLinkToLastBuild: true,
                    allowMissing: false
                    
                ])
                echo "Reports dir: ${env.REPORTS_DIR}/latest"
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
            echo "Pipeline finished. Check console and HTML report."
        }
        failure {
            echo "❌ JMeter test failed!"
        }
        success {
            echo "✅ JMeter test & report generated successfully!"
        }
    }
}

