pipeline {
    agent any

    environment {
 JMETER_VERSION = '5.6.3'
        JMETER_HOME = "${env.WORKSPACE}\\apache-jmeter-${JMETER_VERSION}"
        TEST_PLAN   = "${env.WORKSPACE}\\HRMS_MB.jmx"
        RESULTS_DIR = "${env.WORKSPACE}\\results"
        REPORTS_DIR = "${env.WORKSPACE}\\reports"

    }

    stages {
         stage('Debug Paths') {
            steps {
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

        stage('Setup JMeter') {
            steps {
                bat """
                    echo Downloading Apache JMeter...
                    powershell -command "Invoke-WebRequest -Uri https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-%JMETER_VERSION%.zip -OutFile jmeter.zip"
                    powershell -command "Expand-Archive -Path jmeter.zip -DestinationPath %WORKSPACE% -Force"
                """
            }
        }
        
       stage('Run JMeter Test') {
            steps {
                bat """
                    echo Cleaning old results...
                    if exist "%RESULTS_DIR%" rmdir /s /q "%RESULTS_DIR%"
                    if exist "%REPORTS_DIR%" rmdir /s /q "%REPORTS_DIR%"
                    mkdir "%RESULTS_DIR%"
                    mkdir "%REPORTS_DIR%"

                    echo Running JMeter test plan: %TEST_PLAN%
                    "%JMETER_HOME%\\bin\\jmeter.bat" -n -t "%TEST_PLAN%" -l "%RESULTS_DIR%\\results.csv" -e -o "%REPORTS_DIR%\\latest"
                """
            }
        }

        stage('Publish JMeter HTML Report') {
            steps {
                publishHTML(target: [
                    reportDir: '${env.REPORTS_DIR}\\latest',
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
                archiveArtifacts artifacts: 'results/**, csvs/**, images/**', fingerprint: true
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


