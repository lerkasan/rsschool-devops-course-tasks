## TASK 7

### Prerequisites

- Terraform
- Kubectl
- Helm v.3.x
- Virtualbox
- Minikube
- Docker

### Installation

1. Create minikube cluster:

    `minikube start --driver=virtualbox --cpus=8 --memory=8g`

2. Enable storage class and provisioner

    ```
    minikube addons enable default-storageclass
    minikube addons enable storage-provisioner
    minikube addons enable metrics-server
    ```

3. Check the status of the minikube cluster and its nodes

    `minikube status`

    `kubectl get nodes`

4. Move to the folder `monitoring/iac`
    `cd monitoring/iac`

5. Run terrafrom commands to automatically provision and configure Prometheus, Grafana and Alertmanager
    ```
    terraform init
    terraform apply
    ```

**Clean up**
1. Uninstall Prometheus, Grafana and Alertmanager via terraform

    `terraform destroy`

2. Stop minikube cluster

    `minikube stop`

3. *Optional:* Delete minikube cluster


    `minikube delete`    
______________________________________________________________________________


## TASK 6

### Prerequisites

- Kubectl
- Helm v.3.x
- Virtualbox
- Minikube
- Docker

- Accounts at GitHub, DockerHub and Personal Access Tokens (PAT):
  - GitHub - token for read only access rights
  - DockerHub - token for read/write access rights
- Self hosted SonarQube or an account on SonarQube SaaS https://sonarcloud.io/ with access token
- SMTP credentials (username, password and configuration settings) to send email notifications from Jenkins

### Objective

The objective of the **Task 6** is to write `Jenkinsfile` pipeline to build and deploy the `dummy-flask-app` to Kubernetes cluster (in our case, Minikube) and configure Jenkins server as needed to run this pipeline.

**Steps**

1. **Configure Jenkins Pipeline**

   - Create a Jenkins pipeline and store it as a Jenkinsfile in your git repository.
   - Configure the pipeline to be triggered on each push event to the repository.

2. **Pipeline Steps**

   - The pipeline should include the following steps:
     1. Application build
     2. Unit test execution
     3. Security check with SonarQube
     4. Docker image building and pushing to any Registry
     5. Deployment to the K8s cluster with Helm (dependent on the previous step)
     6. (Optional) Application verification (e.g., curl the main page, send requests to API, smoke test)

3. **Application verification**
   - Ensure that the pipeline runs successfully and deploys the application to the K8s cluster.
4. **Additional Tasks**
   - Set up a notification system to alert on pipeline failures or successes.
   - Document the pipeline setup and deployment process in a README file.


**Review**

`Jenkinsfile` pipeline is located in `flask_app` folder of this GitHub repository. Also, I created a separate GitHub repository `lerkasan/dummy-flask-app`. That repository contains source code for the dummy flask aplication, a dummy test, Dockerfile and Jenkinsfile. The content of 
`lerkasan/dummy-flask-app` GitHub repository is the same as files in `flask_app` folder of this GitHub repository. It is considered a best practice to have separate repositories for: 
 - application source code
 - infrastructure source code

After the installation of Jenkins via Helm chart, Jenkins will have a pipeline job called `dummy-flask-app` already automatically created from `Jenkinsfile` during the initialization via Jenkins Configuration as Code (JCasC). You don't need to change anything. This pipeline job is configured to checkout code from `lerkasan/dummy-flask-app` repository on GitHub. That repository contains source code for the dummy flask aplication, Dockerfile and Jenkinsfile.

Here is the example of JCasC value in `jenkins/manifests/jenkins-minikube-prep-for-helm-chart/jenkins-values.yaml` to automatically create a pipeline job: 

```
  JCasC:
    defaultConfig: true
    configScripts:
      jcasc-configs: |
        jobs:
          - script: >
              pipelineJob('dummy-flask-app') {
                triggers {
                  scm('H/5 * * * *')
                }
                definition {
                  cpsScm {
                    scm {
                      git {
                        remote {
                          url('https://github.com/lerkasan/dummy-flask-app.git')
                          credentials('github')
                        }
                        branch('*/main')
                      }
                    }
                    lightweight()
                  }
                }
              } 
```

I use a local installation of the Minikube cluster without external access. Obviously, my local Jenkins installation doesn't have  a location URL, that can be accessed from outside by GitHub (push approach, configured on GitHub) to trigger a new build in Jenkins on each new commit to the GitHub repository. Consequently, I had to use pull approach configured in Jenkins - a scheduled polling of SCM every 5 minutes by Jenkins to check if there are any new commits and trigger a new build.


The `Jenkinsfile` pipeline has following stages of building and deploying `dummy-flask-app` application:
- Checkout
- Test (includes steps for testing and scanning with sonar-scanner for SonarQube report)
- Build Docker Image
- Push Docker Image to DockerHub
- Publish Helm Chart to DockerHub
- Deploy
- Health Check
- Additional Post stage, that automates sending email notifications about the status of the current build and cleaning the workspace after the build in finished.

As I mentioned before, I use a local installation of the Minikube cluster without external access. Therefore, for the heath check purposes of the deployed application I selected a FQDN of the application service in the cluster. 

