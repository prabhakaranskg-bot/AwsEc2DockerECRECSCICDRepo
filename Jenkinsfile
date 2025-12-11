pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-2'
        ECR_REPO           = '493643818608.dkr.ecr.ap-south-2.amazonaws.com/my-springboot-app'
        IMAGE_TAG          = "${env.BUILD_NUMBER}"
        ECS_CLUSTER        = 'springboot-cluster'
        ECS_SERVICE        = 'springboot-taskdef-service-me61gx90'
        CONTAINER_NAME     = 'springboot-container'
        TASK_FAMILY        = 'springboot-taskdef'
        TASK_EXEC_ROLE     = 'ecsTaskExecutionRole' // IAM Role for ECS to pull images from ECR
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
                          extensions: [[$class: 'WipeWorkspace']]
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
                        docker login --username AWS --password-stdin ${ECR_REPO}
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                    docker push ${ECR_REPO}:${IMAGE_TAG}
                    docker tag ${ECR_REPO}:${IMAGE_TAG} ${ECR_REPO}:latest
                    docker push ${ECR_REPO}:latest
                """
            }
        }

        stage('Register ECS Task Definition') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_DEFAULT_REGION}") {
                    script {
                        env.TASK_DEF_ARN = sh(
                            script: """
                                aws ecs register-task-definition \
                                    --family ${TASK_FAMILY} \
                                    --requires-compatibilities FARGATE \
                                    --network-mode awsvpc \
                                    --cpu 256 --memory 512 \
                                    --execution-role-arn arn:aws:iam::493643818608:role/${TASK_EXEC_ROLE} \
                                    --container-definitions '[{
                                        "name": "${CONTAINER_NAME}",
                                        "image": "${ECR_REPO}:${IMAGE_TAG}",
                                        "essential": true,
                                        "portMappings": [{"containerPort": 8080,"hostPort": 8080,"protocol": "tcp"}]
                                    }]' \
                                    --query 'taskDefinition.taskDefinitionArn' \
                                    --output text
                            """,
                            returnStdout: true
                        ).trim()
                        echo "Registered Task Definition ARN: ${env.TASK_DEF_ARN}"
                    }
                }
            }
        }

        stage('Update ECS Service') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_DEFAULT_REGION}") {
                    sh """
                        aws ecs update-service \
                            --cluster ${ECS_CLUSTER} \
                            --service ${ECS_SERVICE} \
                            --task-definition ${TASK_DEF_ARN} \
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
