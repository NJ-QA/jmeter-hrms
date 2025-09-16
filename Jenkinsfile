pipeline {
    agent any

    environment {
        // Git credentials ID
        GIT_CREDENTIALS = '5fb4bd9e-aada-4473-a6b0-8697d93c1869'
        REPO_URL = 'https://github.com/NJ-QA/jmeter-hrms.git'
        JMETER_HOME = 'C:\\apache-jmeter-5.6.3' // Adjust path as needed
        TEST_PLAN = 'HRMS_MB.jmx' // Your JMeter test plan
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning JMeter project from Git...'
                git url: env.REPO_URL, credentialsId: env.GIT_CREDENTIALS
            }
        }

        stage('Setup JMeter') {
            steps {
                script {
                    if (!fileExists(env.JMETER_HOME + '\\bin\\jmeter.bat')) {
                        echo "JMeter not found. Please install JMeter at ${env.JMETER_HOME}"
                        error "JMeter missing. Cannot continue."
                    } else {
                        echo "JMeter found at ${env.JMETER_HOME}"
                    }
                }
            }
        }

        stage('Run JMeter Test') {
            steps {
                echo "Running JMeter Test Plan..."
                // Windows command to run JMeter
                bat "\"${env.JMETER_HOME}\\bin\\jmeter.bat\" -n -t ${env.TEST_PLAN} -l reports/latest/results.jtl -e -o reports/latest"
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
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs for errors."
        }
    }
}

