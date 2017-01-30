#!/bin/bash

mkdir -p /etc/etcd/
cd /etc/etcd

cat > ca.pem <<EOF
${ca_pem_contents}
EOF

cat > etcd-key.pem <<EOF
${etcd_key_pem_contents}
EOF

cat > etcd.pem <<EOF
${etc_pem_contents}
EOF

function set_etcd_initial_cluster_var_from {
  count=0
  IFS=',' read -ra ip_addresses <<< "$1"
  for ip_addr in "$${ip_addresses[@]}"; do
      ETCD_INITIAL_CLUSTER=$ETCD_INITIAL_CLUSTER"etcd"$count"=https://"$ip_addr":2380,"
      count=$((count + 1))
  done
}

set_etcd_initial_cluster_var_from "${etcd_private_ips}"
printf "ETCD_INITIAL_CLUSTER var set to '%s'" "$ETCD_INITIAL_CLUSTER"

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
  --cert-file=/etc/etcd/etcd.pem \
  --key-file=/etc/etcd/etcd-key.pem \
  --peer-cert-file=/etc/etcd/etcd.pem \
  --peer-key-file=/etc/etcd/etcd-key.pem \
  --trusted-ca-file=/etc/etcd/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ca.pem \
  --initial-advertise-peer-urls https://INTERNAL_IP:2380 \
  --listen-peer-urls https://INTERNAL_IP:2380 \
  --listen-client-urls https://INTERNAL_IP:2379,http://127.0.0.1:2379 \
  --advertise-client-urls https://INTERNAL_IP:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster ETCD_INITIAL_CLUSTER \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
ETCD_NAME=etcd$(echo $INTERNAL_IP | cut -c 8)

sed -i s/INTERNAL_IP/$${INTERNAL_IP}/g etcd.service
sed -i s/ETCD_NAME/$${ETCD_NAME}/g etcd.service
sed -i s@ETCD_INITIAL_CLUSTER@$${ETCD_INITIAL_CLUSTER}@g etcd.service
mv etcd.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
