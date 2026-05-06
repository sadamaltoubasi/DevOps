def COLOR_MAP = [
    'SUCCESS': 'good', 
    'FAILURE': 'danger',
]
pipeline {
    agent any
    tools {
        maven "MAVEN"
        jdk "JDK17"
    }
    
    environment {
        SNAP_REPO = 'vprofile-snapshot'
		NEXUS_USER = 'admin'
		NEXUS_PASS = 'admin123'
		RELEASE_REPO = 'vprofile-release'
		CENTRAL_REPO = 'vpro-maven-central'
		NEXUSIP = '172.31.40.75'
		NEXUSPORT = '8081'
		NEXUS_GRP_REPO = 'vpro-maven-group'
        NEXUS_LOGIN = 'nexuslogin'
        SONARSERVER = 'sonarserver'
        SONARSCANNER = 'sonarscanner'
        NEXUSPASS = credentials('nexuspass')
        ARTIFACT_NAME = "vprofile-v${BUILD_ID}.war"
        AWS_S3_BUCKET = 'sadambean'
        AWS_EB_APP_NAME = 'vproapp'
        AWS_EB_ENVIRONMENT = 'Vproapp-env-1'
        AWS_EB_APP_VERSION = "${BUILD_ID}"

        AWS_ACCOUNT_ID = '579275327561'
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
        DB_IMAGE = "${ECR_URL}/db01"
        APP_IMAGE = "${ECR_URL}/app-bean"
    }

    stages {
        stage('Build'){
            steps {
                sh 'mvn -s settings.xml -DskipTests install'
            }
            post {
                success {
                    echo "Now Archiving."
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }

        stage('Test'){
            steps {
                sh 'mvn -s settings.xml test'
            }

        }

        stage('Checkstyle Analysis'){
            steps {
                sh 'mvn -s settings.xml checkstyle:checkstyle'
            }
        }

        stage('Sonar Analysis') {
            environment {
                scannerHome = tool "${SONARSCANNER}"
            }
            steps {
               withSonarQubeEnv("${SONARSERVER}") {
                   sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                   -Dsonar.projectName=vprofile \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
              }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                    // true = set pipeline to UNSTABLE, false = don't
                    waitForQualityGate abortPipeline: false
                }
            }
        }


stage('Deploy to Stage Bean'){
    steps {
        withAWS(credentials: 'awsbeancreds', region: 'us-east-1') {
            // حل المشكلة: نضع المتغير داخل بلوك script
            script {
                def AWS_EB_APP_VERSION = "vpro-${BUILD_ID}"
                def s3Key = "vpro-v${BUILD_ID}.war"
                
                sh "aws s3 cp ./target/vprofile-v2.war s3://${AWS_S3_BUCKET}/${s3Key}"
                
                sh """
                    aws elasticbeanstalk create-application-version \
                    --application-name ${AWS_EB_APP_NAME} \
                    --version-label ${AWS_EB_APP_VERSION} \
                    --source-bundle S3Bucket=${AWS_S3_BUCKET},S3Key=${s3Key}
                """

                sh "aws elasticbeanstalk update-environment --application-name ${AWS_EB_APP_NAME} --environment-name ${AWS_EB_ENVIRONMENT} --version-label ${AWS_EB_APP_VERSION}"
            }
        }
    }
}

    }
    post {
        always {
            echo 'Slack Notifications.'
            slackSend channel: '#jenkins-cicd',
                color: COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }
}