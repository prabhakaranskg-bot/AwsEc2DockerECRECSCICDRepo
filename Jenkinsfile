pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AKIAXF33W4ZYDP47QKUD')  //change
        AWS_SECRET_ACCESS_KEY = credentials('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')  //change
        AWS_DEFAULT_REGION    = 'ap-south-2'  //change

        ECR_REPO      = '493643818608.dkr.ecr.ap-south-2.amazonaws.com/my-springboot-app:latest' //change
        IMAGE_TAG     = "${env.BUILD_NUMBER}"
        ECS_CLUSTER   = 'springboot-cluster'  // Change
        ECS_SERVICE   = 'springboot-service'  // Change
    }

  }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/prabhakaranskg-bot/AwsEc2DockerECRECSCICDRepo.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${ECR_REPO}:${IMAGE_TAG}")
                }
            }
        }

        stage('Login to ECR') {
            steps {
                script {
                    sh """
                    aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REPO.split('/')[0]}
                    """
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    sh "docker push ${ECR_REPO}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                script {
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
        success {
            echo "Deployment Successful: ${ECR_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo "Deployment Failed!"
        }
    }
}