# 1. Deployment: The actual "App" pods
resource "kubernetes_deployment_v1" "echo" {
  metadata {
    name      = "echo-app"
    namespace = "default"
  }
  spec {
    replicas = 2
    selector { match_labels = { app = "echo" } }
    template {
      metadata { labels = { app = "echo" } }
      spec {
        container {
          image = "k8s.gcr.io/echoserver:1.10"
          name  = "echo"
          port { container_port = 8080 }
        }
      }
    }
  }
}

# 2. Service: The internal "Gate" to the pods
resource "kubernetes_service_v1" "echo" {
  metadata {
    name      = "echo-service"
    namespace = "default"
  }
  spec {
    selector = { app = "echo" }
    port {
      port        = 80
      target_port = 8080
    }
    type = "NodePort" # Required for ALB interaction
  }
}

# 3. Ingress: This triggers the creation of the AWS ALB
resource "kubernetes_ingress_v1" "echo" {
  metadata {
    name      = "echo-ingress"
    namespace = "default"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip" # Direct to pod IPs
    }
  }
  spec {
    ingress_class_name = "alb" # Crucial: links to the LBC
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.echo.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
