pipeline {
    agent any
    
    environment {
        // --- SENİN KONFİGÜRASYONUN ---
        REGISTRY    = "git.local:3000"
        IMG_NAME    = "mehmet/eshoponweb"      // Gitea kullanıcı/repo yapısı
        API_NAME    = "mehmet/eshoponweb-api"  // API projesi için
        K8S_MASTER  = "k3s-master"           // K3s Master IP adresin
    }


stages {
        stage('Docker Login') {
            steps {
                // Görseldeki ID 'gitea-auth' olduğu için burayı güncelledik
                withCredentials([usernamePassword(credentialsId: 'gitea-auth', usernameVariable: 'GITEA_USER', passwordVariable: 'GITEA_PASS')]) {
                    sh "echo ${GITEA_PASS} | docker login ${REGISTRY} -u ${GITEA_USER} --password-stdin"
                }
            }
        }

        stage('Build & Push Web Image') {
            steps {
                script {
                    // Arkadaşının formatında: Build ve Push işlemleri
                    sh "docker build -f src/Web/Dockerfile -t ${REGISTRY}/${IMG_NAME}:${BUILD_NUMBER} -t ${REGISTRY}/${IMG_NAME}:latest ."
                    sh "docker push ${REGISTRY}/${IMG_NAME}:${BUILD_NUMBER}"
                    sh "docker push ${REGISTRY}/${IMG_NAME}:latest"
                }
            }
        }

        stage('Build & Push API Image') {
            steps {
                script {
                    sh "docker build -f src/PublicApi/Dockerfile -t ${REGISTRY}/${API_NAME}:${BUILD_NUMBER} -t ${REGISTRY}/${API_NAME}:latest ."
                    sh "docker push ${REGISTRY}/${API_NAME}:${BUILD_NUMBER}"
                    sh "docker push ${REGISTRY}/${API_NAME}:latest"
                }
            }
        }

        stage('Deploy to K3s') {
            steps {
                // Jenkins'te 'k3s-kubeconfig' adında bir Secret File oluşturmuş olmalısın
                withCredentials([file(credentialsId: 'k3s-kubeconfig', variable: 'KUBECONFIG')]) {
                    sh """
                        # 1. Web Deployment Güncelleme (Yeni Build Numarası ile)
                        kubectl --kubeconfig=${KUBECONFIG} --server=https://${K8S_MASTER}:6443 --insecure-skip-tls-verify \
                        set image deployment/eshop-web-app eshop-web=${REGISTRY}/${IMG_NAME}:${BUILD_NUMBER}

                        # 2. API Deployment Güncelleme
                        kubectl --kubeconfig=${KUBECONFIG} --server=https://${K8S_MASTER}:6443 --insecure-skip-tls-verify \
                        set image deployment/eshop-api-app eshop-api=${REGISTRY}/${API_NAME}:${BUILD_NUMBER}

                        # 3. Rollout Kontrolü (Her şey yolunda mı?)
                        kubectl --kubeconfig=${KUBECONFIG} --server=https://${K8S_MASTER}:6443 --insecure-skip-tls-verify \
                        rollout status deployment/eshop-web-app
                    """
                }
            }
        }
    }

    post {
        always {
            // Docker logout ve workspace temizliği
            sh "docker logout ${REGISTRY}"
            cleanWs()
        }
        success {
            echo "Efsane! eShopOnWeb Build #${BUILD_NUMBER} başarıyla deploy edildi."
        }
        failure {
            echo "Eyvah! Build #${BUILD_NUMBER} sırasında bir hata oluştu."
        }
    }
}