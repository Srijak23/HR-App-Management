pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials-id'   // Replace with your Jenkins DockerHub credentials ID
        DOCKERHUB_USER = 'sreeja026'            // Replace with your DockerHub username
        IMAGE_NAME = "${DOCKERHUB_USER}/hr-app-management"
        IMAGE_TAG = 'latest'
        MONGO_CONTAINER_NAME = 'jenkins-mongo'
        APP_CONTAINER_NAME = 'jenkins-hr-app'
        MONGO_PORT = '27017'
        APP_PORT = '3010'
        DOCKER_NETWORK = 'jenkins-net'
        MONGO_DB_NAME = 'hr_system'                          // Your DB name here
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/Srijak23/HR-App-Management.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                    docker.build("${env.IMAGE_NAME}:${env.IMAGE_TAG}")
                    echo "Docker image build completed."
                }
            }
        }
        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        echo "Logging in to Docker Hub..."
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    }
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "Pushing image ${env.IMAGE_NAME}:${env.IMAGE_TAG} to Docker Hub"
                    docker.image("${env.IMAGE_NAME}:${env.IMAGE_TAG}").push()
                    echo "Docker image pushed successfully."
                }
            }
        }
        stage('Setup Docker Network') {
            steps {
                script {
                    sh "docker network inspect ${env.DOCKER_NETWORK} || docker network create ${env.DOCKER_NETWORK}"
                }
            }
        }
        stage('Run MongoDB Container') {
            steps {
                script {
                    echo "Starting MongoDB container..."
                    sh "docker rm -f ${env.MONGO_CONTAINER_NAME} || true"
                    sh """
                        docker run -d --name ${env.MONGO_CONTAINER_NAME} \
                        --network ${env.DOCKER_NETWORK} \
                        -p ${env.MONGO_PORT}:27017 \
                        mongo:latest
                    """
                    echo "MongoDB container started."
                    sh "sleep 10"
                }
            }
        }
        stage('Run Node.js App Container') {
            steps {
                script {
                    echo "Starting Node.js app container..."
                    sh "docker rm -f ${env.APP_CONTAINER_NAME} || true"
                    sh """
                        docker run -d --name ${env.APP_CONTAINER_NAME} \
                        --network ${env.DOCKER_NETWORK} \
                        -p ${env.APP_PORT}:3000 \
                        -e MONGO_URL=mongodb://${env.MONGO_CONTAINER_NAME}:27017/${env.MONGO_DB_NAME} \
                        ${env.IMAGE_NAME}:${env.IMAGE_TAG}
                    """
                    echo "Node.js app container started."
                }
            }
        }
    }
}
