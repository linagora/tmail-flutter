pipeline {
  agent {
    label 'jdk11'
  }

  options {
    // Configure an overall timeout for the build.
    timeout(time: 1, unit: 'HOURS')
    disableConcurrentBuilds()
  }

  stages {
    stage('Build TMail web app') {
      steps {
        // Build image
        sh "docker build -t linagora/tmail-web ."
      }
    }
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
          if (env.TAG_NAME) {
            env.DOCKER_TAG = env.TAG_NAME
          } else {
            env.DOCKER_TAG = env.BRANCH_NAME
          }

          echo "Docker tag: ${env.DOCKER_TAG}"

          // retag image name previously built
          sh "docker tag linagora/tmail-web linagora/tmail-web:${env.DOCKER_TAG}"

          def webImage = docker.image "linagora/tmail-web:${env.DOCKER_TAG}"
          docker.withRegistry('', 'dockerHub') {
            webImage.push()
          }
        }
      }
    }
  }
}