pipeline {
    agent any

    environment {
        MAIN_REPO_URL = 'http://localhost:8082/repository/main'
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
                    // Define the Docker image name using the Git commit hash
                    def commitSha = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageName = "spring-petclinic:${commitSha}"
                    // Building the Docker image
                    def appImage = docker.build(imageName, '.')
                    // If you still want to push to a registry that doesn't require auth
                    // appImage.push() // Simply push without specifying credentials
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
