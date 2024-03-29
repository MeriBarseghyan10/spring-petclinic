pipeline {
    agent any
    
    stages {
        stage('Checkstyle') {
            when {
                branch 'main'
            }
            steps {
                script {
                    if (fileExists('pom.xml')) {
                        sh 'mvn checkstyle:checkstyle'
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: '**/target/checkstyle-result.xml', allowEmptyArchive: true
                }
            }
        }
        stage('Test') {
            when {
                branch 'main'
            }
            steps {
                script {
                    if (fileExists('pom.xml')) {
                        sh 'mvn test'
                    }
                }
            }
        }
        stage('Build without Tests') {
            when {
                branch 'main'
            }
            steps {
                script {
                    if (fileExists('pom.xml')) {
                        sh 'mvn clean package -DskipTests'
                    }
                }
            }
        }
        stage('Docker Build and Push') {
            when {
                branch 'main'
            }
            steps {
                script {
                    def commitHash = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    def imageName = "http://localhost:8082/repository/maven-central:${commitHash}"
                    sh "docker build -f Dockerfile -t ${imageName} ."
                    sh "docker push ${imageName}"
                }
            }
        }
        stage('Main Docker Build and Push') {
            when {
                branch 'main'
            }
            steps {
                script {
                    def imageName = "http://localhost:8082/repository/main:latest"
                    sh "docker build -f Dockerfile -t ${imageName} ."
                    sh "docker push ${imageName}"
                }
            }
        }
    }
}
