def isPrImageEligible() {
    if (!env.CHANGE_ID) {
        return false
    }
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
        def commentsStatus = sh(
          script: """curl -s -o /tmp/pr_comments_${CHANGE_ID}.json -w "%{http_code}" \
            -H "Authorization: token \${GITHUB_CREDENTIAL_PSW}" \
            "https://api.github.com/repos/linagora/tmail-flutter/issues/\${CHANGE_ID}/comments" """,
          returnStdout: true
        ).trim()
        if (commentsStatus != '200') {
          error("GitHub API error ${commentsStatus} while fetching PR comments for approval check")
        }
        def commentsJson = readFile("/tmp/pr_comments_${CHANGE_ID}.json")
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
          return false
        }
      } else if (memberStatus == '401' || memberStatus == '403') {
        error("Authentication/permission error validating fork owner: ${memberStatus}")
      } else {
        error("GitHub API error ${memberStatus} while checking membership for '${forkOwner}'")
      }
    }
    return true
}

pipeline {
    agent {
        label 'flutter-web'
    }

    tools {
        nodejs 'nodejs_24'
    }

    options {
        timeout(time: 180, unit: 'MINUTES')
        disableConcurrentBuilds(abortPrevious: true)
        buildDiscarder(logRotator(daysToKeepStr: '5', artifactDaysToKeepStr: '5'))
    }

    environment {
        FLUTTER_VERSION = '3.38.9'
    }

    stages {
        stage('Run web tests and build PR image') {
            steps {
                script {
                    env.PR_IMAGE_BUILT = 'false'
                    // Decided before the PR's scripts run: the GitHub token must not be bound beside them.
                    def buildPrImage = false
                    if (env.CHANGE_ID) {
                        withCredentials([usernamePassword(credentialsId: 'github', usernameVariable: 'GITHUB_CREDENTIAL_USR', passwordVariable: 'GITHUB_CREDENTIAL_PSW')]) {
                            buildPrImage = isPrImageEligible()
                        }
                    }
                    parallel(
                        tests: {
                            sh './scripts/prebuild.sh'
                            // One Patrol job per agent: the backend container and its ports are host-wide.
                            sh 'flock -o /tmp/tmail-patrol-backend.lock ./scripts/patrol-web-integration-test-with-docker.sh'
                        },
                        image: {
                            if (buildPrImage) {
                                // A tracked-files snapshot: the workspace is being written by prebuild meanwhile.
                                sh '''
                                    QUOTA=${PR_IMAGE_CPU_QUOTA:-200000}
                                    case $QUOTA in ''|*[!0-9]*) QUOTA=200000 ;; esac
                                    # The quota is part of the name: an existing builder keeps the limits it was created with.
                                    BUILDER=tmail-pr-image-q$QUOTA
                                    CAPPED=0
                                    if docker buildx version >/dev/null 2>&1; then
                                        # Low CPU cap: the image build must not starve the parallel Patrol tests.
                                        if flock /tmp/tmail-pr-image-builder.lock sh -c "docker buildx inspect $BUILDER >/dev/null 2>&1 || \
                                            docker buildx create --name $BUILDER --driver docker-container \
                                            --driver-opt cpu-period=100000 --driver-opt cpu-quota=$QUOTA"; then
                                            CAPPED=1
                                        fi
                                    fi
                                    if [ "$CAPPED" = 1 ]; then
                                        echo "PR image build: capped, builder $BUILDER"
                                        git archive --format=tar HEAD | docker buildx build --builder "$BUILDER" --load \
                                            --build-arg FLUTTER_VERSION=$FLUTTER_VERSION -t linagora/tmail-web-pr:$CHANGE_ID -
                                    else
                                        echo "PR image build: UNCAPPED (no buildx or builder unavailable)"
                                        git archive --format=tar HEAD | docker build --build-arg FLUTTER_VERSION=$FLUTTER_VERSION -t linagora/tmail-web-pr:$CHANGE_ID -
                                    fi
                                '''
                                env.PR_IMAGE_BUILT = 'true'
                            }
                        },
                        failFast: false
                    )
                }
            }
        }

        stage('Deliver Docker image for PR') {
          when {
            allOf {
              changeRequest()
              expression { env.PR_IMAGE_BUILT == 'true' }
            }
          }
          environment {
            DOCKER_HUB_CREDENTIAL = credentials('dockerHub')
            GITHUB_CREDENTIAL = credentials('github')
          }
          steps {
            script {
              // Publish only after the parallel tests and image build succeed.
              sh '''
                set -eu
                export DOCKER_CONFIG="$(mktemp -d)"
                cleanup() {
                  docker logout || true
                  rm -rf "$DOCKER_CONFIG"
                }
                trap cleanup EXIT
                echo "$DOCKER_HUB_CREDENTIAL_PSW" | docker login -u "$DOCKER_HUB_CREDENTIAL_USR" --password-stdin
                docker push linagora/tmail-web-pr:$CHANGE_ID
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

                archiveArtifacts artifacts: 'ci-logs/**', allowEmptyArchive: true

                // Tear down the backend Docker stack if it is still running and belongs to this workspace.
                sh '''
                    [ -f scripts/ci-backend-teardown.sh ] || exit 0
                    flock -n -o /tmp/tmail-patrol-backend.lock bash scripts/ci-backend-teardown.sh \
                        || echo "agent backend lock held by another job; skip teardown."
                '''
            }
            deleteDir() /* clean up our workspace */
        }
        failure {
            echo 'Pipeline failed. Review the console log and emulator.log for details.'
        }
    }
}
