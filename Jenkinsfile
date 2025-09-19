pipeline {
    agent any

    environment {
        JMETER_VERSION = '5.6.3'      
        JMETER_HOME = 'C:\\apache-jmeter-5.6.3'
        TEST_PLAN   = "${env.WORKSPACE}\\HRMS_MB.jmx"
        RESULTS_DIR = "${env.WORKSPACE}\\results"
        REPORTS_DIR = "${env.WORKSPACE}\\reports"
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

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/NJ-QA/jmeter-hrms.git'
            }
        }

        stage('Run JMeter Test') {
            steps {
                echo "Running JMeter Test Plan: ${env.TEST_PLAN}"
                bat '"%WORKSPACE%\\runTest.bat"'
            }
        }

        stage('Verify and Publish JMeter HTML Report') {
            steps {
                script {
                    // ✅ Verify HTML report exists in "latest"
                    bat """
                        if exist "${REPORTS_DIR}\\latest\\index.html" (
                            echo HTML report exists:
                            dir "${REPORTS_DIR}\\latest"
                        ) else (
                            echo ERROR: HTML report not found!
                            exit /b 1
                        )
                    """

                    // ✅ Publish from "latest"
                    publishHTML(target: [
                        reportDir: "${env.REPORTS_DIR}/latest",
                        reportFiles: 'index.html',
                        reportName: "JMeterTestReport-${BUILD_NUMBER}",
                        keepAll: true,
                        alwaysLinkToLastBuild: true,
                        allowMissing: false
                    ])
                }
            }
        }

        stage('Archive Results + Test Data') {
            steps {
                archiveArtifacts artifacts: 'results/**, csvs/**, images/**, reports/**', fingerprint: true
            }
        }
    }

    post {
        always {
           // echo "Cleaning workspace..."
            echo "Skipping workspace cleanup to preserve JMeter and results."
            //echo "removed to keep JMeter and results cached"
           // deleteDir()
        }
        failure {
            echo "❌ JMeter test failed! Check console output for details."
        }
        success {
            echo "✅ JMeter test completed successfully!"
            echo "📊 Report via HTML Publisher: JMeterTestReport-${BUILD_NUMBER}"
            echo "📂 Direct Artifact Link: ${env.BUILD_URL}artifact/reports/latest/index.html"
        }
    }
}