Example of FQDN of a service in a Kubernetes cluster:
`<SERVICE_NAME>.<NAMESPACE_NAME>.svc.cluster.local`

In the `service.yaml` template of the `dummy-flask-app` Helm chart I configured service name to be `name: {{ .Release.Name }}-{{ .Chart.Name }}`. Thus, the FQDN of the service for the `dummy-flask-app` is `<HELM_RELEASE_NAME>-<HELM_CHART_NAME>.<NAMESPACE_NAME>.svc.cluster.local` and health check URL is `http://dummy-flask-app-dummy-flask-app.dummy-flask-app.svc.cluster.local:8080` 


### Installation

0. We need a minikube cluster that was created the same way as during Task 4, so for convinience let's repeat those steps below. All **Jenkins** related confguration was moved to `jenkins` folder.

1. Create minikube cluster:

    `minikube start --driver=virtualbox --cpus=8 --memory=8g`

2. Enable storage class and provisioner

    `minikube addons enable default-storageclass`

    `minikube addons enable storage-provisioner`

3. Check the status of the minikube cluster and its nodes

    `minikube status`

    `kubectl get nodes`

4. Create namespace for jenkins

    `kubectl apply -f jenkins/manifests/jenkins-minikube-prep-for-helm-chart/namespace.yaml`

5. Create service account for jenkins

    `kubectl apply -f jenkins/manifests/jenkins-minikube-prep-for-helm-chart/serviceAccount.yaml`

6. Create volume claim and volume for jenkins

    `kubectl apply -f jenkins/manifests/jenkins-minikube-prep-for-helm-chart/volume.yaml`

In the above spec, `hostPath` uses the `/data/jenkins-volume/` of your node to emulate network-attached storage. This approach is only suited for development and testing purposes.

Minikube configured for hostPath sets the permissions on `/data` to the root account only. Once the volume is created you will need to manually change the permissions to allow the jenkins account to write its data.

7. Change permissions to allow the jenkins account to write its data on volume

    `minikube ssh`

    `sudo mkdir /data/jenkins-volume`

    `sudo chown -R 1000:1000 /data/jenkins-volume`

8. Add Helm repository with Jenkins

    `helm repo add jenkins https://charts.jenkins.io`

    `helm repo update`  

9. For our Jenkins we also would need two custom agents to run Pipeline job. I would like to provide detailed explanation of what was done and why it was done, so that several months or years from now it would help me understand the configuration pecularities. 

Here is a snippet of code from `jenkins/manifests/jenkins-minikube-prep-for-helm-chart/jenkins-values.yaml`:

```
additionalAgents:
  dind:
    podName: dind-agent
    customJenkinsLabels: dind
    image:
      repository: jenkins/jnlp-agent-docker     # based on alpine + busybox, has java openjdk17 as default
      tag: latest
    alwaysPullImage: true
    envVars:
      - name: DOCKER_HOST
        value: "tcp://localhost:2375"
    yamlTemplate:  |-  
     spec: 
         containers:
           - name: dind-daemon 
             image: docker:28.3.2-dind-alpine3.22
             securityContext: 
               privileged: true
             env: 
               - name: DOCKER_TLS_CERTDIR
                 value: ""    
  python:
    podName: python-agent
    customJenkinsLabels: python
    # sideContainerName: python
    image:
      # repository: jenkins/jnlp-agent-python3    # based on alpine + busybox, has old java openjdk11 as default jvm that crashes the container on start
      repository: lerkasan/jnlp-agent-python3
      tag: "jdk21"
    alwaysPullImage: true
    resources:
      requests:
        cpu: "1024m"
        memory: "1024Mi"
      limits:
        cpu: "2048m"
        memory: "4096Mi"
```

The first Jenkins agent would be `docker-in-docker` agent labeled as `dind` and running two containers in a pod based on images:
   - **jenkins/jnlp-agent-docker** - container providing *docker client*
   - **docker:28.3.2-dind-alpine3.22** - container providing *docker daemon* available at `tcp://localhost:2375`

   The environment variable `DOCKER_TLS_CERTDIR` is set to emtpy string `""` for the *docker daemon* container in order to disable TLS and avoid hussle with mounting volumes containing TLS certificates for the client and server/daemon to corresponding *docker client* and *docker daemon* containers. Setting the environment variable `DOCKER_TLS_CERTDIR=""` would also make *docker daemon* listen to TCP port `2375`.
   Otherwise, by default *docker daemon* starts with enforced TLS and listens to TCP port `2376`.

   This agent will be used only for stages **Build Docker Image** and **Push Docker Image**  because they require `docker build` and `docker push` steps.

*Note: Big thanks to the author of the article https://rokpoto.com/jenkins-docker-in-docker-agent/ 
I followed the steps in the article to set up a `docker-in-docker` agent and it worked like a charm.*   

