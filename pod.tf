resource "kubernetes_deployment" "dst-server" {
  metadata {
    name = "dst-server"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "dst-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "dst-server"
        }
      }

      spec {
        container {
          name  = "dst-server"
          image = "jamesits/dst-server:nightly"

          resources {
            limits = {
              cpu    = "0.8"
              memory = "1.5Gi"
            }
            requests = {
              cpu    = "0.4"
              memory = "50Mi"
            }
          }

          port {
            name           = "master"
            container_port = 10999
            protocol = "UDP"
          }

          port {
            name           = "caves"
            container_port = 11000
            protocol = "UDP"
          }

          port {
            name           = "steam"
            container_port = 12346
            protocol = "UDP"
          }

          port {
            name           = "steam2"
            container_port = 12347
            protocol = "UDP"
          }

          volume_mount {
            name = "blob1"
            mount_path = "/data"
          }
        }

        volume {
          name = "blob1"
          persistent_volume_claim {
            claim_name = "pvc-blob"
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "dst-server" {
  metadata {
    name = "dst-server"
  }

  spec {
    port {
      name           = "master"
      port = 10999
      protocol = "UDP"
    }

    port {
      name           = "caves"
      port = 11000
      protocol = "UDP"
    }

    port {
      name           = "steam"
      port = 12346
      protocol = "UDP"
    }

    port {
      name           = "steam2"
      port = 12347
      protocol = "UDP"
    }

    selector = {
      app = "dst-server"
    }

    type = "LoadBalancer"
  }
}