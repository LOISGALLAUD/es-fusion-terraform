# variables.tf
variable "kube_config_path" {
  description = "Path to the kubeconfig file on the host machine to use for Kubernetes operations"
  type        = string
}

variable "kube_config_context" {
  description = "Kubernetes config context to use for Kubernetes operations"
  type        = string
}