**Ideas for further improvement:**
   **jenkins/jnlp-agent-docker** image has `openjdk17` installed by default. `Java 17` will be deprecated in 2026, so ideally I should have build my own image `lerkasan/jnlp-agent-docker` based on `jenkins/jnlp-agent-docker:latest` and should have installed `openjdk21` as default JDK inside. 

   Adittionally, for the Jenkins controller configuration in `jenkins/manifests/jenkins-minikube-prep-for-helm-chart/jenkins-values.yaml` we are using image **jenkins/jenkins:2.504.3-lts-jdk21** that as its tag might suggest it has `openjdk21` as default JDK:

  ```
  controller:
  componentName: "jenkins-controller"
  image:
    registry: "docker.io"
    repository: "jenkins/jenkins"
    tag: 2.504.3-lts-jdk21
    pullPolicy: "Always"
  ```

   According to the best practices JDK versions inside Jenkins controller and Jenkins agents should be the same. Therefore, one of the potential improvements is to build a custom image with `openjdk21`.

   The second potential improvement is to add a special `entrypoint.sh` as it is suggested in the article https://rokpoto.com/jenkins-docker-in-docker-agent/
   I included `Dockerfile` `entrypoint.sh` script fo futher reference in `jenkins/agents/jnlp-agent-docker`

   The idea behind this `entrypoint.sh` is to avoid a race condition between two containers in the `dind-agent` pod: the *docker client* container and the *docker daemon* container. Sometimes *docker client* container is slightly faster and starts executing `docker build` and `docker push` commands in the stages **Build Docker Image** and **Push Docker Image** before *docker daemon* container in the same pod is ready to receive requests at `tcp://localhost:2375`.

   Currently, the simplest workaround I am using to avoid a race condition is to add `sleep 10` step to the stages **Build Docker Image** and **Push Docker Image** just before `docker build` and `docker push` commands. Here is the code snippet of the workarond in the `Jenkinsfile` pipeline for the `dummy-flask-app` application:

   ```
           stage('Build Docker Image') {
            steps {
                // Adding sleep to ensure Docker Daemon is ready
                sh 'sleep 10'
                sh 'docker build -t "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}" ./src'
            }
        }
   ```

  The third further improvement is to improve security by enabling TLS for *docker daemon* and mounting volumes containing TLS certificates for the client and server/daemon to corresponding *docker client* and *docker daemon* containers. Docker will soon deprecate an ability to disable TLS an it will force using TLS on TCP port `2376` as the only available option.

  So, all previous details were about the `docker-in-docker` agent. 
  
  There is also some explanation that needs to be done about the `python` agent.

  ```
  python:
    podName: python-agent
    customJenkinsLabels: python
    # sideContainerName: python
    image:
      # repository: jenkins/jnlp-agent-python3    # based on alpine + busybox, has old java openjdk11 as default jvm that crashes the container on start
      repository: lerkasan/jnlp-agent-python3
      tag: "jdk21"
    alwaysPullImage: true
    resources:
      requests:
        cpu: "1024m"
        memory: "1024Mi"
      limits:
        cpu: "2048m"
        memory: "4096Mi"
  ```

  I had to build my own `jnlp-agent-python3:jdk21` docker image based on `jenkins/jnlp-agent-python3:latest` image (`latest` tag is the only available tag for `jenkins/jnlp-agent-python3`). Original `jenkins/jnlp-agent-python3:latest` has old java `openjdk11` that makes agent crash on container start because of the incompatability between the Jenkins controller version `2.504.3-lts` based on `openjdk21` and `jnlp-agent` software (written in Java) of the `jenkins/jnlp-agent-python3` agent based on `openjdk11`. Downgrading the controller to same version `2.504.3-lts` based on `openjdk17` didn't fix the problem. And `Java 11` is quite outdated that I desided to build a custom image for the `python` agent.

  `Dockerfile` for the custom `python` agent is available in `jenkins/agents/jnlp-agent-python3`. The image itself was pushed to the public DockerHub repository `lerkasan/jnlp-agent-python3` with `jdk21` tag.

  Here is code snippet of the `Dockerfile`:

  ```
  # latest is the only tag available
FROM jenkins/jnlp-agent-python3:latest

ARG OPENJDK_MAJOR_VERSION=21
ARG SONAR_SCANNER_VERSION=7.0.2.4839
ARG SONAR_SCANNER_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux-x64.zip"

ENV HOME=/root
ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV SONAR_SCANNER_VERSION="${SONAR_SCANNER_VERSION}"
ENV SONAR_SCANNER_HOME="$HOME/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-linux-x64"
ENV PATH="$SONAR_SCANNER_HOME/bin:$PATH"
ENV SONAR_SCANNER_OPTS="-server"

RUN apk add --no-cache helm "openjdk${OPENJDK_MAJOR_VERSION}" unzip yq && \
  wget -q -O /tmp/sonar-scanner-cli.zip "${SONAR_SCANNER_URL}" && \
  mkdir "$HOME/.sonar" && \
  unzip -o /tmp/sonar-scanner-cli.zip -d "$HOME/.sonar/" && \
  sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' "$HOME/.sonar/sonar-scanner-${SONAR_SCANNER_VERSION}-linux-x64/bin/sonar-scanner" && \
  rm /tmp/sonar-scanner-cli.zip && \
  rm -rf /var/cache/apk/*
  ```

  Since I needed to build a custom `python3` agent with `openjdk21`, I decided to install `helm`, `sonar-runner` and `yq` on this custom agent because I needed these tools for different stages of the `Jenkinsfile` pipeline. 

  I increased `memory` and `cpu` requests and limits for `python` agent, bacause otherwise `sonar-scanner` was OOM-killed (Out of Memory) during the Test stage of the `Jenkinsfile` pipeline. 
 ```
     resources:
      requests:
        cpu: "1024m"
        memory: "1024Mi"
      limits:
        cpu: "2048m"
        memory: "4096Mi"
 ``` 

