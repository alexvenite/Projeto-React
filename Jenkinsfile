pipeline {
    agent any

    stages {

        stage('Build Image') {
            steps {
                script {
                    //dockerImage = docker.build("${DOCKER_HUB_REPO}:${IMAGE_NAME}" , ".")
                    dockerapp = docker.build("alexvenite/react:${env.BUILD_ID}", ".")
                }
            }
        }

        stage('Unit Test') {
            steps {
                script {
                    // Executa o contêiner
                    containerId = sh(returnStdout: true, script: "docker run -d alexvenite/react:${env.BUILD_ID}").trim()

                    // Aguarda o contêiner iniciar
                    sleep(5)

                    // Executa os testes dentro do contêiner
                    sh "docker exec ${containerId} npm test" 

                    // Remove o contêiner
                    sh "docker rm -f ${containerId}"
                }
            }
        }

        stage('Code Quality') {
            steps {
                script {
                    // Executa o contêiner
                    containerId = sh(returnStdout: true, script: "docker run -d alexvenite/react:${env.BUILD_ID}").trim()

                    // Aguarda o contêiner iniciar
                    sleep(5)

                    // Rodando o ESLint dentro do contêiner
                    sh "docker exec ${containerId} npx eslint ./src --max-warnings 0"

                    // Remove o contêiner
                    sh "docker rm -f ${containerId}"
                }
            }
        }
        
        stage('Push Image') {
            steps {
                script {
                    // Aonde esta escrito ID, precisa colocar user/password do dockerhub nas credentials la no Jenkins, para o user/password nao ficarem expostos aqui no codigo
                    docker.withRegistry('https://registry.hub.docker.com', 'ID') {
                        dockerapp.push("${env.BUILD_ID}")
                    }
                }
            }
        }     
        
        stage('Deploy HML') {
            environment {
                tag_version = "${env.BUILD_ID}"
            }
            steps {
                // Aonde esta escrito ID, precisa colocar o arquivo config que é gerado na maquina quando voce loga no cluster AKS, colocar la nas credentials no Jenkins como SecretFile, para o config nao ficar exposto aqui no codigo
                withKubeConfig([credentialsId: 'ID']) {
                    sh 'sed -i "s/{{tag}}/$tag_version/g" ./aks/hml.yaml'
                    sh 'kubectl apply -f aks/hml.yaml'
                }
            }
        }

        stage('Approval PROD') {
            steps {
                script {
                    // A interação com a UI agora deve ser mais clara.
                    input message: 'Aprovar deploy em Produção ?', ok: 'Aprovar', parameters: [string(defaultValue: '', description: 'Insira algum comentário', name: 'comentario')]
                }
            }
        }

        stage('Deploy PROD') {
            environment {
                tag_version = "${env.BUILD_ID}"
            }
            steps {
                // Aonde esta escrito ID, precisa colocar o arquivo config que é gerado na maquina quando voce loga no cluster AKS, colocar la nas credentials no Jenkins como SecretFile, para o config nao ficar exposto aqui no codigo
                withKubeConfig([credentialsId: 'ID']) {
                    sh 'sed -i "s/{{tag}}/$tag_version/g" ./aks/prod.yaml'
                    sh 'kubectl apply -f aks/prod.yaml'
                }
            }
        }

    } 
}


