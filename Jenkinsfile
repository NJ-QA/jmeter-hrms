pipeline {
    agent any
     
    stages {
        stage('Run JMeter Test') {
            steps {
                echo "Running JMeter Test Plan..."
                bat 'runTest.bat -Jdomain=qa.myserver.com'
            }
        }

        stage('Publish JMeter HTML Report') {
            steps {
                script {
                    if(fileExists('reports/latest/index.html')){
                publishHTML(target: [
                    reportDir: 'reports/latest',
                    reportFiles: 'index.html',
                    reportName: 'JMeterTestReport',
                    keepAll: true,
                    alwaysLinkToLastBuild: true,
                    allowMissing: false
                ])
            } else{
                        echo "JMeter HTML report not found!"
                    }
        }
            }
        }
        stage('Archive CSV + Images') {
            steps {
                archiveArtifacts artifacts: 'csvs/**, images/**', fingerprint: true, llowEmptyArchive: true
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


