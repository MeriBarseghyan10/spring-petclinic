pipeline {
    agent {
        label 'inbound-agent'
    }

    environment {
        // Setting the PATH to include Maven
        PATH = "/usr/local/bin:$PATH"

        // Defining repository URLs for Docker images
        MAIN_REPO_URL = 'http://localhost:8082/repository/main'
        MR_REPO_URL = 'http://localhost:8083/repository/mr'
    }

    stages {
        stage('Maven Install or Prepare') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        echo 'Preparing project for main branch (Skipping Tests)...'
                        sh './mvnw clean install -DskipTests'
                    } else {
                        echo 'Running full Maven install including tests for branch: ${env.BRANCH_NAME}'
                        sh './mvnw clean install'
                    }
                }
            }
        }

        stage('Checkstyle') {
            when {
                not { branch 'main' }
            }
            steps {
                echo 'Running Checkstyle analysis...'
                sh './mvnw checkstyle:checkstyle'
                archiveArtifacts artifacts: '**/target/checkstyle-result.xml', fingerprint: true
            }
        }

        stage('Test') {
            when {
                not { branch 'main' }
            }
            steps {
                echo 'Running tests...'
                sh 'mvn test'
            }
        }

        stage('Create and Push Docker Image') {
            steps {
                script {
                    def commitSha = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageName = "spring-petclinic:${commitSha}"
                    def appImage
                    if (env.BRANCH_NAME == 'main') {
                        sh "docker build -t ${MAIN_REPO_URL}/${imageName} ."
                        sh "docker push ${MAIN_REPO_URL}/${imageName}"
                    } else {
                        sh "docker build -t ${MR_REPO_URL}/${imageName} ."
                        sh "docker push ${MR_REPO_URL}/${imageName}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
        }
    }
}
