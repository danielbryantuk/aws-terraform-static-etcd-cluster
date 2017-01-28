resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "${tls_private_key.ca.algorithm}"
  private_key_pem = "${tls_private_key.ca.private_key_pem}"

  validity_period_hours = 8760

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth",
    "server_auth",
  ]

  subject {
    common_name         = "Kubernetes"
    country             = "US"
    locality            = "Portland"
    organization        = "Kubernetes"
    organizational_unit = "CA"
  }

  is_ca_certificate = true
}

resource "tls_private_key" "etcd" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_locally_signed_cert" "etcd" {
  cert_request_pem   = "${tls_private_key.etcd.private_key_pem}"
  ca_key_algorithm   = "${tls_private_key.ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"

  validity_period_hours = 8760

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth",
    "server_auth",
  ]

  dns_names = [
    "${lookup(var.etcd_private_ips, "zone0")}",
    "${lookup(var.etcd_private_ips, "zone1")}",
    "${lookup(var.etcd_private_ips, "zone2")}",
    "ip-${replace(lookup(var.etcd_private_ips, "zone0"), ".", "-")}",
    "ip-${replace(lookup(var.etcd_private_ips, "zone1"), ".", "-")}",
    "ip-${replace(lookup(var.etcd_private_ips, "zone2"), ".", "-")}",
    "127.0.0.1",
  ]

  subject {
    common_name         = "Kubernetes"
    country             = "US"
    locality            = "Portland"
    organization        = "Kubernetes"
    organizational_unit = "CA"
  }
}
