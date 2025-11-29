pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-2'
        ECR_REPO = '493643818608.dkr.ecr.ap-south-2.amazonaws.com/my-springboot-app'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        ECS_CLUSTER = 'springboot-cluster'
        ECS_SERVICE = 'springboot-service'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-creds',
                    url: 'https://github.com/prabhakaranskg-bot/AwsEc2DockerECRECSCICDRepo.git'
            }
        }

        stage('ECR Login') {
            steps {
                script {
                    def ecrRegistry = ECR_REPO.tokenize('/')[0]
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                        sh """
                        echo 'Logging in to AWS ECR...'
                        aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
                        docker login --username AWS --password-stdin ${ecrRegistry}
                        """
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker image...'
                    sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    echo 'Pushing Docker image to ECR...'
                    sh "docker push ${ECR_REPO}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                        echo 'Deploying to ECS...'
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
    }

    post {
        success {
            echo "✅ Deployment Successful: ${ECR_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Deployment Failed!"
        }
    }
}
