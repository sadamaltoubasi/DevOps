pipeline {
    agent any

    // تعريف البارامترات هنا يجعلها تظهر بوضوح في Jenkins UI
    parameters {
        string(name: 'BUILD', defaultValue: '', description: 'Build number from Nexus (e.g., 10)')
        string(name: 'TIME', defaultValue: '', description: 'Timestamp from Nexus (e.g., 20260324-123646)')
    }

    environment {
        // حدد بيانات الـ ECR الخاصة بك هنا
        AWS_REGION     = 'us-east-1'
        AWS_ACCOUNT_ID = '579275327561' // ضع رقم حسابك في AWS هنا
        ECR_REPO_NAME  = 'app01'
        IMAGE_TAG      = "${env.BUILD_ID}"
    }

    stages {
        stage('Ansible Deploy to staging'){
            agent {
                docker { 
                    // استخدام صورة شاملة تحتوي على الـ SSH والـ Python مسبقاً
                    image 'alpine/ansible:latest'
                    args "-u root -v /etc/hosts:/etc/hosts -v ${WORKSPACE}:${WORKSPACE} -w ${WORKSPACE}"
                }
            }

            when {
                // التأكد أن المستخدم أدخل قيم قبل البدء
                expression { params.IMAGE_TAG != ''}
            }
            
            environment {
                NEXUS_SEC_PASS = credentials('nexuspass')
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'applogin', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    sh """
                    # حل مشكلة مسارات أنسيبل للملفات المؤقتة داخل الحاوية
                    export HOME=${WORKSPACE}
                    export ANSIBLE_LOCAL_TEMP=${WORKSPACE}/.ansible/tmp
                    export ANSIBLE_REMOTE_TEMP=/tmp/.ansible/tmp
                    
                    export ANSIBLE_HOST_KEY_CHECKING=False
                    
                    # تأمين ملف مفتاح الـ SSH
                    chmod 400 \${SSH_KEY}
                    
                    # تشغيل الأنسيبل مباشرة (الـ SSH مدعوم تلقائياً هنا)
                    ansible-playbook -i ansible/prod.inventory ansible/app-deploy.yml \
                    --user=\${SSH_USER} \
                    --private-key=\${SSH_KEY} \
                    --extra-vars "image_tag_env=${params.IMAGE_TAG}"
                    """
                }
            }
        }
    }
    
    post {
        always {
            // استخدام تلوين Slack بناءً على النتيجة
            script {
                def color = (currentBuild.currentResult == 'SUCCESS') ? 'good' : 'danger'
                slackSend(
                    channel: '#jenkins-cicd',
                    color: color,
                    message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} [Build: ${params.BUILD}] \nDetails: ${env.BUILD_URL}"
                )
            }
        }
    }
}