**Other considerations:**

Sometime later I would like to explore more advanced ways of dynamically creating agents, e.g. docker plugin, kaniko etc.
Something like this:
```
// https://stackoverflow.com/questions/64241539/how-to-get-python3-on-jenkins
// Modern jenkins python example - utilizing Pipelines and Docker agent (python:3)

pipeline {
    agent {
      docker {
        image 'python:3'
        label 'my-build-agent'
      }
    }
    stages {
        stage('Test') {
            steps {
              sh """
              python --version
              python ./test.py
              """
            }
        }
    }
}
```

or 

```
    stages {
        stage('Build Docker Image') {
            steps {
                container('docker') {
                  sh 'docker build .'
                }
            }
        }
    }              
```

10. Create `dummy-flask-app` namespace:

`kubectl create ns dummy-flask-app`

11. Login in to your Docker registry using command `docker login`:

`echo "${REGISTRY_PASSWORD}" | docker login -u "${REGISTRY_USERNAME}" --password-stdin`
Afterwards, credentials will be automatically stored in the file `~/.docker/config.json`.

12. Use `~/.docker/config.json` file to create `dockerhub-credentials-secret` that will be used later as one of `imagePullSecrets` to download the `lerkasan/dummy-flask-app` image from private repository on DockerHub.

```
kubectl create secret generic dockerhub-credentials-secret \
  --from-file=.dockerconfigjson=/home/lerkasan/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson \
  --namespace=dummy-flask-app
```

13. *Optional:* Use `~/.docker/config.json` file to create `dockerhub-credentials-secret` in `jenkins` namespace that will be used later as one of `imagePullSecrets` to download the custom `lerkasan/jnlp-agent-python3:jdk21` image from DockerHub. Currently this repository is public and doesn't require `imagePullSecrets`. However, later the visibility of the repository can be changed to private.

```
kubectl create secret generic dockerhub-credentials-secret \
    --from-file=.dockerconfigjson=/home/lerkasan/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson \
    --namespace=jenkins
```

14. Use `env-for-secret.example` file in the `jenkins/manifests/jenkins-minikube-prep-for-helm-chart` directory as an example for a `.env` file that you need to create and provide values of your personal access tokens from GitHub, DockerHub, SonarQube, as well as SMTP credentials:
```
github-username=lerkasan
github-token=provide_your_github_token_here
dockerhub-username=lerkasan
dockerhub-token=provide_your_dockerhub_token_here
sonarqube-token=provide_your_sonarqube_token_here
smtp-username=jenkins.notify.lerkasan@gmail.com
smtp-password=provide_your_smtp_password_here
```

15. Create `jcasc-secrets` secret in namespace `jenkins` from `.env` file.

`kubectl create secret generic jcasc-secrets --from-env-file=.env -n jenkins`

This secret will be used to automatically inject GitHub, DockerHub, SonarQube and SMTP mail credentials into Jenkins controller during initialization with Jenkins Configuration as Code (JCasC). Here are `additionalExistingSecrets` and `JCasC` values from `jenkins-values.yaml` file in `jenkins/manifests/jenkins-minikube-prep-for-helm-chart` directory, that do the magic of auto-configuring credentials in Jenkins:

```
  additionalExistingSecrets:
    - name: jcasc-secrets
      keyName: github-username
    - name: jcasc-secrets
      keyName: github-token
    - name: jcasc-secrets
      keyName: dockerhub-username
    - name: jcasc-secrets
      keyName: dockerhub-token
    - name: jcasc-secrets
      keyName: sonarqube-token
    - name: jcasc-secrets
      keyName: smtp-username
    - name: jcasc-secrets
      keyName: smtp-password

  JCasC:
    defaultConfig: true
    configScripts:
      jcasc-configs: |
        credentials:
          system:
            domainCredentials:
              - credentials:
                  - usernamePassword:
                      id: "github"
                      scope: GLOBAL
                      username: "${jcasc-secrets-github-username}"
                      password: "${jcasc-secrets-github-token}"
                  - usernamePassword:
                      id: "dockerhub"
                      scope: GLOBAL
                      username: "${jcasc-secrets-dockerhub-username}"
                      password: "${jcasc-secrets-dockerhub-token}"
                  - usernamePassword:
                      id: "smtp"
                      scope: GLOBAL
                      username: "${jcasc-secrets-smtp-username}"
                      password: "${jcasc-secrets-smtp-password}"
                  - string:
                      id: "sonarqube"
                      scope: GLOBAL
                      secret: "${jcasc-secrets-sonarqube-token}"
```

