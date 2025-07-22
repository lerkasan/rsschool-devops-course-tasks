pipeline {
    agent { 
        label 'dind' 
    }

    environment {
        GIT_COMMIT_SHA = sh (script: "git log -n 1 --pretty=format:'%H'", returnStdout: true).trim()
        GIT_COMMIT_SHORT_SHA = sh (script: "git rev-parse --short HEAD", returnStdout: true).trim()
        APP_GIT_URL="https://github.com/lerkasan/dummy-flask-app.git"
        IMAGE_NAME = "dummy-flask-app"
        IMAGE_TAG = "${GIT_COMMIT_SHORT_SHA}-${env.BUILD_NUMBER}"
        REGISTRY = "docker.io/lerkasan"
        APP_NAMESPACE = "dummy-flask-app"
        HELM_RELEASE_NAME = "dummy-flask-app"
        SONAR_ORGANIZATION = "lerkasan"
        SONAR_PROJECT_KEY = "lerkasan_dummy-flask-app"
        SONAR_HOST_URL = "https://sonarcloud.io"
        NOTIFICATION_RECIPIENTS = "jenkins.notify.lerkasan@gmail.com"
    }

    stages {
        stage('Checkout') {
            agent { 
                label 'python' 
            }
            steps {
                git url: "${APP_GIT_URL}",
                    credentialsId: 'github',
                    branch: 'main'
            }
        }

        stage('Test') {
            agent { 
                label 'python' 
            }
            steps {
                    sh '''
                    pip3 install -r src/requirements.txt
                    pytest tests/ --doctest-modules --junitxml=test-results.xml
                    coverage run -m pytest
                    coverage xml
                    '''

                    junit 'test-results.xml'

                    withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_TOKEN')]) { 
                    sh '''
                    sonar-scanner -Dsonar.organization="${SONAR_ORGANIZATION}" \
                                  -Dsonar.projectKey="${SONAR_PROJECT_KEY}" \
                                  -Dsonar.sources=./src \
                                  -Dsonar.host.url=${SONAR_HOST_URL} \
                                  -Dsonar.login="${SONAR_TOKEN}" \
                                  -Dsonar.qualitygate.wait=true
                    '''
                }
            }    

        }    

        stage('Build Docker Image') {
            steps {
                // Adding sleep to ensure Docker Daemon is ready in dind container
                sh 'sleep 10'
                sh 'docker build -t "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}" ./src'
            }
        }

        stage('Push Docker Image') {
            steps {
                // Adding sleep to ensure Docker Daemon is ready in dind container
                sh 'sleep 10'
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub', 
                        usernameVariable: 'REGISTRY_USERNAME', 
                        passwordVariable: 'REGISTRY_PASSWORD'
                )]) {
                    sh '''
                    echo "${REGISTRY_PASSWORD}" | docker login -u "${REGISTRY_USERNAME}" --password-stdin
                    docker push "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
                    '''
                }

                script {
                    image_sha = sh(script: 'docker inspect --format="{{index .RepoDigests 0}}" "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}" | cut -d "@" -f 2', 
                                   returnStdout: true).trim()
                }
            }
        }

        stage('Publish Helm Chart') {
            agent { 
                label 'python' 
            }
            environment {
                IMAGE_SHA = "${image_sha}"
            }
            steps {
                withCredentials([
                usernamePassword(
                  credentialsId: 'dockerhub',
                  usernameVariable: 'REGISTRY_USERNAME', 
                  passwordVariable: 'REGISTRY_PASSWORD'
                )
              ]) {  
                    sh '''
                    echo "${REGISTRY_PASSWORD}" | helm registry login registry-1.docker.io -u "${REGISTRY_USERNAME}" --password-stdin
                    helm package ./chart/
                    helm push "$(yq -r .name ./chart/Chart.yaml)-$(yq -r .version ./chart/Chart.yaml).tgz" "oci://registry-1.docker.io/${REGISTRY_USERNAME}"
                    '''
                }    
            }
        }   

        stage('Deploy') {
            agent { 
                label 'python' 
            }
            environment {
                IMAGE_SHA = "${image_sha}"
            }
            steps {
                withCredentials([
                usernamePassword(
                  credentialsId: 'dockerhub',
                  usernameVariable: 'REGISTRY_USERNAME', 
                  passwordVariable: 'REGISTRY_PASSWORD'
                )
              ]) {  
                    // https://polarsquad.com/blog/check-your-helm-deployments
                    sh '''
                    helm upgrade --install \
                                 --atomic --timeout 300s \
                                 --set image.tag="${IMAGE_TAG}" \
                                 --set image.sha256="${IMAGE_SHA}" \
                                 --create-namespace --namespace "${APP_NAMESPACE}" \
                                 -f ./chart/values.yaml "${HELM_RELEASE_NAME}" ./chart
                    '''
                }    
            }
        }

        stage('Health Check') {
            agent { 
                label 'python' 
            }

            steps { 
                sh '''
                wget --no-verbose \
                     --tries=5 \
                     --timeout=10 \
                     --spider \
                     "http://${HELM_RELEASE_NAME}-$(yq -r .name ./chart/Chart.yaml).${APP_NAMESPACE}.svc.cluster.local:8080/" || exit 1
                '''
            }
        }               
    }

    post {
        always {
            emailext(
                subject: "${env.JOB_BASE_NAME} - Build #${env.BUILD_NUMBER} - ${currentBuild.currentResult}",     
                to: "${NOTIFICATION_RECIPIENTS}",                                                                         
                body: "The build #${env.BUILD_NUMBER} for ${env.JOB_BASE_NAME} finished with status ${currentBuild.currentResult}. Check console output at ${env.BUILD_URL} to view the results."                
            )

            cleanWs()
        }
    }  
}
