pipeline {
    agent any
    tools {
        maven "MAVEN3.9"
        jdk "JDK17"
    }
    
    environment {
        SNAP_REPO = 'vprofile-snapshot'
		NEXUS_USER = 'admin'
		NEXUS_PASS = 'admin'
		RELEASE_REPO = 'vprofile-release'
		CENTRAL_REPO = 'vpro-maven-central'
		NEXUSIP = '172.31.31.0'
		NEXUSPORT = '8081'
		NEXUS_GRP_REPO = 'vpro-maven-group'
        NEXUS_LOGIN = 'nexuslogin'
    }

    stages {
        stage('Build'){
            steps {
                sh 'mvn -s settings.xml -DskipTests install'
            }
            post {
                success {
                    echo 'Build completed successfully.'
                    archiveArtifacts artifacts: '**/*.war'
                }
                failure {
                    echo 'Build failed.'
                }
            }
        }
        stage('Unit Tests'){
            steps {
                sh 'mvn test'
            }
            post {
                success {
                    echo 'All unit tests passed.'
                }
                failure {
                    echo 'Some unit tests failed.'
                }
            }
        }
        stage('Tests'){
            steps {
                sh 'mvn test'
            }
        }
        stage('checkstyle analysis'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }
    }
}