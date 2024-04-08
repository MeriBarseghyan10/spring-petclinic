pipeline {
    agent any

    environment {
        // Define repository URLs
        MAIN_REPO_URL = 'http://localhost:8082/repository/main'
        MR_REPO_URL = 'http://localhost:8083/repository/mr'
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
            steps {
                script {
                    def commitSha = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageName = "spring-petclinic:${commitSha}"
                    def appImage
                    if (env.BRANCH_NAME == 'main') {
                        appImage = docker.build("${MAIN_REPO_URL}/${imageName}", '.')
                        appImage.push()
                    } else {
                        appImage = docker.build("${MR_REPO_URL}/${imageName}", '.')
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
