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
        FLUTTER_VERSION = '3.47.9'
        FLUTTER_ROOT    = "/opt/flutter-${FLUTTER_VERSION}"
        PATH            = "${FLUTTER_ROOT}/bin:${env.PATH}"
        WEB_WORKERS = '4'
        PR_IMAGE_CPU_QUOTA = '100000'
    }

    // No pipeline-level credentials, see withGithubCredential and withDockerHubLogin.
    stages {
        stage('Authorize fork') {
            // A fork pull request runs no code of its own before an org member vouches for its head
            // commit, see authorizeFork
            when {
                changeRequest()
                expression { env.CHANGE_FORK != null }
            }
            steps {
                script {
                    authorizeFork()
                }
            }
        }
        stage('Check Flutter version') {
            steps {
                sh './scripts/ci-assert-flutter-version.sh'
            }
        }

        stage('Run web tests and build PR image') {
            steps {
                script {
                    env.PR_IMAGE_BUILT = 'false'
                    // A fork pull request reaches this stage only once authorized, see authorizeFork
                    def buildPrImage = env.CHANGE_ID != null
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
                                    # Low CPU cap so the parallel Patrol tests are not starved; no skip, or the old PR image stays published.
                                    if ! docker buildx version >/dev/null 2>&1 || \
                                        ! flock /tmp/tmail-pr-image-builder.lock sh -c "docker buildx inspect $BUILDER >/dev/null 2>&1 || \
                                            docker buildx create --name $BUILDER --driver docker-container \
                                            --driver-opt cpu-period=100000 --driver-opt cpu-quota=$QUOTA"; then
                                        echo "PR image build: capped builder unavailable"
                                        exit 1
                                    fi
                                    echo "PR image build: capped, builder $BUILDER"
                                    git archive --format=tar HEAD | docker buildx build --builder "$BUILDER" --load \
                                        --build-arg FLUTTER_VERSION=$FLUTTER_VERSION -t linagora/tmail-web-pr:$CHANGE_ID -
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
          steps {
            script {
              // Publish only after the parallel tests and image build succeed.
              withDockerHubLogin {
                sh 'docker push linagora/tmail-web-pr:$CHANGE_ID'
              }
              withGithubCredential {
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
    }

    post {
        always {
            script {
                echo 'Running post-build cleanup...'

                archiveArtifacts artifacts: 'ci-logs/**', allowEmptyArchive: true

                // Tear down the backend Docker stack if it is still running and belongs to this workspace.
                if (mayRunChangeCode()) {
                  sh '''
                      [ -f scripts/ci-backend-teardown.sh ] || exit 0
                      flock -n -o /tmp/tmail-patrol-backend.lock bash scripts/ci-backend-teardown.sh \
                          || echo "agent backend lock held by another job; skip teardown."
                  '''
                }
            }
            deleteDir() /* clean up our workspace */
        }
        failure {
            echo 'Pipeline failed. Review the console log and emulator.log for details.'
        }
    }
}

def githubRepository() {
  return 'linagora/tmail-flutter'
}

// ---- Fork authorization and credentials. The same block is in the Jenkinsfiles of
// twake-contacts-frontend, twake-calendar-frontend, twake-calendar-side-service, webadmin-proxy,
// tmail-flutter and esn-sabre: change it in all of them. Only githubRepository() differs.
//
// No credential is bound at pipeline level: every stage runs code of the checked out sources (build
// plugins, package scripts, tests, scripts/), so secrets are bound only around the steps that need
// them, see withGithubCredential and withDockerHubLogin.

// A fork pull request runs no code of its own before an org member vouches for its head commit: the
// owner of the fork is a linagora member, or a member submitted a review on that very commit (an
// approval, or a review comment 'Build this please'). GitHub ties the review to that commit
// (commit_id), so a commit pushed after the approval is not built until a member reviews it again.
def authorizeFork() {
  withGithubCredential {
    // CHANGE_FORK is 'owner', or 'owner/repository' for a fork renamed on GitHub
    def forkOwner = env.CHANGE_FORK.tokenize('/')[0]
    if (isOrgMember(forkOwner)) {
      echo "Fork owner '${forkOwner}' is a linagora org member, proceeding."
      env.FORK_AUTHORIZED = 'true'
      return
    }
    def headSha = checkedOutPullRequestHead()
    def approver = memberReviewerOf(headSha)
    if (approver) {
      echo "Commit ${headSha} approved by linagora member '${approver}', proceeding."
      env.FORK_AUTHORIZED = 'true'
      return
    }
    error("Fork owner '${forkOwner}' is not a linagora org member and no member reviewed commit ${headSha}. " +
      "A linagora member must approve the pull request, or submit a review 'Build this please', " +
      "on this commit, then re-run the build.")
  }
}

// Whether the build may run code of the checked out sources, for the post actions that run even
// when the fork authorization failed
def mayRunChangeCode() {
  return env.CHANGE_FORK == null || env.FORK_AUTHORIZED == 'true'
}

// The head commit of the pull request, checked against the sources Jenkins checked out: HEAD itself,
// or the second parent of the merge commit Jenkins builds with the target branch
def checkedOutPullRequestHead() {
  def headSha = githubApi("pulls/${env.CHANGE_ID}").head.sha
  def checkedOut = sh(script: 'git rev-parse HEAD; git rev-parse -q --verify "HEAD^2" || true', returnStdout: true)
    .trim().tokenize('\n')
  if (!checkedOut.contains(headSha)) {
    error("The pull request head moved to ${headSha} since the checkout of ${checkedOut}: re-run the build.")
  }
  return headSha
}

// The login of a linagora member who approved the given commit, or reviewed it with 'Build this please'
def memberReviewerOf(String sha) {
  def reviews = githubApi("pulls/${env.CHANGE_ID}/reviews?per_page=100")
  for (review in reviews) {
    def approves = review.state == 'APPROVED' ||
      (review.state != 'DISMISSED' && "${review.body}".trim() == 'Build this please')
    if (review.commit_id == sha && approves && isOrgMember(review.user.login)) {
      return review.user.login
    }
  }
  return null
}

def isOrgMember(String login) {
  def status
  withEnv(["GITHUB_LOGIN=${login}"]) {
    status = sh(
      script: 'curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_CREDENTIAL_PSW" ' +
        '"https://api.github.com/orgs/linagora/members/$GITHUB_LOGIN"',
      returnStdout: true
    ).trim()
  }
  echo "GitHub org membership check returned HTTP ${status} for '${login}'"
  if (status == '204') {
    return true
  }
  if (status == '404') {
    return false
  }
  error("GitHub API error ${status} while checking the membership of '${login}'")
}

def githubApi(String path) {
  def json
  withEnv(["GITHUB_API_PATH=${path}", "GITHUB_API_REPOSITORY=${githubRepository()}"]) {
    json = sh(
      script: 'curl -sf -H "Authorization: token $GITHUB_CREDENTIAL_PSW" ' +
        '"https://api.github.com/repos/$GITHUB_API_REPOSITORY/$GITHUB_API_PATH"',
      returnStdout: true
    )
  }
  return readJSON(text: json)
}

// Binds the GitHub token as GITHUB_CREDENTIAL_USR / GITHUB_CREDENTIAL_PSW around the given steps only
def withGithubCredential(Closure body) {
  withCredentials([usernamePassword(credentialsId: 'github',
      usernameVariable: 'GITHUB_CREDENTIAL_USR', passwordVariable: 'GITHUB_CREDENTIAL_PSW')]) {
    body()
  }
}

// Logs in Docker Hub in a throwaway Docker config deleted afterwards, so that the credential never
// stays on the agent where a later build could read it
def withDockerHubLogin(Closure body) {
  withEnv(["DOCKER_CONFIG=${pwd(tmp: true)}/docker-config"]) {
    try {
      withCredentials([usernamePassword(credentialsId: 'dockerHub',
          usernameVariable: 'DOCKER_HUB_CREDENTIAL_USR', passwordVariable: 'DOCKER_HUB_CREDENTIAL_PSW')]) {
        sh 'mkdir -p "$DOCKER_CONFIG" && printf \'%s\' "$DOCKER_HUB_CREDENTIAL_PSW" | docker login -u "$DOCKER_HUB_CREDENTIAL_USR" --password-stdin'
      }
      body()
    } finally {
      sh 'docker logout || true; rm -rf "$DOCKER_CONFIG"'
    }
  }
}
