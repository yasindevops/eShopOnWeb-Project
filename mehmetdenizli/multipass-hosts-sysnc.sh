#!/bin/bash

HOSTS_FILE="/etc/hosts"
TMP_FILE="/tmp/hosts.multipass.tmp"
DOMAIN_SUFFIX=".lab"

echo "Multipass IP bilgileri alınıyor..."

# Sadece 192.168 ile başlayan IP’leri alıyoruz
multipass list | awk '
/Running/ {name=$1}
/192\.168\./ {print $1, name}
' | while read ip name; do
    echo "$ip $name$DOMAIN_SUFFIX"
done > "$TMP_FILE"

if [ ! -s "$TMP_FILE" ]; then
    echo "Çalışan instance bulunamadı."
    exit 1
fi

echo "Eski multipass kayıtları temizleniyor..."

sudo sed -i '' '/# MULTIPASS-BEGIN/,/# MULTIPASS-END/d' "$HOSTS_FILE"

echo "Yeni kayıtlar ekleniyor..."

sudo bash -c "cat >> $HOSTS_FILE" <<EOF

# MULTIPASS-BEGIN
$(cat $TMP_FILE)
# MULTIPASS-END
EOF

rm "$TMP_FILE"

echo "Hosts dosyası güncellendi ✅"

# Ne Yapıyor Bu Script?
# Sadece çalışan VM’leri alır
# Sadece 192.168.x.x IP’leri alır
# /etc/hosts içinde kendi bloğunu yönetir
# Eski kayıtları siler, yenilerini yazar
# Diğer hosts satırlarına dokunmaz


192.168.2.81 git.local
192.168.2.79 jenkins.local
192.168.2.77 k8s-master
192.168.2.78 k8s-worker
192.168.2.80 security.local