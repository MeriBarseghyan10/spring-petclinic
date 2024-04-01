pipeline {
    agent any

    environment {
        MAIN_REPO_URL = 'http://localhost:8082/repository/main'
        MR_REPO_URL = 'http://localhost:8082/repository/mr'
        DOCKER_CREDENTIALS_ID = '1111' // The ID of Docker registry credentials in Jenkins
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
                    def shortGitCommit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageName = "spring-petclinic:${shortGitCommit}"
                    def repositoryUrl = env.MAIN_REPO_URL

                    docker.withRegistry('', env.DOCKER_CREDENTIALS_ID) {
                        sh "docker build -t ${imageName} ."
                        sh "docker tag ${imageName} ${repositoryUrl}/${imageName}"
                        sh "docker push ${repositoryUrl}/${imageName}"
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