16. Install Jenkins via Helm chart using custom values form a file

    `helm upgrade --install --create-namespace jenkins --namespace jenkins -f jenkins/manifests/jenkins-minikube-prep-for-helm-chart/jenkins-values.yaml jenkinsci/jenkins`


17. Check that Jenkins pods are running successfully and service resource exists for Jenkins  

    `kubectl get pods -n jenkins`

    `kubectl get svc -n jenkins`

18. To access Jenkins obtain admin password from a secret
    `kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo`   

19. Use port-forwarding to make Jenkins available in the browser    
    `kubectl port-forward -n jenkins svc/jenkins 8080:8080`

    Open address `http://localhost:8080` in the browser and login with username `admin` and password from the previous step.

20. After the installation of Jenkins via Helm chart, Jenkins will have a pipeline job called `dummy-flask-app` already automatically created from `Jenkinsfile` during the initialization via Jenkins Configuration as Code (JCasC). You don't need to change anything. This pipeline job is configured to checkout code from `lerkasan/dummy-flask-app` repository on GitHub. That repository contains source code for the dummy flask aplication, Dockerfile and Jenkinsfile.

Here is the example of JCasC value in `jenkins/manifests/jenkins-minikube-prep-for-helm-chart/jenkins-values.yaml` to automatically create a pipeline job: 

```
  JCasC:
    defaultConfig: true
    configScripts:
      jcasc-configs: |
        jobs:
          - script: >
              pipelineJob('dummy-flask-app') {
                triggers {
                  scm('H/5 * * * *')
                }
                definition {
                  cpsScm {
                    scm {
                      git {
                        remote {
                          url('https://github.com/lerkasan/dummy-flask-app.git')
                          credentials('github')
                        }
                        branch('*/main')
                      }
                    }
                    lightweight()
                  }
                }
              } 
```

21. `Email Extention` (`email-ext`) plugin is also configured automatically via CasC value in `jenkins/manifests/jenkins-minikube-prep-for-helm-chart/jenkins-values.yaml`:

```
  JCasC:
    defaultConfig: true
    configScripts:
      jcasc-configs: |
        unclassified:
          email-ext:
            charset: "UTF-8"
            defaultContentType: "text/html"
            maxAttachmentSizeMb: 15
            mailAccount:
              smtpHost: "smtp.gmail.com"
              smtpPort: "587"
              credentialsId: "smtp"
              useSsl: true
              useTls: true
            defaultRecipients: "jenkins.notify.lerkasan@gmail.com"
            defaultReplyTo: "jenkins.notify.lerkasan@gmail.com"
```

22. Verify that the Flask application is installed:

    `helm list`

    `kubectl get pods -n dummy-flask-app`

    `kubectl get svc -n dummy-flask-app`

23. Access the Flask application in the browser:

*Option 1:*
  - Run `kubectl port-forward -n dummy-flask-app svc/dummy-flask-app-dummy-flask-app 8000:8080` to forward traffic from localhost:8000 to `dummy-flask-app` service port 8080. We are using `8000` port that is different than `8080`, because port `8080` on local machine is already in use for port-forwarding to access Jenkins server website.
  - Open `http://localhost:8000` in the browser

*Option 2:*
  - Run `kubectl get nodes -o wide` and fing Internal IP of the node.
  - Find a value for the variable service.nodePort in `flask_app/chart/values.yaml` file. The current value of the mentioned variable is 30080.
  - Open `http://node-internal-ip:node-port` in the browser.
    For example, `http://192.168.59.100:30080`


**Clean up**

1. Stop minikube cluster

    `minikube stop`

2. *Optional:* Delete minikube cluster


    `minikube delete`
______________________________________________________________________________


**TASK 5**

**Prerequisites**

- kubectl
- helm v.3.x
- virtualbox
- minikube
- docker

**Installation**

1. Build docker image:

    `docker build -t lerkasan/dummy-flask-app:0.0.1 .`

2. Push docker image to registry:

    `docker push lerkasan/dummy-flask-app:0.0.1`

3. Add information about the docker image repository, tag and sha256 to the file `flask_app/chart/values.yaml`

4. Start minikube cluster:

    `minikube start --driver=virtualbox --cpus=8 --memory=8g`

5. Check the status of the minikube cluster and its nodes

    `minikube status`

    `kubectl get nodes`

6. Create namespace for the Flask application

    `kubectl create namespace dummy-flask-app`

7. If your docker registry requires authentication, create secret with credentials:
    - Run `docker login` and finish necessary login actions. Afterwards credentials will be automatically stored in the file `~/.docker/config.json`.

    - Create a secret `dockerhub-credentials-secret` with registry credentials in `dummy-flask-app` namespace:

          kubectl create secret generic dockerhub-credentials-secret \
            --from-file=.dockerconfigjson=/home/lerkasan/.docker/config.json \
            --type=kubernetes.io/dockerconfigjson \
            --namespace=dummy-flask-app

8. Install the Flask application in `dummy-flask-app` namespace via helm chart from the directory `flask_app/chart`:

    `helm install -n dummy-flask-app -f ./flask_app/chart/values.yaml dummy-flask-app ./flask_app/chart`

9. Verify that the Flask application is installed:

    `helm list`

    `kubectl get pods -n dummy-flask-app`

    `kubectl get svc -n dummy-flask-app`

