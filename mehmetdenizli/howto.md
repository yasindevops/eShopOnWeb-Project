# Kubernetes Cluster
multipass launch --name k8s-master --cpus 2 --memory 1.5G --disk 15G
multipass launch --name k8s-worker --cpus 2 --memory 4.5G --disk 30G

# CI/CD ve Security
multipass launch --name jenkins-srv --cpus 2 --memory 3G --disk 35G
multipass launch --name security-srv --cpus 2 --memory 3G --disk 20G


# K3S Kurulumu traefik olmadan
multipass exec k8s-master -- sh -c "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--disable traefik' sh -"

# Helm yükle (Eğer yoksa)
multipass exec k8s-master -- sh -c "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"

# NGINX deposunu ekle
multipass exec k8s-master -- helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
multipass exec k8s-master -- helm repo update

# .kube klasörünü oluştur
mkdir -p $HOME/.kube

# K3s config dosyasını buraya kopyala
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config

# Dosya sahipliğini kullanıcıya (ubuntu) ver
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# KUBECONFIG değişkenini terminale tanıt (isteğe bağlı ama garanti olur)
export KUBECONFIG=$HOME/.kube/config

# NGINX'i kur
multipass exec k8s-master -- helm install nginx-ingress ingress-nginx/ingress-nginx --set controller.publishService.enabled=true

# worker node'u kur ve master'a ekle

MASTER_IP=$(multipass info k8s-master --format json | jq -r '.info."k8s-master".ipv4[0]')
echo $MASTER_IP
NODE_TOKEN=$(multipass exec k8s-master sudo cat /var/lib/rancher/k3s/server/node-token)
echo $NODE_TOKEN

multipass exec k8s-worker -- sh -c "curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_IP}:6443 K3S_TOKEN=${NODE_TOKEN} sh -"

# jenkins kurulumu
# java kurulumu 

multipass exec jenkins-srv -- sh -c "
  sudo apt-get update && \
  sudo apt-get install -y openjdk-17-jre && \
  java -version
"

multipass exec jenkins-srv -- sh -c "sudo apt update && sudo apt install -y openjdk-17-jdk"

# jenkins kurulumu

multipass exec jenkins-srv -- sh -c "
  sudo apt-get update && \
  sudo apt-get install -y openjdk-17-jre curl gnupg && \
  curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins.gpg --yes && \
  echo 'deb [signed-by=/usr/share/keyrings/jenkins.gpg] https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null && \
  sudo apt-get update && \
  sudo apt-get install -y jenkins && \
  sudo systemctl enable jenkins && \
  sudo systemctl start jenkins
"

multipass exec jenkins-srv -- sh -c "
  sudo systemctl enable jenkins && \
  sudo systemctl start jenkins
"




# 1. Gerekli paketleri kur ve anahtar klasörünü hazırla
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings

# 2. Docker GPG anahtarını indir ve binary formatına çevir
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Docker deposunu sisteme ekle (Noble ve ARM64 için spesifik satır)
echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Listeleri güncelle ve Docker'ı kur
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Jenkins kullanıcısını yetkilendir
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins



