pipeline {

    agent any
    stages {
        stage('Clone repository') { 
            steps { 
                    git url:'git@github.com:Wikingst13/Project_WP.git'
					
					}
        }

        stage('Checks Docker-compose file') {
            steps {
                sh '''
                    docker-compose config
                '''
            }
        }
        
        stage('UP with Docker-compose') {
            steps {
                sh '''
                    docker-compose up -d
                '''
            }
        }

        stage("Wait prior starting testing") {
            steps {
                sleep(time:15,unit:"SECONDS")
            }
        }    

        stage('Checking start page') {
            steps {
                sh '''
                    lynx -dump  ec2-35-158-2-219.eu-central-1.compute.amazonaws.com:80
                '''
            }
        }
	    stage('Stopping Docker containers') {
            steps {
                sh 'docker ps -q | xargs --no-run-if-empty docker container stop'
            }
        }

        stage('Removing Docker images') {
          steps{
            sh 'docker container ls -a -q | xargs -r docker container rm'
          }
        }
        
        

        
    }

    post {
            success {
                slackSend (color: '#00FF00', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
            }
            failure {
                slackSend (color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
            }
        }
}