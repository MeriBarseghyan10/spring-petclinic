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
        // Only 'main' branch executes this stage
        stage('Main Docker Build and Push') {
            when {
                branch 'main'
            }
            steps {
                script {
                    def fullImageName = "${REGISTRY_URL}/repository/main/${IMAGE_NAME}:latest"
                    dockerImageBuildAndPush(fullImageName)
                }
            }
        }

        // Other branches execute these stages
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
                echo 'Building...'
                sh 'mvn clean package -DskipTests'
            }
        }

        // All branches except 'main' execute this stage
        stage('MR Docker Build and Push') {
            when {
                not { branch 'main' }
            }
            steps {
                script {
                    def tag = env.GIT_COMMIT.take(7)
                    def fullImageName = "${REGISTRY_URL}/repository/mr/${IMAGE_NAME}:${tag}"
                    dockerImageBuildAndPush(fullImageName)
                }
            }
        }
    }
}

// Define a method for Docker build and push to avoid repetition
def dockerImageBuildAndPush(fullImageName) {
    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'REGISTRY_USER', passwordVariable: 'REGISTRY_PASS')]) {
        sh "docker login ${REGISTRY_URL} --username $REGISTRY_USER --password $REGISTRY_PASS"
        sh "docker build -t ${fullImageName} ."
        sh "docker push ${fullImageName}"
        sh "docker logout ${REGISTRY_URL}" // Logout after pushing the image
    }
}
