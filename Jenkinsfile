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
        AWS_EB_APP_NAME = 'vproapp-1'
        AWS_EB_ENVIRONMENT = 'Vproapp-1-env-1'
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


stage('Docker Build & Push to ECR') {
    steps {
        script {
            withAWS(credentials: 'awsbeancreds', region: 'us-east-1') {
                // 1. تسجيل الدخول لـ ECR
                sh "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ECR_URL}"
                
                // 2. معالجة صورة قاعدة البيانات (DB)
                // بناء الصورة بالوسم الجديد
                sh "docker build -t ${DB_IMAGE}:${BUILD_ID} ./db"
                // إعطاء الصورة وسم latest إضافي
                sh "docker tag ${DB_IMAGE}:${BUILD_ID} ${DB_IMAGE}:latest"
                // دفع النسختين (الرقم و latest)
                sh "docker push ${DB_IMAGE}:${BUILD_ID}"
                sh "docker push ${DB_IMAGE}:latest"
                
                // 3. معالجة صورة التطبيق (App)
                sh "docker build -t ${APP_IMAGE}:${BUILD_ID} ./app"
                sh "docker tag ${APP_IMAGE}:${BUILD_ID} ${APP_IMAGE}:latest"
                sh "docker push ${APP_IMAGE}:${BUILD_ID}"
                sh "docker push ${APP_IMAGE}:latest"
            }
        }
    }
}

stage('Deploy to Stage Bean'){
    steps {
        withAWS(credentials: 'awsbeancreds', region: 'us-east-1') {
            // 1. رفع ملف الـ JSON كما هو (لأننا نعتمد على latest بالداخل)
            sh "aws s3 cp ./compose.yml s3://${AWS_S3_BUCKET}/vpro-v${BUILD_ID}.yml"
            
    
            // تحديث أمر إنشاء نسخة التطبيق ليشير لملف الـ YAML
            sh "aws elasticbeanstalk create-application-version --application-name ${AWS_EB_APP_NAME} --version-label ${AWS_EB_APP_VERSION} --source-bundle S3Bucket=${AWS_S3_BUCKET},S3Key=vpro-v${BUILD_ID}.yml"

            sh "aws elasticbeanstalk update-environment --application-name ${AWS_EB_APP_NAME} --environment-name ${AWS_EB_ENVIRONMENT} --version-label ${AWS_EB_APP_VERSION}"
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