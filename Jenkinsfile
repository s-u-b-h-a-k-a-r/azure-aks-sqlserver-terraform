pipeline {
  agent {
    kubernetes {
      //cloud 'kubernetes'
      label 'jenkins-slave-terraform-kubectl-helm-azurecli'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jenkins-slave-terraform-kubectl-helm-azurecli
    image: subhakarkotta/terraform-kubectl-helm-azurecli
    command: ['cat']
    tty: true
"""
    }
  }
    options {
        disableConcurrentBuilds()
        timeout(time: 1, unit: 'HOURS')
        ansiColor('xterm')
    }
    parameters {
        choice(
            choices: ['preview' , 'create' , 'show', 'preview-destroy' , 'destroy'],
            description: 'preview - to list the resources being created.  create - creates a new cluster.  show - list the resources of existing cluster.  preview-destroy - list the resources of existing cluster that will be destroyed. destroy - destroys the cluster',
            name: 'action')
        choice(
            choices: ['master' , 'dev' , 'qa', 'staging'],
            description: 'Choose branch to build and deploy',
            name: 'branch')
        string(name: 'credential', defaultValue : '<YOUR_AZURE_ACCOUNT_CREDENTIAL>', description: "Provide your  Azure Credential ID  from Global credentials")
        string(name: 'resourcegroup', defaultValue : '<YOUR_RESOURCE_GROUP>', description: "Existing resource group name where your storage account exists in azure account. ")
        string(name: 'storageaccount', defaultValue : '<YOUR_STORAGE_ACCOUNT>', description: "Existing storage account name in azure account where the auto-generated<.tfstate> file will be saved. ")
        string(name: 'container', defaultValue : '<YOUR_STORAGE_CONTAINER>', description: "Existing container name in the above storage account to store auto-generated <.tfstate> file. ")
        string(name: 'accesskey', defaultValue : '<YOUR_ACCESS_KEY>', description: "Access key to access the storage account. ")
        string(name: 'cluster', defaultValue : '<YOUR_CLUSTER_NAME>', description: "Unique AKS Cluster name [non existing cluster in case of new. Finally cluster name will have {-aks} appended automatically by terraform].")
        text(name: 'parameters', defaultValue : '<YOUR_TERRAFORM_TFVARS>', description: "Provide all the parameters by visiting the github link [https://github.com/SubhakarKotta/azure-aks-sqlserver-terraform/tree/master/provisioning/terraform.tfvars.template].   Make sure you update the values as per your requirements.    Provide unique values for the parameters  cluster: <subhakar-demo-cloud> [cluster {subhakar-demo-cloud-aks} will be created by appending -aks]   db_resource_group_name: <subhakar-demo-cloud-db-rg>   db_name : <subhakar-demo-cloud-db> [database {subhakar-demo-cloud-db-sqlsvr} will be created by appending -sqlsvr]")
    }

    environment {
       PLAN_NAME= "${cluster}-aks-terraform-plan"
       TFVARS_FILE_NAME= "${cluster}-aks-terraform.tfvars"
       GIT_REPO = "https://github.com/SubhakarKotta/azure-aks-sqlserver-terraform.git"
    }   
    
    stages {
        stage('Set Build Display Name') {
            steps {
                script {
                    currentBuild.displayName = "#" + env.BUILD_NUMBER + " " + params.action + "-aks-" + params.cluster
                    currentBuild.description = "Creates AKS Cluster and SQLServer database"
                }
            }
        }
        stage('Git Checkout'){
            steps {
		             git url: "${GIT_REPO}",branch: "${branch}"
            }
  	    }
        stage('Create terraform.tfvars') {
            steps {
              container('jenkins-slave-terraform-kubectl-helm-azurecli'){ 
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                         dir ("provisioning") { 
                             echo "${parameters}"
                             writeFile file: "${TFVARS_FILE_NAME}", text: "${parameters}"
                             echo " ############ Cluster @@@@@ ${cluster} @@@@@ #############"
                             echo " ############ Using @@@@@ ${TFVARS_FILE_NAME} @@@@@ #############"
                         }
                     }
               }
             }
         } 
        stage('versions') {
            steps {
                container('jenkins-slave-terraform-kubectl-helm-azurecli'){ 
                      wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                            sh 'terraform version'
                            sh 'kubectl version'
                            sh 'helm version --client'
                            sh 'az --version'
                       }
                 }
             }
         }
        stage('init') {
            steps {
               container('jenkins-slave-terraform-kubectl-helm-azurecli'){ 
                    withCredentials([azureServicePrincipal(credentialsId: params.credential, subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', tenantIdVariable: 'ARM_TENANT_ID')]) {
                        wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                            dir ("provisioning") { 
                               sh 'terraform init  -backend-config="resource_group_name=${resourcegroup}" -backend-config="storage_account_name=${storageaccount}" -backend-config="container_name=${container}" -backend-config="access_key=${accesskey}" -backend-config="key=${cluster}-aks.tfstate"'
                            }
                         }
                     }
                 }
             }
         }
        stage('validate') {
            when {
                expression { params.action == 'preview' || params.action == 'create' }
             }
             steps {
                container('jenkins-slave-terraform-kubectl-helm-azurecli'){ 
                     withCredentials([azureServicePrincipal(credentialsId: params.credential, subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', tenantIdVariable: 'ARM_TENANT_ID')]) {
                         wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                             dir ("provisioning") { 
                                 sh 'terraform validate -var CLIENT_ID=$ARM_CLIENT_ID  -var CLIENT_SECRET=$ARM_CLIENT_SECRET --var-file=${TFVARS_FILE_NAME}'
                             }
                         }
                     }
                 }
               }
          }
        stage('preview') {
            when {
                expression { params.action == 'preview' }
            }
            steps {
               container('jenkins-slave-terraform-kubectl-helm-azurecli'){ 
                    withCredentials([azureServicePrincipal(credentialsId: params.credential, subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', tenantIdVariable: 'ARM_TENANT_ID')]) {
                        wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                            dir ("provisioning") {
                                sh 'terraform plan -var prefix=$cluster -var CLIENT_ID=$ARM_CLIENT_ID  -var CLIENT_SECRET=$ARM_CLIENT_SECRET --var-file=${TFVARS_FILE_NAME}'
                             }
                         }
                     }
                 }
             }
        }
        stage('create') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                container('jenkins-slave-terraform-kubectl-helm-azurecli'){ 
                     withCredentials([azureServicePrincipal(credentialsId: params.credential, subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', tenantIdVariable: 'ARM_TENANT_ID')]) {
                         wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                              dir ("provisioning") {
                                 sh 'terraform plan  -var prefix=$cluster -var CLIENT_ID=$ARM_CLIENT_ID  -var CLIENT_SECRET=$ARM_CLIENT_SECRET -out=${PLAN_NAME} --var-file=${TFVARS_FILE_NAME}'
                                 sh 'terraform apply  -auto-approve ${PLAN_NAME}'
                               }
                           }
                       }
                 }
              }
         }
        stage('show') {
            when {
                expression { params.action == 'show' }
            }
            steps {
                container('jenkins-slave-terraform-kubectl-helm-azurecli'){ 
                     withCredentials([azureServicePrincipal(credentialsId: params.credential, subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', tenantIdVariable: 'ARM_TENANT_ID')]) {
                         wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                             dir ("provisioning") {
                                sh 'terraform show'
                             }
                          }
                       }
                 }
             }
         }
        stage('preview-destroy') {
            when {
                expression { params.action == 'preview-destroy' }
            }
            steps {
                  container('jenkins-slave-terraform-kubectl-helm-azurecli'){ 
                       withCredentials([azureServicePrincipal(credentialsId: params.credential, subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', tenantIdVariable: 'ARM_TENANT_ID')]) {
                           wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                               dir ("provisioning") {
                                 sh 'terraform plan -destroy -var CLIENT_ID=$ARM_CLIENT_ID  -var CLIENT_SECRET=$ARM_CLIENT_SECRET --var-file=${TFVARS_FILE_NAME}'
                               }
                           }
                        }
                   } 
             }
         }
        stage('destroy') {
            when {
                expression { params.action == 'destroy' }
            }
            steps {
                container('jenkins-slave-terraform-kubectl-helm-azurecli'){ 
                     withCredentials([azureServicePrincipal(credentialsId: params.credential, subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID', clientIdVariable: 'ARM_CLIENT_ID', clientSecretVariable: 'ARM_CLIENT_SECRET', tenantIdVariable: 'ARM_TENANT_ID')]) {
                         wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                              dir ("provisioning") {
                                 sh 'terraform destroy -var CLIENT_ID=$ARM_CLIENT_ID  -var CLIENT_SECRET=$ARM_CLIENT_SECRET  --var-file=${TFVARS_FILE_NAME} -force'
                              }
                        }
                    }
                 } 
             }
         }
    }
}