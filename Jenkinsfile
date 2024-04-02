pipeline {
    agent any

    environment {
        // Defining main repository URL using host.docker.internal for Docker-in-Docker communication
        MAIN_REPO_URL = 'http://host.docker.internal:8082/repository/main'
    }

    stages {
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
                    // Use the MAIN_REPO_URL from the environment variable
                    docker.withRegistry("${env.MAIN_REPO_URL}", 'DOCKER_CREDENTIALS_ID') {
                        def commitSha = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        def imageName = "spring-petclinic:${commitSha}"
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