10. Access the Flask application in the browser:

*Option 1:*
  - Run `kubectl port-forward -n dummy-flask-app svc/dummy-flask-app-dummy-flask-app 8080:8080`
  - Open `http://localhost:8080` in the browser

*Option 2:*
  - Run `kubectl get nodes -o wide` and fing Internal IP of the node.
  - Find a value for the variable service.nodePort in `flask_app/chart/values.yaml` file. The current value of the mentioned variable is 30080.
  - Open `http://node-internal-ip:node-port` in the browser.
    For example, `http://192.168.59.100:30080`

**Clean up**

1. Uninstall `dummy-flask-app` chart

`helm uninstall dummy-flask-app -n dummy-flask-app`

2. Delete `dummy-flask-app` namespace

    `kubectl delete ns dummy-flask-app`

3. Delete minikube cluster

    `minikube delete`


______________________________________________________________

**TASK 4**

**Prerequisites**

- kubectl
- helm v.3.x
- virtualbox
- minikube

**Features**
- Jenkins data is stored on persistent volume to avoid data loss when pods are terminated
- Jenkins is configured using JCasC via `jenkins-values.yaml` file
- Security and SecurityRealm settings are preconfigured in JCasC
- Freestyle job named "Hello World" is created using JCasC
- JPlugins are configured in `jenkins-values.yaml` file including `job-dsl` plugin needed to create a job that was configured via JCasC

**Installation**

1. Create minikube cluster:

    `minikube start --driver=virtualbox --cpus=8 --memory=8g`

2. Enable storage class and provisioner

    `minikube addons enable default-storageclass`

    `minikube addons enable storage-provisioner`

3. Check the status of the minikube cluster and its nodes

    `minikube status`

    `kubectl get nodes`

4. Create namespace for jenkins

    `kubectl apply -f jenkins/manifests/jenkins-minikube-prep-for-helm-chart/namespace.yaml`

5. Create service account for jenkins

    `kubectl apply -f jenkins/manifests/jenkins-minikube-prep-for-helm-chart/serviceAccount.yaml`

6. Create volume claim and volume for jenkins

    `kubectl apply -f jenkins/manifests/jenkins-minikube-prep-for-helm-chart/volume.yaml`

In the above spec, hostPath uses the /data/jenkins-volume/ of your node to emulate network-attached storage. This approach is only suited for development and testing purposes.

Minikube configured for hostPath sets the permissions on /data to the root account only. Once the volume is created you will need to manually change the permissions to allow the jenkins account to write its data.

7. Change permissions to allow the jenkins account to write its data on volume

    `minikube ssh`

    `sudo mkdir /data/jenkins-volume`

    `sudo chown -R 1000:1000 /data/jenkins-volume`

8. Add Helm repository iwith Jenkins

    `helm repo add jenkins https://charts.jenkins.io`

    `helm repo update`   

9. Install Jenkins via Helm chart using custom values form a file

    `helm install jenkins -n jenkins -f jenkins/manifests/jenkins-minikube-prep-for-helm-chart/jenkins-values.yaml jenkinsci/jenkins`


10. Check that Jenkins pods are running successfully and service resource exists for Jenkins  

    `kubectl get pods -n jenkins`

    `kubectl get svc -n jenkins`

11. To access Jenkins obtain admin password from a secret
    `kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo`   

12. Use port-forwarding to make Jenkins available in the browser    
    `kubectl port-forward -n jenkins svc/jenkins 8080:8080`

    Open address `http://localhost:8080` in the browser and login with username `admin` and password from the previous step.

**Clean up**

1. Delete minikube cluster

    `minikube delete`
______________________________________________________________________________

**TASK 3**

**How to run this code**
1. Run following commands in teminal:

`terraform init`

`terraform apply`

2. Connect to Bastion host via SSH

3. Check cluster nodes using command:
`kubectl get nodes -o wide`

4. Check that cluster works as intended by creating a pod:

```
kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
kubectl get all --all-namespaces
```

The output should show nginx pod in default namespace.

5. To destroy infrastructure run `terraform destroy` and type "yes" to confirm.


*Notes:* Access an EC2 instance in private subnet on AWS through Bastion EC2 instance in public subnet via SSH tunnel:

`ssh -i appserver_rsschool_ssh_key_pair.pem -o ProxyCommand="ssh -i bastion_rsschool_ssh_key_pair.pem -W %h:%p ubuntu@bastion_ip" ubuntu@private_ec2_ip`

`ssh -i appserver_rsschool_ssh_key_pair.pem -o ProxyCommand="ssh -i bastion_rsschool_ssh_key_pair.pem -W %h:%p ubuntu@54.91.195.38" ubuntu@10.1.230.231`


*Notes:* Access a K3S in private subnet on AWS from local machine through Bastion EC2 instance in public subnet via SSH tunnel:

1. Establish SSH tunnel for K3S API Server to use kubectl on local machine:

`ssh -i bastion_rsschool_ssh_key_pair.pem -L 6443:k3s_master_ip:6443 ubuntu@bastion_ip -N &`

