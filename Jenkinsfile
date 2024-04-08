pipeline {
    agent any

    environment {
        // Defining main repository URL using host.docker.internal for Docker-in-Docker communication
        MAIN_REPO_URL = 'http://host.docker.internal:8082/repository/main' // It's recommended to use HTTPS instead of HTTP for security
    }

    stages {
        stage('Maven Install') {
            agent {
                docker {
                    image 'maven:3.8.4'
                }
            }
            steps {
                sh 'mvn clean install'
            }
        }
        
        stage('Checkstyle') {
            when {
                not { branch 'main' } // Only run this stage if the branch is not 'main'
            }
            steps {
                echo 'Running Checkstyle analysis...'
                sh 'mvn checkstyle:checkstyle'
                archiveArtifacts artifacts: '**/target/checkstyle-result.xml', fingerprint: true
            }
        }

        stage('Test') {
            when {
                not { branch 'main' } // Only run this stage if the branch is not 'main'
            }
            steps {
                echo 'Running tests...'
                sh 'mvn test'
            }
        }

        stage('Build') {
            when {
                not { branch 'main' } // Only run this stage if the branch is not 'main'
            }
            steps {
                echo 'Building project (without tests)...'
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Create and Push Docker Image') {
            when {
                branch 'main' // Only run this stage if the branch is 'main'
            }
            steps {
                script {
                    def commitSha = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageName = "main/spring-petclinic:${commitSha}"
                    def appImage = docker.build(imageName, '.')
                    appImage.push("${imageName}")
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
