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

        AWS_APP_NAME = 'vpro-app'
        AWS_S3_BUCKET = 'sadam-bean'
        AWS_REGION = 'us-east-1'
        AWS_ENV_NAME = 'Vpro-app-env'
    }

    stages {

        stage('BUILD') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo 'Now Archiving...'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }

        stage('UNIT TEST') {
            steps {
                sh 'mvn test'
            }
        }

        stage('INTEGRATION TEST') {
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }

        stage('CHECKSTYLE') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }

        stage('SONARQUBE ANALYSIS') {
            environment {
                scannerHome = tool 'sonarscanner'
            }
            steps {
                withSonarQubeEnv('sonarserver') {
                    sh """${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                        -Dsonar.projectName=vprofile-repo \
                        -Dsonar.projectVersion=1.0 \
                        -Dsonar.sources=src/ \
                        -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                        -Dsonar.junit.reportsPath=target/surefire-reports/ \
                        -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml"""
                }
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('UploadArtifact') {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: "${NEXUSIP}:${NEXUSPORT}",
                    groupId: 'QA',
                    version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                    repository: "${RELEASE_REPO}",
                    credentialsId: "${NEXUS_LOGIN}",
                    artifacts: [
                        [artifactId: 'vproapp',
                         classifier: '',
                         file: 'target/vprofile-v2.war',
                         type: 'war']
                    ]
                )
            }
        }

        stage('DEPLOY TO BEANSTALK') {
            steps {
                // استخدام الـ Credentials المسجلة في جينكينز للوصول إلى AWS
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'awsbeancreds', // ضع الـ ID الخاص ببيانات AWS هنا
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    
                    script {
                        def artifactVersion = "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}"
                        def s3Key = "vprofile-v2-${artifactVersion}.war"
                        
                        // 1. رفع ملف الـ WAR إلى S3 (حيث يحتاج Beanstalk لقراءة الملف من هناك)
                        sh "aws s3 cp target/vprofile-v2.war s3://${AWS_S3_BUCKET}/${s3Key} --region ${AWS_REGION}"
                        
                        // 2. إنشاء نسخة تطبيق جديدة (Application Version) في Beanstalk مرتبطة بملف الـ S3
                        sh """aws elasticbeanstalk create-application-version \
                            --application-name "${AWS_APP_NAME}" \
                            --version-label "${artifactVersion}" \
                            --source-bundle S3Bucket="${AWS_S3_BUCKET}",S3Key="${s3Key}" \
                            --region ${AWS_REGION}"""
                        
                        // 3. تحديث البيئة (Environment) لتعمل بالنسخة الجديدة
                        sh """aws elasticbeanstalk update-environment \
                            --environment-name "${AWS_ENV_NAME}" \
                            --version-label "${artifactVersion}" \
                            --region ${AWS_REGION}"""
                    }
                }
            }
        }
    }


}
