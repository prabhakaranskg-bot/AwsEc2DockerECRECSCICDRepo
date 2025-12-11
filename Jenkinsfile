pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-2'
        ECR_REPO           = '493643818608.dkr.ecr.ap-south-2.amazonaws.com/my-springboot-app'
        ECR_REGISTRY       = '493643818608.dkr.ecr.ap-south-2.amazonaws.com'
        IMAGE_TAG          = "${env.BUILD_NUMBER}"
        ECS_CLUSTER        = 'springboot-cluster'
        ECS_SERVICE        = 'springboot-taskdef-service-me61gx90'
    }

    stages {
        stage('Clean Workspace') {
            steps { deleteDir() }
        }

        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: '*/main']],
                          userRemoteConfigs: [[
                              url: 'https://github.com/prabhakaranskg-bot/AwsEc2DockerECRECSCICDRepo.git',
                              credentialsId: 'github-creds'
                          ]],
                          extensions: [[$class: 'WipeWorkspace']] // Ensures old files are removed
                ])
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
                            --task-definition springboot-taskdef:2 \
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
