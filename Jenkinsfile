pipeline {
    agent any

    environment {
        // Defining repository URLs for Docker images
        MAIN_REPO_URL = 'http://localhost:8082/repository/main'
        MR_REPO_URL = 'http://localhost:8083/repository/mr'
    }

    stages {
        stage('Maven Install or Prepare') {
            agent {
                docker {
                    image 'maven:3.8.4'
                    args '-v /root/.m2:/root/.m2' // Enables Maven cache between runs
                }
            }
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        echo 'Preparing project for main branch (Skipping Tests)...'
                        sh 'mvn clean install -DskipTests'
                    } else {
                        echo 'Running full Maven install including tests for branch: ${env.BRANCH_NAME}'
                        sh 'mvn clean install'
                    }
                }
            }
        }

        stage('Checkstyle') {
            when {
                not { branch 'main' } // Execute for branches other than 'main'
            }
            agent {
                docker {
                    image 'maven:3.8.4'
                }
            }
            steps {
                echo 'Running Checkstyle analysis...'
                sh 'mvn checkstyle:checkstyle'
                archiveArtifacts artifacts: '**/target/checkstyle-result.xml', fingerprint: true
            }
        }

        stage('Test') {
            when {
                not { branch 'main' } // Execute for branches other than 'main'
            }
            agent {
                docker {
                    image 'maven:3.8.4'
                }
            }
            steps {
                echo 'Running tests...'
                sh 'mvn test'
            }
        }

        // This stage is merged with the "Maven Install or Prepare" stage
        // Consider adding any branch-specific build steps here if needed

        stage('Create and Push Docker Image') {
            agent {
                docker {
                  
                    image 'docker:19.03'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                script {
                    def commitSha = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageName = "spring-petclinic:${commitSha}"
                    def appImage
                    if (env.BRANCH_NAME == 'main') {
                        appImage = docker.build("${MAIN_REPO_URL}/${imageName}", '.')
                    } else {
                        appImage = docker.build("${MR_REPO_URL}/${imageName}", '.')
                    }
                    appImage.push()
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            // Optionally, clean up Maven artifacts, Docker images, etc.
        }
    }
}
