pipeline {
    agent any

    tools {
        maven 'Maven'
    }

    environment {
        DOCKER_CREDENTIALS_ID = 'f1754fdb-84a3-4fcf-bb62-8cac10496521'
        REGISTRY_URL = 'http://localhost:8082'
        IMAGE_NAME = 'spring-petclinic'
    }

    stages {
        // The 'main' branch will only execute this stage
        stage('Main Docker Build and Push') {
            when {
                branch 'main'
            }
            steps {
                echo 'Building and pushing Docker image for main...'
                script {
                    dockerBuildAndPush('latest', 'main')
                }
            }
        }

        // Non-main branches will execute these stages
        stage('Checkstyle') {
            when {
                not { branch 'main' }
            }
            steps {
                echo 'Running Checkstyle...'
                sh 'mvn checkstyle:checkstyle'
                archiveArtifacts artifacts: '**/target/checkstyle-result.xml', allowEmptyArchive: true
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

        stage('Build without Tests') {
            when {
                not { branch 'main' }
            }
            steps {
                echo 'Building without running tests...'
                sh 'mvn clean package -DskipTests'
            }
        }

        // Non-main branches will execute this stage
        stage('MR Docker Build and Push') {
            when {
                not { branch 'main' }
            }
            steps {
                echo 'Building and pushing Docker image for MR...'
                script {
                    def shortCommit = env.GIT_COMMIT.take(7)
                    dockerBuildAndPush(shortCommit, 'mr')
                }
            }
        }
    }
}

// Define a method for Docker build and push to avoid repetition
def dockerBuildAndPush(String tag, String repo) {
    def fullImageName = "${REGISTRY_URL}/repository/${repo}/${IMAGE_NAME}:${tag}"
    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'REGISTRY_USER', passwordVariable: 'REGISTRY_PASS')]) {
        sh "docker login ${REGISTRY_URL} --username $REGISTRY_USER --password $REGISTRY_PASS"
        sh "docker build -t ${fullImageName} ."
        sh "docker push ${fullImageName}"
        sh "docker logout ${REGISTRY_URL}"
    }
}
