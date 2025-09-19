pipeline {
    agent any

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
                    reportName: 'JMeterTestReport',
                    keepAll: true,
                    alwaysLinkToLastBuild: true,
                    allowMissing: false
                ])
            }
        }

        stage('Archive CSV + Images') {
            steps {
                archiveArtifacts artifacts: 'csvs/**, images/**', fingerprint: true
            }
        }
    }

    post {
        always {
            echo "Cleaning workspace..."
            deleteDir()
        }
    }
}



