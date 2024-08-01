pipeline { 
         agent any
           environment {
        jenkins_server_url = "http://192.168.163.102:8080"
        notification_channel = 'devops'
        slack_url = 'https://hooks.slack.com/services/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'
        deploymentName = "hotstar-deployment"
    containerName = "hotstar-app-server"
    serviceName = "hotstar-service"
    imageName = "master.dns.com/hotstar/$JOB_NAME:v1.$BUILD_ID"
     applicationURL="http://192.168.163.101"
    applicationURI="epps-smartERP/"
    
		   
        
    }
         
    
    tools {
        jdk 'java'
		nodejs 'node16'
    }
    
    stages { 
        stage('Build Checkout') { 
            steps { 
              checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/ckmine11/Hotstar.git']]])
         }
        }
      
			  
			  
		 stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
		

		stage ('Vulnerability Scan - Docker ') {
              steps {
                  
                 parallel   (
     
	 	  "Trivy Scan":{
	 		    sh "bash trivy-docker-image-scan.sh"
		     	},
		   "OPA Conftest":{
			sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
		    }   	
		             	
   	                      )
                    
              }
               }
			   
			 stage ('Regitsry Approve') {
      steps {
      echo "Taking approval from DEV Manager forRegistry Push"
        timeout(time: 7, unit: 'DAYS') {
        input message: 'Do you want to deploy?', submitter: 'admin'
        }
      }
    }

 // Building Docker images
    stage('Building image | Upload to Harbor Repo') {
      steps{
            sh 'chmod -R 777 /var/lib/jenkins/workspace/hotstar-app/shell.sh'
            sh '/var/lib/jenkins/workspace/hotstar-app/shell.sh'  
    }
      
    }  
		

         stage('K8S Deployment - DEV') {
       steps {
         parallel(
          "Deployment": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-deployment.sh"
	  
             }
           },
         "Rollout Status": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
             sh "bash k8s-deployment-rollout-status.sh"
             }
           }
        )
       }
     }
		
			   
			}
			 

			}
