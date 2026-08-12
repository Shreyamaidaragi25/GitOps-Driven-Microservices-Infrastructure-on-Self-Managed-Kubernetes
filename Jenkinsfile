pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "kuki25/pawcare"
        K8S_SERVER   = "https://10.0.1.16:6443"
        K8S_NAMESPACE = "default"
        K8S_DEPLOYMENT = "pawcare"
        K8S_CONTAINER  = "pawcare"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Python Setup') {
            steps {
                sh '''
                    python3 --version
                    python3 -m venv venv
                    ./venv/bin/pip install --upgrade pip
                    ./venv/bin/pip install -r app/requirements.txt
                '''
            }
        }

        stage('Application Test') {
            steps {
                sh '''
                    ./venv/bin/python -m py_compile app/app.py
                    echo "Python application syntax check passed"
                '''
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {
                sh '''
                    trivy fs \
                      --severity HIGH,CRITICAL \
                      --exit-code 0 \
                      --no-progress \
                      .
                '''
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    env.IMAGE_TAG = "${env.BUILD_NUMBER}"

                    sh """
                        docker build \
                          -t ${DOCKER_IMAGE}:${IMAGE_TAG} \
                          -t ${DOCKER_IMAGE}:latest \
                          .
                    """
                }
            }
        }

        stage('Trivy Docker Image Scan') {
            steps {
                sh '''
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 0 \
                      --no-progress \
                      ${DOCKER_IMAGE}:${IMAGE_TAG}
                '''
            }
        }

    stage('Test DockerHub Credential') {
        steps {
            withCredentials([
                usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )
            ]) {
                sh '''
                    echo "Username received: [$DOCKER_USERNAME]"
                    echo "Password received: [${DOCKER_PASSWORD:+YES}]"
                '''
            }
        }
    }

        stage('Deploy to K3s') {
    steps {
        sshagent(['k3s-master-ssh']) {
            sh '''
                ssh -o StrictHostKeyChecking=no \
                    ubuntu@10.0.1.16 \
                    "sudo kubectl set image deployment/$K8S_DEPLOYMENT \
                    $K8S_CONTAINER=$DOCKER_IMAGE:$IMAGE_TAG"
            '''
        }
    }
}

stage('Verify Deployment') {
    steps {
        sshagent(['k3s-master-ssh']) {
            sh '''
                ssh -o StrictHostKeyChecking=no \
                    ubuntu@10.0.1.16 \
                    "sudo kubectl rollout status deployment/$K8S_DEPLOYMENT \
                    --timeout=180s"

                ssh -o StrictHostKeyChecking=no \
                    ubuntu@10.0.1.16 \
                    "sudo kubectl get pods -o wide"
            '''
        }
    }
}
    post {
        success {
            echo "PawCare CI/CD pipeline completed successfully!"
            echo "Deployed image: ${DOCKER_IMAGE}:${IMAGE_TAG}"
        }

        failure {
            echo "PawCare CI/CD pipeline failed. Check the failed stage above."
        }

        always {
            sh 'docker image prune -f || true'
        }
    }
}
