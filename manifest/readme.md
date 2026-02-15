Kubernetes'e Gitea Şifresini Öğret

```bash

kubectl create secret docker-registry gitea-creds \
  --docker-server=git.local:3000 \
  --docker-username=mehmet \
  --docker-password=39612d5f69abd6ce28ca6fa5a8bb8b2455d5ff2e \
  --docker-email=foriinji@gmail.com
```

Docker Engine ayarlarini yaptim
/etc/docker/daemon.json  

```json
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "insecure-registries": [
    "192.168.2.81:3000",
    "git.local:3000"
  ]
}
```

ayrica /etc/hosts dosyasina ekledim.

192.168.2.81 git.local  

# Proje ana dizininde build ediyoruz

docker build -f src/Web/Dockerfile -t git.local:3000/mehmet/eshoponweb:manual-mac .

# docker login

docker login git.local:3000 -u mehmet
Password:
Login Succeeded

docker push git.local:3000/mehmet/eshoponweb:manual-mac

# api imajini build ediyoruz

docker build -f src/PublicApi/Dockerfile -t git.local:3000/mehmet/eshoponweb-api:manual-mac .

docker push git.local:3000/mehmet/eshoponweb-api:manual-mac

kubectl apply -f sql-deployment.yaml
kubectl apply -f web-deployment.yaml
kubectl apply -f api-deployment.yaml

worker node giteaya erisebilmeli o nedenle /etc/hosts dosyasina ekledim.

192.168.2.81 git.local  

worker node giteaya https yerine http ile erisebilmeli o nedenle /etc/rancher/k3s/registries.yaml dosyasina ekledim.

sudo mkdir -p /etc/rancher/k3s
sudo nano /etc/rancher/k3s/registries.yaml
mirrors:
  "git.local:3000":
    endpoint:
      - "<http://git.local:3000>"

jenkins icin giteaya webhook eklerken gitea ini de asagidaki eklemeyi yaptim. Gemini said
Bu güvenlik ayarı, kötü niyetli kişilerin Gitea sunucunuzu bir basamak olarak kullanarak iç ağınızdaki diğer gizli servislere (veritabanı veya admin panelleri gibi) saldırmasını engellemek için vardır.

Böylece SSRF (Server-Side Request Forgery) saldırılarına karşı koruma sağlanır ve sunucunun sadece izin verilen dış adreslerle iletişim kurması garanti edilir.

[webhook]
ALLOWED_HOST_LIST = *
[webhook]
ALLOWED_HOST_LIST = 192.168.2.79, 192.168.2.80 bu sekilde daha prof

112356b51229c8c55b0875671b9dc5b8f3 gitea jenkinsde olusturdugum api token

<http://mehmet:112356b51229c8c55b0875671b9dc5b8f3@jenkins.local:8080/job/eshop/build?token=token> bu sekilde webhook url olusturdum. giteada artik code push yapinca jenkins otomatik build baslatacak.

jenkinsfile yazimi ile devam edilecek
