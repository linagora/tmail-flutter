pipeline {
    agent {
        label 'test'
    }

    tools {
        nodejs 'nodejs_24'
    }

    options {
        timeout(time: 180, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    environment {
        FLUTTER_VERSION = '3.38.9'
    }

    stages {
        stage('Prebuild') {
            steps {
                sh './scripts/prebuild.sh'
            }
        }

        stage('Run Patrol Web Integration Tests') {
            steps {
                sh './scripts/patrol-web-integration-test-with-docker.sh'
            }
        }
    }

    post {
        always {
            script {
                echo 'Running post-build cleanup...'

                // Tear down the backend Docker stack if it is still running.
                sh '''
                    cd backend-docker
                    docker compose down --remove-orphans 2>/dev/null || true
                '''
            }
            deleteDir() /* clean up our workspace */
        }
        failure {
            echo 'Pipeline failed. Review the console log and emulator.log for details.'
        }
    }
}
