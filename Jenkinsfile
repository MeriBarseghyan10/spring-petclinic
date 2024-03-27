pipeline {
    agent any
    
    stages {
        stage('Checkstyle') {
            steps {
                script {
                    if (fileExists('pom.xml')) {
                        sh 'mvn checkstyle:checkstyle'
                    } else if (fileExists('build.gradle')) {
                        sh 'gradle checkstyleMain'
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
            steps {
                script {
                    if (fileExists('pom.xml')) {
                        sh 'mvn test'
                    } else if (fileExists('build.gradle')) {
                        sh 'gradle test'
                    }
                }
            }
        }
        stage('Build without Tests') {
            steps {
                script {
                    if (fileExists('pom.xml')) {
                        sh 'mvn clean package -DskipTests'
                    } else if (fileExists('build.gradle')) {
                        sh 'gradle assemble'
                    }
                }
            }
        }
      stage('Docker Build and Push') {
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
