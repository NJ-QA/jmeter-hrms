pipeline {
    agent any

    environment {
        JMETER_HOME = 'C:\\apache-jmeter-5.6.3'
        TEST_PLAN   = "${env.WORKSPACE}\\HRMS_MB.jmx"
        RESULTS_DIR = "${env.WORKSPACE}\\results"
        REPORTS_DIR = "${env.WORKSPACE}\\reports"
    }

    stages {
        stage('Run JMeter Test') {
            steps {
                echo "Running JMeter Test Plan..."
                bat 'runTest.bat'
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

        stage('Archive Results + Test Data') {
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
            echo "❌ JMeter test failed! Check console output for details."
        }
        success {
            echo "✅ JMeter test completed successfully!"
        }
    }
}
