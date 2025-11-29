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

        stage('Build & Push Docker') {
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding', 
                        credentialsId: 'aws-creds'
                    ]]) {
                        // Docker build
                        docker.build("${ECR_REPO}:${IMAGE_TAG}")

                        // Login to ECR
                        sh """
                        aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
                        docker login --username AWS --password-stdin ${ECR_REPO.split('/')[0]}
                        """

                        // Push Docker image
                        sh "docker push ${ECR_REPO}:${IMAGE_TAG}"

                        // Deploy to ECS
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
            echo "Deployment Successful: ${ECR_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo "Deployment Failed!"
        }
    }
}
