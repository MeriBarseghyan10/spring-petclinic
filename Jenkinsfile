pipeline {
    agent any

    tools {
        maven 'Maven' 
    }

    environment {
        //Created Docker registry credentials ID
        DOCKER_CREDENTIALS_ID = 'f1754fdb-84a3-4fcf-bb62-8cac10496521'
        // Nexus Docker registry URL
        REGISTRY_URL = 'http://localhost:8082'
        // Docker image name
        IMAGE_NAME = 'spring-petclinic'
    }

    stages {
        stage('Preparation') {
            steps {
                echo 'Preparing the environment...'
                script {
                    // This can include initial steps like cloning the repo if not automatically handled by Jenkins
                }
            }
        }

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

        stage('Docker Build and Push') {
            steps {
                script {
                    def branchName = env.BRANCH_NAME
                    def tag = branchName == 'main' ? 'latest' : env.GIT_COMMIT.take(7)
                    def repositoryPath = branchName == 'main' ? 'main' : 'mr'
                    def fullImageName = "${REGISTRY_URL}/repository/${repositoryPath}/${IMAGE_NAME}:${tag}"

                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'REGISTRY_USER', passwordVariable: 'REGISTRY_PASS')]) {
                        sh "docker login ${REGISTRY_URL} --username $REGISTRY_USER --password $REGISTRY_PASS"
                        sh "docker build -t ${fullImageName} ."
                        sh "docker push ${fullImageName}"
                    }
                }
            }
        }
    }
}
