## Deploying a microservices-based architecture application

### Overview:
A microservices architecture divides an application into small, independent services that communicate over a network.
In this project, we'll deploy SockShop, a containerized microservices-based application, using Kubernetes for orchestration.

Core DevOps practices will be employed to automate the deployment of SockShop, this DevOps practices will include:
    - Infrastructure as a Code to automate the provisioning of our resources
    - Container Orchestration
    - Monitoring, Logging & Alerts
    - Continous Development and Continous Integration
    - Security

SockShop includes several microservices, such as the front-end, carts, catalouge, payments and shipping. Each service operates independently but share relevant data accross the deployment. Each microservice is packaged in a docker image and kubernetes is used to deploy and orchestrate the communication between the different services. Below is an architectural diagram illustrating the application's workflow.
    ![architecture diagram](images/architecture.png)

I setup my project folder to have all key parts of the project.
    ![screen of my project folder structure](images/filestructure.png)

The app and everything needed to run it is in the `sock-shop-app` directory. There are subdirectories in it:
    - K8s - Kubernetes manifest files for the app and ingress yaml file.
    - Logging - Yaml files to handle the needed metrics for logging
    - Monitoring - yaml files to handle the needed metrics for monitoring
    - Terraform - Terraform configuration for provisioning of 


### Prerequisites:
__Technologies__
To complete the setup, you will need access to several utilities and services, they include:
    - Microsoft Azure
    - Terraform 
    - Kubernetes
    - Helm
    - Prometheus & Grafana
    - Github Actions
    - Let's Encrypt
    - Azure KeyVault and Firewall


__Before you start__
The follwing processes assumes you have some basic familiarity with Kubernetes and that you should have these installed:
- Azure account with active subcription
- AzCLI configured on your terminal
- Terraform installed
- Kubectl
- Helm


### Setup Process:
__Terraform__
Clone the repo or setup your folder structure. Navigate to the terraform directory and write/confirm your configuration files to provision a Kubernetes cluster on Microsoft Azure. The terraform [main.tf](sock-shop-app/terraform/main.tf) file includes configurations to create a resource group and an Azure Kubernetes Service within that group.
_N/B: If you have not previously used docker or any container services in the azure subscription you are plannign to deploy to, you might have to add microsoft container services to the subscription_

Once you are done with your configuration,
Do: `terraform init`
    `terraform plan`
    `terraform apply --auto-approve`

Now, our cluster is up and running, you can visit the portal to investigate.
    ![screen of running cluster](images/akscluster.png)

__Connect to the Cluster & configure Kubectl__
You need kubectl to interact with and manage your cluster. Use the follwing steps to link your cluster to your terminal and configure kubectl access.
    ![screen of how to connect kubectl](images/connect-cluster.png)
    ![screen of kubectl accessing cluster](images/connect-cluster-success.png)

__Deploying the microservice-based app on the cluster__
Having provisioned the AKS cluster and setup a connection to it on your terminal, you can now deploy your app. The application is a series of kubernetes files that creates a namespace, deploys pods for the different parts that make up the app and creates services that acts as network layers over the pods.

Do: `kubectl apply -f <name-of-manifest-file.yaml>`
    ![screenshot](images/kubectl-apply-app.png)

Once there are created, you can check that services are up and running.
    ![screenshot](images/up-and-running.png)

Change context to the sock-shop namespace
Do: `kubectl get all to show (-A or -0 wide)`

To view the app on the browser,
Do `kubectl port-forward service/front-end -n sock-shop 30001:80`
    ![screenshot](images/exposing.png)
    ![screenshot](images/exposed.png)

Now, while the frontend service does enough to expose the app, we need a more flexible and fine-grained control over incoming traffic. An Ingress is needed to give services in the cluster externally-reachable URLs, load balance traffic, terminate SSL/TLS, and offer name-based virtual hosting.

To use ingress, find the [ingress.yaml](sock-shop-app/k8s/ingress.yaml) file with the configurations and install an ingress controller in the cluster, here, the nginx ingress controller will be used.
    ![screenshot](images/apply-ingress.png)

Also, once installed, you will have to update your DNS records with the address pointing to your ingress ip address.
App is now up and running and can be accessible via our domain name, thanks to ingress.
    ![screenshot](images/exposed-ingress.png)

__Requesting a certificate__
The app is up but it is not secure... we will request a certificate from using let's encrypt.
    ![screenshot](images/no-cert.png)
To reach let's encrypt, we will have to instal cert-manager in our cluster.
    ![screenshot](images/yes-cert.png)

__Setup monitoring, logging and alerts__
For monitoring, Prometheus is used alongside Grafana for visualization. Added to monitoring, it also offers alerts that ensure admins are notified of a possible probelm before it occurs.
You will have to install prometheus and grafana using helm and then apply the files containing the configurations for targets and metrics to be gotten. There will run as pods on your cluster. It is best practice to run them in a seperate namespace.
    ![screenshot](images/install-prom.png)
    ![screenshot](images/install-grafana.png)
    ![screenshot](images/namespace-monitoring.png)
    ![screenshot](images/grafana-running.png)

__Building a CI/CD pipeline__
Continous Integration and continous delivery is a key DevOps concept. 
Github Actions will be used to build a ci/cd pipeline for the successful deployment and automation of the Sockshop app. GitHub Actions is a continuous integration and continuous delivery (CI/CD) platform that allows you to automate your build, test, and deployment pipeline.
Github Actions will create a `.github/workflow` directory in the project's root directory. Action files wriiten in yaml will be saved there.

__Summary__
We have successfuly deployed the app and it is fully automated.
If any changes are made to the repo, github actions will build the process we just completed.


### Evaluation criteria:



