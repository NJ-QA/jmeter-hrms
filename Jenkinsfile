pipeline {
    agent any

    environment {
        GIT_CREDENTIALS = '5fb4bd9e-aada-4473-a6b0-8697d93c1869'
        REPO_URL = 'https://github.com/NJ-QA/jmeter-hrms.git'
        BRANCH_NAME = 'main'
        JMETER_HOME = "${env.WORKSPACE}\\apache-jmeter-5.6.3"
        JMETER_ZIP_URL = 'https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.6.3.zip'
        TEST_PLAN = 'HRMS_MB.jmx' // Your JMX file name
        REPORT_DIR = 'reports\\latest'
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out branch '${env.BRANCH_NAME}' from ${env.REPO_URL}"
                git url: env.REPO_URL,
                    branch: env.BRANCH_NAME,
                    credentialsId: env.GIT_CREDENTIALS
            }
        }

        stage('Setup JMeter') {
            steps {
                script {
                    if (!fileExists("${JMETER_HOME}\\bin\\jmeter.bat")) {
                        echo "JMeter not found. Downloading..."
                        powershell """
                            Invoke-WebRequest -Uri '${JMETER_ZIP_URL}' -OutFile '${env.WORKSPACE}\\jmeter.zip'
                        """
                        powershell """
                            Expand-Archive -Path '${env.WORKSPACE}\\jmeter.zip' -DestinationPath '${env.WORKSPACE}' -Force
                        """
                        echo "JMeter downloaded and extracted to ${JMETER_HOME}"
                    } else {
                        echo "JMeter already exists at ${JMETER_HOME}"
                    }
                }
            }
        }

        stage('Prepare Reports Folder') {
            steps {
                echo "Ensuring reports folder exists..."
                bat "mkdir reports || echo Folder exists"
                bat "mkdir ${REPORT_DIR} || echo Folder exists"
            }
        }

        stage('Run JMeter Test') {
            steps {
                echo "Running JMeter Test Plan..."
                bat "\"${JMETER_HOME}\\bin\\jmeter.bat\" -n -t ${TEST_PLAN} -l ${REPORT_DIR}\\results.jtl -e -o ${REPORT_DIR}"
            }
        }

        stage('Publish JMeter HTML Report') {
            steps {
                script {
                    if (fileExists("${REPORT_DIR}\\index.html")) {
                        echo "Publishing JMeter HTML report..."
                        publishHTML(target: [
                            reportDir: REPORT_DIR,
                            reportFiles: 'index.html',
                            reportName: 'JMeterTestReport',
                            keepAll: true,
                            alwaysLinkToLastBuild: true,
                            allowMissing: false
                        ])
                    } else {
                        echo "WARNING: JMeter HTML report not found! Skipping publish step."
                        // Do not fail the pipeline if report is missing
                        publishHTML(target: [
                            reportDir: REPORT_DIR,
                            reportFiles: 'index.html',
                            reportName: 'JMeterTestReport',
                            keepAll: true,
                            alwaysLinkToLastBuild: true,
                            allowMissing: true
                        ])
                    }
                }
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

