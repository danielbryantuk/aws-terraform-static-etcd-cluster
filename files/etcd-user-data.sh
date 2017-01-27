#!/bin/bash
cd /tmp
wget https://github.com/coreos/etcd/releases/download/v3.0.10/etcd-v3.0.10-linux-amd64.tar.gz
tar -xvf etcd-v3.0.10-linux-amd64.tar.gz
mv etcd-v3.0.10-linux-amd64/etcd* /usr/bin/
mkdir -p /var/lib/etcd

cat > etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/bin/etcd --name ETCD_NAME \
  --cert-file=/etc/etcd/kubernetes.pem \
  --key-file=/etc/etcd/kubernetes-key.pem \
  --peer-cert-file=/etc/etcd/kubernetes.pem \
  --peer-key-file=/etc/etcd/kubernetes-key.pem \
  --trusted-ca-file=/etc/etcd/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ca.pem \
  --initial-advertise-peer-urls https://INTERNAL_IP:2380 \
  --listen-peer-urls https://INTERNAL_IP:2380 \
  --listen-client-urls https://INTERNAL_IP:2379,http://127.0.0.1:2379 \
  --advertise-client-urls https://INTERNAL_IP:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster controller0=https://10.42.10.5:2380,controller1=https://10.42.11.5:2380,controller2=https://10.42.12.5:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
ETCD_NAME=controller$(echo $INTERNAL_IP | cut -c 8)
sed -i s/INTERNAL_IP/${INTERNAL_IP}/g etcd.service
sed -i s/ETCD_NAME/${ETCD_NAME}/g etcd.service
mv etcd.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable etcd
systemctl start etcd

systemctl status etcd --no-pager
