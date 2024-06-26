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
       stage ('Code Quality scan') {
              steps {
        withSonarQubeEnv('sonar') {
          
       sh "sudo /usr/local/bin/sonar-scanner -Dsonar.projectName=hotstar -Dsonar.projectKey=hotstar  -Dsonar.host.url=http://master.dns.com:9001 -Dsonar.login=sqp_e708fbb10fb1e3284045162b9910475e9fe720a1"
        }
		      timeout(time: 2, unit: 'HOURS') {
           script {
             waitForQualityGate abortPipeline: true
           }
         }
   }
              }
			  
			  
		 stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
		

         stage('Synk-Test') {
      steps {
	      snykSecurity failOnError: false, failOnIssues: false, projectName: 'hotstar', snykInstallation: 'snyk', snykTokenId: 'snyk'
       // echo 'Testing...'
      //  snykSecurity(
       //  snykInstallation: 'snyk',
        // snykTokenId: 'bbe4c279-8455-48f7-aeaa-901144bd2a86'
          // place other parameters here
      //  )
      }
   }
		stage ('Vulnerability Scan - Docker ') {
              steps {
                  
                 parallel   (
       "Dependency Scan": {
       	     	dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-check'
       	     	dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
		},
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
