def PROJECT = [
  name: 'jenkins-test',
  infrastructure: [
    environments: [
      development: [
        aws_account: credentials('aws_account'),
        domain: credentials('domain'),
        zone_name: credentials('zone_name')
      ]
    ]
  ]
]

pipeline {
  agent none

    environment {
        SERVICE_NAME = "${PROJECT.name}"
        AWS_REGION = 'eu-west-1'
        AWS_ACCESS_KEY = credentials('terraform_access_key')
        AWS_SECRET_KEY = credentials('terraform_secret_key')
        TF_VAR_project_name = "${PROJECT.name}"
    }

        stages {


            stage('NetworkInit-plan'){
                    agent {
                        docker {
                            image 'hashicorp/terraform:light'
                            args "--entrypoint '' -v /etc/passwd:/etc/passwd -v /var/lib/jenkins/.ssh:/var/lib/jenkins/.ssh"
                        }
                    }
                    steps {

                        dir('.'){
                            sh 'terraform --version'
                            sh 'terraform init' 
                            sh "echo \$PWD"
                            sh "whoami"
                        }

                        script {
                            try {
                            // sh "terraform workspace new development"
                            } catch (err) {
                                sh "terraform workspace select development"
                            }
                                sh "terraform plan -out terraform.tfplan;echo \$? > status"
                                stash name: "terraform-plan", includes: "terraform.tfplan"
                            }

                    }
                }

                stage('NetworkApply'){
                    agent {
                        docker {
                            image 'hashicorp/terraform:light'
                            args "--entrypoint '' -v /etc/passwd:/etc/passwd -v /var/lib/jenkins/.ssh:/var/lib/jenkins/.ssh"
                        }
                    }    
                    steps {
                        dir('.'){
                            sh 'terraform --version'
                            sh 'terraform init' 
                            sh "echo \$PWD"
                            sh "whoami"
                        }

                        script{
                            def apply = false
                            try {
                                input message: 'confirm apply', ok: 'Apply Config'
                                apply = true
                            } catch (err) {
                                apply = false
                                dir('.'){
                                    // sh "terraform workspace select development"
                                    sh "terraform destroy -force"
                                }
                                currentBuild.result = 'UNSTABLE'
                            }
                            if(apply){
                                dir('.'){
                                    unstash "terraform-plan"
                                    sh 'terraform apply terraform.tfplan'
                                }
                            }
                        }
                    }
                }
        }        
}
