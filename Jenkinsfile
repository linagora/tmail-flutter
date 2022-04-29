pipeline {
  agent any

  options {
    // Configure an overall timeout for the build.
    timeout(time: 1, unit: 'HOURS')
    disableConcurrentBuilds()
  }

  stages {
    stage('Deliver web Docker image') {
      when {
        anyOf {
          branch 'master'
          branch 'release'
          buildingTag()
        }
      }
      steps {
        script {
          env.DOCKER_TAG = 'master'
          if (env.BRANCH_NAME == 'release') {
            env.DOCKER_TAG = 'release'
          }
          if (env.TAG_NAME) {
            env.DOCKER_TAG = env.TAG_NAME
          }

          echo "Docker tag: ${env.DOCKER_TAG}"

          // Build image
          sh "docker build -t linagora/tmail-web:${env.DOCKER_TAG} ."

          def webImage = docker.image "linagora/tmail-web:${env.DOCKER_TAG}"
          docker.withRegistry('', 'dockerHub') {
            webImage.push()
          }
        }
      }
    }
  }
}