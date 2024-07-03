# ingress-nginx.tf
# This file describes the Helm release for the Ingress Nginx controller.

resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  chart            = "./charts/ingress-nginx-4.10.1.tgz"
  namespace        = "ingress-nginx"
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  description      = "Ingress Nginx Controller to manage ingress resources"
  recreate_pods    = true

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
}
