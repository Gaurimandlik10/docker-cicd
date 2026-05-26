pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        AWS_DEFAULT_REGION    = 'ap-southeast-2'
        AWS_ACCOUNT_ID        = '500345929326'
        ECR_REPO              = 'devops-project'
        IMAGE_TAG             = 'latest'
        ECR_URL               = "${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-2.amazonaws.com"
    }

    stages {

        stage('Git Checkout') {
            steps {
                echo 'Cloning repository...'
                git branch: 'main',
                    url: 'https://github.com/Gaurimandlik10/docker-cicd.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} ."
            }
        }

        stage('Push to ECR') {
            steps {
                echo 'Pushing to ECR...'
                sh """
                    aws ecr get-login-password \
                        --region ap-southeast-2 | \
                        docker login \
                        --username AWS \
                        --password-stdin ${ECR_URL}

                    docker tag ${ECR_REPO}:${IMAGE_TAG} \
                        ${ECR_URL}/${ECR_REPO}:${IMAGE_TAG}

                    docker push \
                        ${ECR_URL}/${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Terraform Init') {
            steps {
                echo 'Initialising Terraform...'
                sh 'cd terraform && terraform init'
            }
        }

        stage('Terraform Apply') {
            steps {
                echo 'Creating EC2...'
                sh 'cd terraform && terraform apply -auto-approve'
            }
        }

        stage('Get EC2 IP') {
            steps {
                script {
                    EC2_IP = sh(
                        script: 'cd terraform && terraform output -raw ec2_public_ip',
                        returnStdout: true
                    ).trim()
                    echo "EC2 IP: ${EC2_IP}"
                }
            }
        }

        stage('Setup SSH Key') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'newdemo',
                    keyFileVariable: 'SSH_KEY'
                )]) {
                    sh '''
                      cp $SSH_KEY newdemo.pem
                      chmod 400 newdemo.pem
                      '''

                }
            }
        }

        stage('Wait for EC2') {
            steps {
                echo 'Waiting for EC2 to boot...'
                sh 'sleep 30'
            }
        }

        stage('Ansible Deploy') {
            steps {
                echo 'Deploying with Ansible...'
                sh 'cd Ansible && ansible-playbook -i inventory.ini playbook.yml'
            }
        }

        stage('Verify') {
            steps {
                script {
                    sh "curl http://${EC2_IP}"
                    echo "Website live at: http://${EC2_IP} 🎉"
                }
            }
        }
    }

    post {
        success {
            echo '🎉 Complete Pipeline Successful!'
        }
        failure {
            echo '❌ Pipeline Failed!'
        }
        always {
            // Cleanup Docker images
            sh 'docker system prune -f'
        }
    }
}