`ssh -i bastion_rsschool_ssh_key_pair.pem -L 6443:10.1.240.251:6443 ubuntu@34.228.244.136 -N &`

2. Add kubeconfig to `~/.kube/config` on the local machine and inside this config replace k3s_master_ip with `127.0.0.1`.
Now run `kubectl get nodes` on local machine.
______________________________________________________________________________

**TASK 2**

This main part of terraform code is located in `infra` directory and divided into 3 modules: 
   - vpc
   - ec2
   - ec2_instance_connect_endpoint

The code creates:
   - 2 public subnets in different AZs
   - 2 private subnets in different AZs
   - Internet Gateway
   - 2 NAT Gateways (1 NAT Gateway in each public subnet)
   - Bastion server in a public subnet
   - 2 Application servers in private subnets (1 Application server in each private subnet)
   - 1 EC2 Instance Connect Endpoint in order to be able to directly connect to Application servers without a Bastion server
   - Routing configuration:
     - Instances in all subnets can reach each other
     - Instances in public subnets can reach addresses outside VPC and vice-versa


Here is an example of variables used to create this infrastructure:

```
vpcs = [
  {
    name                     = "rsschool-vpc-1"
    cidr_block               = "10.1.0.0/16"
    public_subnets           = ["10.1.10.0/24", "10.1.20.0/24"]
    private_subnets          = ["10.1.230.0/24", "10.1.240.0/24"]
    enable_dns_hostnames     = true
    enable_dns_support       = true
    enable_flow_logs         = true
    flow_logs_retention_days = 365

    tags = {
      "Environment" = "dev"
      "Project"     = "rsschool-devops"
      "ManagedBy"   = "terraform"
    }
  }
]

ec2_bastions = [
  {
    ec2_instance_type           = "t3.micro"
    vpc_cidr                    = "10.1.0.0/16"
    subnet_cidr                 = "10.1.10.0/24"
    associate_public_ip_address = true
    volume_type                 = "gp3"
    volume_size                 = 10
    delete_on_termination       = true
    private_ssh_key_name        = "bastion_rsschool_ssh_key_pair"
    admin_public_ssh_key_names  = ["ssh_public_key"]
    enable_ec2_instance_connect_endpoint = true
    os                                   = "ubuntu"
    os_product                           = "server"
    os_architecture                      = "amd64"
    os_version                           = "22.04"
    os_releases                          = { "22.04" = "jammy" }
    ami_virtualization                   = "hvm"
    ami_architectures                    = { "amd64" = "x86_64" }
    ami_owner_ids                        = { "ubuntu" = "099720109477" } # Canonical's official Ubuntu AMIs
    tags = {
      "Name"        = "BastionHost"
      "Environment" = "dev"
      "Project"     = "rsschool-devops"
      "ManagedBy"   = "terraform"
    }
  }
]

ec2_appservers = [
  {
    ec2_instance_type     = "t3.micro"
    vpc_cidr              = "10.1.0.0/16"
    subnet_cidr           = "10.1.230.0/24"
    volume_type           = "gp3"
    volume_size           = 10
    delete_on_termination = true
    private_ssh_key_name  = "appserver_rsschool_ssh_key_pair"
    enable_bastion_access = true
    bastion_name          = "BastionHost"
    admin_public_ssh_key_names           = ["ssh_public_key"]
    enable_ec2_instance_connect_endpoint = true
    os                                   = "ubuntu"
    os_product                           = "server"
    os_architecture                      = "amd64"
    os_version                           = "22.04"
    os_releases                          = { "22.04" = "jammy" }
    ami_virtualization                   = "hvm"
    ami_architectures                    = { "amd64" = "x86_64" }
    ami_owner_ids                        = { "ubuntu" = "099720109477" } # Canonical's official Ubuntu AMIs
    tags = {
      "Name"        = "AppServer-1"
      "Environment" = "dev"
      "Project"     = "rsschool-devops"
      "ManagedBy"   = "terraform"
    }
  },
  {
    ec2_instance_type           = "t3.micro"
    vpc_cidr                    = "10.1.0.0/16"
    subnet_cidr                 = "10.1.240.0/24"
    associate_public_ip_address = false
    enable_bastion_access       = true
    bastion_name                = "BastionHost"
    volume_type                 = "gp3"
    volume_size                 = 10
    delete_on_termination       = true
    private_ssh_key_name        = "appserver_rsschool_ssh_key_pair"
    admin_public_ssh_key_names  = ["ssh_public_key"]
    enable_ec2_instance_connect_endpoint = true
    os                                   = "ubuntu"
    os_product                           = "server"
    os_architecture                      = "amd64"
    os_version                           = "22.04"
    os_releases                          = { "22.04" = "jammy" }
    ami_virtualization                   = "hvm"
    ami_architectures                    = { "amd64" = "x86_64" }
    ami_owner_ids                        = { "ubuntu" = "099720109477" } # Canonical's official Ubuntu AMIs
    tags = {
      "Name"        = "AppServer-2"
      "Environment" = "dev"
      "Project"     = "rsschool-devops"
      "ManagedBy"   = "terraform"
    }
  }
]

ec2_instance_connect_endpoints = [
  {
    vpc_cidr    = "10.1.0.0/16"
    subnet_cidr = "10.1.240.0/24"
    tags = {
      "Name"        = "ec2-instance-connect-endpoint"
      "Environment" = "dev"
      "Project"     = "rsschool-devops"
      "ManagedBy"   = "terraform"
    }
  }
]
```

