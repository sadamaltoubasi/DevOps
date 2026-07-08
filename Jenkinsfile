def COLOR_MAP = [
    'SUCCESS': 'good', 
    'FAILURE': 'danger',
]

pipeline {
    // جعل الـ Agent الافتراضي none لأننا سنحدد لكل Stage الحاوية الخاصة بها
    agent none 
    
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

        BASTION_PUBLIC_IP = '54.227.230.251'
    }

    stages {
        
        // مرحلة الـ Build: تستخدم حاوية مافن الرسمية مع جافا 17
        stage('Build'){
            agent {
                docker { image 'maven:3.9.6-eclipse-temurin-17' }
            }
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo "Now Archiving."
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }

        // مرحلة الـ Test: تستخدم نفس حاوية مافن لضمان تطابق البيئة
        stage('Test'){
            agent {
                docker { image 'maven:3.9.6-eclipse-temurin-17' }
            }
            steps {
                sh 'mvn test'
            }
        }

        // مرحلة الـ Checkstyle
        stage('Checkstyle Analysis'){
            agent {
                docker { image 'maven:3.9.6-eclipse-temurin-17' }
            }
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }


        // مرحلة الـ Sonar: تستخدم حاوية الـ Sonar Scanner الرسمية (بدون الحاجة لعمل tool في جينكينز)

        stage('SonarCloud Analysis') {
            agent {
                docker { 
                  image 'sonarsource/sonar-scanner-cli:latest' 
                  args '-u root --entrypoint='
                }
            }
            steps {
                withCredentials([string(credentialsId: 'sonarcloud', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            sonar-scanner \
                            -Dsonar.organization=jenkans \
                            -Dsonar.projectKey=jenkans_vprofile-project \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=https://sonarcloud.io \
                            -Dsonar.token=$SONAR_TOKEN \
                            -Dsonar.java.binaries=target/classes \
                            -Dsonar.junit.reportsPath=target/surefire-reports/ \
                            -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                            -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml \
                            -Dsonar.exclusions=**/*.js,**/*.ts,**/*.css,**/*.html \
                            -Dsonar.qualitygate.wait=false

                        '''
                    }
                }
            }
        

        stage('Build & Push to ECR') {
            agent {
                docker {
                    image 'docker:stable'
                    // تمرير الـ Docker Socket الخاص بالـ Host لكي نتمكن من تشغيل أوامر docker داخل حاوية الـ aws-cli
                    args '-v /var/run/docker.sock:/var/run/docker.sock -u root'
                }
            }
            environment {
                // حدد بيانات الـ ECR الخاصة بك هنا
                AWS_REGION     = 'us-east-1'
                AWS_ACCOUNT_ID = '579275327561' // ضع رقم حسابك في AWS هنا
                ECR_REPO_NAME  = 'app01'
                IMAGE_TAG      = "${env.BUILD_ID}"
            }
            steps {
                // استخدام الـ Credentials الخاصة بـ AWS والمخزنة في جينكينز
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'awsbeancreds', // معرف الـ Credentials في جينكينز
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh """

                    apk add --no-cache aws-cli
      
                    # 2. عمل Login إلى AWS ECR
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    
                    # 3. بناء الـ Docker Image (ستأخذ ملف الـ .war الجاهز في الـ workspace مباشرة)
                    docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} .
                    
                    # 4. عمل Tag للصورة بالمسار الكامل للـ ECR
                    docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest
                    
                    # 5. رفع الصور (Push) إلى ECR
                    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest

                    docker rmi ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    docker rmi ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest
                    """
                }
            }
        }
        


        // مرحلة الـ Ansible: تستخدم حاوية تحتوي على Ansible مثبت مسبقاً بدلاً من الـ Plugin المحلي
        stage('Ansible Deploy to staging'){
            agent {
                docker { 
                    // استخدام صورة شاملة تحتوي على الـ SSH والـ Python مسبقاً
                    image 'alpine/ansible:latest'
                    args '-u root -v /etc/hosts:/etc/hosts'
                }
            }
            environment {
                NEXUS_SEC_PASS = credentials('nexuspass')
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'bastion_login', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    sh """
                    # حل مشكلة مسارات أنسيبل للملفات المؤقتة داخل الحاوية
                    export HOME=${WORKSPACE}
                    export ANSIBLE_LOCAL_TEMP=${WORKSPACE}/.ansible/tmp
                    export ANSIBLE_REMOTE_TEMP=/tmp/.ansible/tmp
                    
                    export ANSIBLE_HOST_KEY_CHECKING=False
                    
                    # تأمين ملف مفتاح الـ SSH
                    chmod 400 \${SSH_KEY}
                    
                    # تشغيل الأنسيبل مباشرة (الـ SSH مدعوم تلقائياً هنا)
                    ansible-playbook -i ansible/stage.inventory ansible/site.yml \
                    --user=\${SSH_USER} \
                    --private-key=\${SSH_KEY} \
                    --extra-vars "image_tag_env=${env.BUILD_ID} ssh_key_path=\${SSH_KEY}"
                    """
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


// --extra-vars "USER=admin PASS=\${NEXUS_SEC_PASS} nexusip=172.31.40.75 reponame=vprofile-release groupid=QA time=${env.BUILD_TIMESTAMP} build=${env.BUILD_ID} artifactid=vproapp vprofile_version=vproapp-${env.BUILD_ID}-${env.BUILD_TIMESTAMP}.war"
// -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/