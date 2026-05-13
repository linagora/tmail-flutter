pipeline {
    agent {
        label 'test'
    }

    options {
        timeout(time: 180, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    environment {
        FLUTTER_VERSION = '3.38.9'
        API_LEVEL = '30'
        AVD_NAME = 'pixel_6'
    }

    stages {
        stage('Prebuild') {
            steps {
                sh './scripts/prebuild.sh'
            }
        }

        stage('Start Android Emulator') {
            steps {
                script {
                    // Ensure a clean adb state before launching.
                    sh 'adb kill-server || true'
                    sh 'adb start-server'

                    // Launch the headless emulator in the background.
                    // These flags mirror the GitHub Actions runner configuration
                    // and keep the emulator deterministic and CI-friendly.
                    sh """
                        nohup emulator -avd \${AVD_NAME} \
                            -no-snapshot-save \
                            -no-window \
                            -gpu swiftshader_indirect \
                            -noaudio \
                            -no-boot-anim \
                            -camera-back none \
                            > emulator.log 2>&1 &
                    """

                    // Wait until the device is visible to adb.
                    sh 'timeout 120 adb wait-for-device'

                    // Wait for the Android system to finish booting.
                    sh '''
                        timeout 600 adb shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 2; done; echo "boot_completed"'
                    '''

                    // Force screen geometry to match local Pixel 4 (prevents keyboard overflow)
                    sh '''
                        adb shell wm size 1080x2340
                        adb shell wm density 440
                    '''

                    // Disable animations so Patrol interactions are stable.
                    sh '''
                        adb shell settings put global window_animation_scale 0.0
                        adb shell settings put global transition_animation_scale 0.0
                        adb shell settings put global animator_duration_scale 0.0
                    '''

                    echo "Emulator \${AVD_NAME} (API \${API_LEVEL}) is ready."
                }
            }
        }

        stage('Run Patrol Mobile Integration Tests') {
            steps {
                sh './scripts/patrol-integration-test-with-docker.sh'
            }
        }
    }

    post {
        always {
            script {
                echo 'Running post-build cleanup...'

                // The test script kills the emulator in its own cleanup trap,
                // but we repeat the logic here in case the script exited early.
                sh 'adb emu kill || true'
                sleep 2

                // crashpad_handler ignores SIGTERM; use SIGKILL directly.
                // Retry a few times to catch any mid-spawn instances.
                sh '''
                    for _i in 1 2 3; do
                        pkill -SIGKILL crashpad_handler 2>/dev/null || break
                        sleep 1
                    done
                '''

                // Tear down the backend Docker stack if it is still running.
                sh '''
                    cd backend-docker
                    docker compose down --remove-orphans 2>/dev/null || true
                '''
            }
        }
        failure {
            echo 'Pipeline failed. Review the console log and emulator.log for details.'
        }
    }
}