In this example, `appserver_rsschool_ssh_key_pair` and `bastion_rsschool_ssh_key_pair` refer to the names of Key Pairs that should be created beforehand and downloaded manually on AWS Console website. These Key Pairs will be associated with EC2 instances of Bastion server and Application servers correspondently.

Moreover, `admin_public_ssh_key_names` represents a list of names of SSM parameters in SSM Parameter Store. Values (represented as strings) of these SSM parameters can include additional public keys for SSH access to servers. Those public keys will be added to servers using cloud-init via userdata.

Prerequisites:

- AWS CLI v. 2.27 and higher
- Terraform v. 1.12 and higher


To run Terraform code locally please follow these steps:

1. Create an IAM user with following permissions:

    - AmazonEC2FullAccess
    - AmazonRoute53FullAccess
    - AmazonS3FullAccess
    - IAMFullAccess
    - AmazonVPCFullAccess
    - AmazonSQSFullAccess
    - AmazonEventBridgeFullAccess

2. Set values for the following terraform variables in tfvars file or TF_VAR_* environment variables:

    - region
    - admin_public_ips
    - vpcs
    - ec2_bastions
    - ec2_appservers
    - ec2_instance_connect_endpoints

    *Examples of values for these variables can be found in the file **infra/variables.tfvars.example***

3. Create S3 bucket for terraform state and put its name as bucket value into backend.tf file

4. Run following commands in terminal:

    `terraform init`

    `terraform plan` and verify the intended changes

    `terraform apply` and verify the intended changes again, type "yes" to confirm or "no" to cancel.

5. To destroy infrastructure run `terraform destroy` and type "yes" to confirm.


To configure GitHub variables and secrets necessary for GitHub Actions workflow please follow these steps:

1. Create the following variables in your GitHub repository:
    - REGION
    - TERRAFORM_VERSION
    - EC2_BASTIONS
    - EC2_APPSERVERS
    - EC2_INSTANCE_CONNECT_ENDPOINT

    *Examples of values for these variables can be found in the file **infra/variables.tfvars.example***

2. Create the following secrets in your GitHub repository:
    - TERRAFORM_ROLE with a value that equals ARN of the IAM role created earlier for GitHub Actions 
    - INFRACOST_API_KEY if you want to use Infracost tool, otherwise delete steps related to Infracost from terraform-plan job in GitHub Actions workflow.

______________________________________________________________________________

TASK 1

This task provides Terraform code in `bootstrap` directory to create AWS resources that are necessary to bootstrap a new infrastructure project:
- S3 bucket for Terraform state
- IAM group
- IAM user to run Terraform code locally
- IAM role to be assumed by GitHub Action with permissions to run Terraform code
- OIDC provider to authenticate GitHub Action with AWS
- GitHub Actions workflow that validates, plans, and applies Terraform code

IAM group, IAM user and IAM role have permissions listed below:
- AmazonEC2FullAccess
- AmazonRoute53FullAccess
- AmazonS3FullAccess
- IAMFullAccess
- AmazonVPCFullAccess
- AmazonSQSFullAccess
- AmazonEventBridgeFullAccess

Prerequisites:

- AWS CLI v. 2.27 and higher
- Terraform v. 1.12 and higher


To run Terraform code locally please follow these steps:

1. Create an IAM user with following permissions:

    - AmazonEC2FullAccess
    - AmazonRoute53FullAccess
    - AmazonS3FullAccess
    - IAMFullAccess
    - AmazonVPCFullAccess
    - AmazonSQSFullAccess
    - AmazonEventBridgeFullAccess

2. Set values for the following terraform variables in tfvars file or TF_VAR_* environment variables:

    - region
    - s3_buckets
    - users
    - groups
    - oidc_roles

    *Examples of values for these variables can be found in the file **bootstrap/variables.tfvars.example***

3. Create S3 bucket for terraform state and put its name as bucket value into backend.tf file

4. Run following commands in terminal:

    `terraform init`

    `terraform plan` and verify the intended changes

    `terraform apply` and verify the intended changes again, type "yes" to confirm or "no" to cancel.

5. To destroy infrastructure run `terraform destroy` and type "yes" to confirm.


To configure GitHub variables and secrets necessary for GitHub Actions workflow please follow these steps:

1. Create the following variables in your GitHub repository:
    - REGION
    - TERRAFORM_VERSION
    - S3_BUCKETS
    - IAM_GROUPS
    - IAM_USERS
    - OIDC_ROLES

    *Examples of values for these variables can be found in the file **bootstrap/variables.tfvars.example***

2. Create the following secrets in your GitHub repository:
    - TERRAFORM_ROLE with a value that equals ARN of the IAM role created earlier for GitHub Actions 
    - INFRACOST_API_KEY if you want to use Infracost tool, otherwise delete steps related to Infracost from terraform-plan job in GitHub Actions workflow.