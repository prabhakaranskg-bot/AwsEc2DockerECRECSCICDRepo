pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-2'
        ECR_REPO           = '493643818608.dkr.ecr.ap-south-2.amazonaws.com/my-springboot-app'
        ECR_REGISTRY       = '493643818608.dkr.ecr.ap-south-2.amazonaws.com'
        IMAGE_TAG          = "${env.BUILD_NUMBER}"
        ECS_CLUSTER        = 'springboot-cluster'
        ECS_SERVICE        = 'springboot-service'
    }

    stages {
        stage('Clean Workspace') {
            steps { deleteDir() }
        }

        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-creds',
                    url: 'https://github.com/prabhakaranskg-bot/AwsEc2DockerECRECSCICDRepo.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Ensure Docker is available
                    sh 'docker --version'

                    // Build Spring Boot Docker image
                    docker.build("${ECR_REPO}:${IMAGE_TAG}", "-f Dockerfile .")
                }
            }
        }

        stage('Install AWS CLI (if missing)') {
            steps {
                script {
                    sh '''
                        if ! command -v aws &> /dev/null
                        then
                            echo "AWS CLI not found, installing..."
                            apt-get update && apt-get install -y awscli
                        else
                            echo "AWS CLI already installed"
                        fi
                    '''
                }
            }
        }

        stage('Login to ECR') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_DEFAULT_REGION}") {
                    sh """
                        aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
                        docker login --username AWS --password-stdin ${ECR_REGISTRY}
                    """
                }
            }
        }

        stage('Push to ECR') {
            steps {
                sh "docker push ${ECR_REPO}:${IMAGE_TAG}"
            }
        }

        stage('Deploy to ECS') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_DEFAULT_REGION}") {
                    sh """
                        aws ecs update-service \
                            --cluster ${ECS_CLUSTER} \
                            --service ${ECS_SERVICE} \
                            --force-new-deployment
                    """
                }
            }
        }
    }

    post {
        success { echo "Deployment Successful: ${ECR_REPO}:${IMAGE_TAG}" }
        failure { echo "Deployment Failed!" }
    }
}
