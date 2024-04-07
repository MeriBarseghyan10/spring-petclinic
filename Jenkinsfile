pipeline {
    agent any

    environment {
        // Defining main repository URL using host.docker.internal for Docker-in-Docker communication
        MAIN_REPO_URL = 'http://host.docker.internal:8082/repository/main' // Consider using HTTPS instead of HTTP for security
    }

    stages {
        stage('Checkstyle') {
            when {
                not { branch 'main' } // Only run this stage if the branch is not 'main'
            }
            steps {
                echo 'Running Checkstyle analysis...'
                script {
                    docker.image('maven:3.6.3-jdk-11').inside {
                        sh 'mvn checkstyle:checkstyle'
                        // Note: Depending on your setup, you may need to adjust paths for artifact archiving
                    }
                }
                archiveArtifacts artifacts: '**/target/checkstyle-result.xml', fingerprint: true
            }
        }

        stage('Test') {
            when {
                not { branch 'main' } // Only run this stage if the branch is not 'main'
            }
            steps {
                echo 'Running tests...'
                script {
                    docker.image('maven:3.6.3-jdk-11').inside {
                        sh 'mvn test'
                    }
                }
            }
        }

        stage('Build') {
            when {
                not { branch 'main' } // Only run this stage if the branch is not 'main'
            }
            steps {
                echo 'Building project (without tests)...'
                script {
                    docker.image('maven:3.6.3-jdk-11').inside {
                        sh 'mvn clean install -DskipTests'
                    }
                }
            }
        }

        stage('Create and Push Docker Image') {
            when {
                branch 'main' // Only run this stage if the branch is 'main'
            }
            steps {
                script {
                    docker.withRegistry('http://host.docker.internal:8082', 'registry-credentials-id'){
                        def commitSha = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        def imageName = "main/spring-petclinic:${commitSha}"
                        def appImage = docker.build(imageName, '.')
                        appImage.push()
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
