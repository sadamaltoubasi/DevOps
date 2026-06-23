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
        AWS_S3_BUCKET = 'sadambean'
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
                // ﺎﺴﺘﺧﺩﺎﻣ ﺎﻠـ Credentials ﺎﻠﻤﺴﺠﻟﺓ ﻒﻳ ﺞﻴﻨﻜﻴﻧﺯ ﻞﻟﻮﺻﻮﻟ ﺈﻟﻯ AWS
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'awsbeancreds', // ﺾﻋ ﺎﻠـ ID ﺎﻠﺧﺎﺻ ﺐﺒﻳﺎﻧﺎﺗ AWS ﻪﻧﺍ
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {

                    script {
                        def artifactVersion = "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}"
                        def s3Key = "vprofile-v2-${artifactVersion}.war"

                        // 1. ﺮﻔﻋ ﻢﻠﻓ ﺎﻠـ WAR ﺈﻟﻯ S3 (ﺢﻴﺛ ﻲﺤﺗﺎﺟ Beanstalk ﻞﻗﺭﺍﺀﺓ ﺎﻠﻤﻠﻓ ﻢﻧ ﻪﻧﺎﻛ)
                        sh "aws s3 cp target/vprofile-v2.war s3://${AWS_S3_BUCKET}/${s3Key} --region ${AWS_REGION}"

                        // 2. ﺈﻨﺷﺍﺀ ﻦﺴﺧﺓ ﺖﻄﺒﻴﻗ ﺝﺪﻳﺩﺓ (Application Version) ﻒﻳ Beanstalk ﻡﺮﺘﺒﻃﺓ ﺐﻤﻠﻓ ﺎﻠـ S3
                        sh """aws elasticbeanstalk create-application-version \
                            --application-name "${AWS_APP_NAME}" \
                            --version-label "${artifactVersion}" \
                            --source-bundle S3Bucket="${AWS_S3_BUCKET}",S3Key="${s3Key}" \
                            --region ${AWS_REGION}"""

                        // 3. ﺖﺣﺪﻴﺛ ﺎﻠﺒﻴﺋﺓ (Environment) ﻞﺘﻌﻤﻟ ﺏﺎﻠﻨﺴﺧﺓ ﺎﻠﺟﺪﻳﺩﺓ
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