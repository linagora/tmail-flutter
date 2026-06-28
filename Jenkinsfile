pipeline {
    agent {
        label 'mobile'
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
        DOCKER_HUB_CREDENTIAL = credentials('dockerHub')
        GITHUB_CREDENTIAL = credentials('github')
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

        stage('Deliver Docker image for PR') {
          when {
            changeRequest()
          }
          steps {
            script {
              if (env.CHANGE_FORK) {
                def forkOwner = env.CHANGE_FORK.split('/')[0]
                def memberStatus = sh(
                  script: """curl -s -o /dev/null -w "%{http_code}" \
                    -H "Authorization: token \${GITHUB_CREDENTIAL_PSW}" \
                    "https://api.github.com/orgs/linagora/members/${forkOwner}" """,
                  returnStdout: true
                ).trim()
                echo "GitHub org membership check returned HTTP ${memberStatus} for '${forkOwner}'"
                if (memberStatus == '204') {
                  echo "Fork owner '${forkOwner}' is a linagora org member, proceeding."
                } else if (memberStatus == '404') {
                  echo "Fork owner '${forkOwner}' is not a member of the linagora organization."
                  def approvedByMember = false
                  def commentsJson = sh(
                    script: """curl -s \
                      -H "Authorization: token \${GITHUB_CREDENTIAL_PSW}" \
                      "https://api.github.com/repos/linagora/tmail-flutter/issues/\${CHANGE_ID}/comments" """,
                    returnStdout: true
                  ).trim()
                  def comments = new groovy.json.JsonSlurper().parseText(commentsJson)
                  for (comment in comments) {
                    if (comment.body.trim().toLowerCase() == 'build this please') {
                      def commenter = comment.user.login
                      def commenterStatus = sh(
                        script: """curl -s -o /dev/null -w "%{http_code}" \
                          -H "Authorization: token \${GITHUB_CREDENTIAL_PSW}" \
                          "https://api.github.com/orgs/linagora/members/${commenter}" """,
                        returnStdout: true
                      ).trim()
                      if (commenterStatus == '204') {
                        echo "Build approved by linagora member '${commenter}', proceeding."
                        approvedByMember = true
                        break
                      }
                    }
                  }
                  if (!approvedByMember) {
                    echo "No linagora member approval found. Skipping PR image delivery."
                    return
                  }
                } else if (memberStatus == '401' || memberStatus == '403') {
                  error("Authentication/permission error validating fork owner: ${memberStatus}")
                } else {
                  error("GitHub API error ${memberStatus} while checking membership for '${forkOwner}'")
                }
              }

              // Build and push the web Docker image tagged with the PR number to ease testing.
              sh '''
                docker build --build-arg FLUTTER_VERSION=$FLUTTER_VERSION -t linagora/tmail-web-pr:$CHANGE_ID .
                echo "$DOCKER_HUB_CREDENTIAL_PSW" | docker login -u "$DOCKER_HUB_CREDENTIAL_USR" --password-stdin
                docker push linagora/tmail-web-pr:$CHANGE_ID
                docker logout
              '''
              sh """
                HTTP_STATUS=\$(curl -s -o /tmp/gh_comment_response.json -w "%{http_code}" -X POST \\
                  -H "Authorization: token \${GITHUB_CREDENTIAL_PSW}" \\
                  -H "Content-Type: application/json" \\
                  -d "{\\"body\\": \\"Docker image published for this PR: linagora/tmail-web-pr:\${CHANGE_ID}\\"}" \\
                  "https://api.github.com/repos/linagora/tmail-flutter/issues/\${CHANGE_ID}/comments")
                if [ "\$HTTP_STATUS" -lt 200 ] || [ "\$HTTP_STATUS" -ge 300 ]; then
                  echo "WARNING: GitHub API comment failed with HTTP \$HTTP_STATUS"
                  cat /tmp/gh_comment_response.json
                fi
              """
            }
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
