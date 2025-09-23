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
        stage('Debug Paths') {
            steps {
                echo "JMeter Home: ${env.JMETER_HOME}"
                echo "WORKSPACE path: ${env.WORKSPACE}"
                echo "Test plan path: ${env.TEST_PLAN}"
                echo "Results dir: ${env.RESULTS_DIR}"
                echo "Reports dir: ${env.REPORTS_DIR}"
            }
        }

        stage('Clear CSV Cache'){
            steps{
                 echo "Clearing Universal CSV Loader cache..."
                script{
                    // Ensure latest CSV is used
                    def groovyScript = """
                        props.remove('universalCsvLoader')
                        props.remove('__universalCsvLoaderInit')
                        log.info('✅ Cleared Universal CSV Loader cache')
                    """
                    writeFile file: "${WORKSPACE}\\clearCsvCache.groovy", text: groovyScript
                    bat "\"${JMETER_HOME}\\bin\\jmeter.bat\" -n -t \"${TEST_PLAN}\" -JclearCsv=true -q \"${JMETER_HOME}\\bin\\user.properties\""
                }
            }
            
        }

        stage('Run JMeter Test + Generate Report') {
            steps {
                echo "Running JMeter Test Plan..."
                bat '"%WORKSPACE%\\runTest.bat"'
            }
        }

        stage('Publish JMeter HTML Report') {
            steps {
                publishHTML(target: [
                    reportDir: "${env.REPORTS_DIR}\\latest",
                    reportFiles: "index.html",
                    reportName: "JMeter-HTML-Report",
                    keepAll: true,
                    alwaysLinkToLastBuild: true,
                    allowMissing: false
                ])
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




