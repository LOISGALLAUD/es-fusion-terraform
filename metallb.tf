# metallb.tf
# This file loads the official MetalLB manifests.
# We don't want to fetch the official manifest as suggested in the MetalLB documentation 
# because http data source doesn't have any authentication mechanism. So we prefer to
# use the local file data source to load the manifest files from the local filesystem.
# For more information, see https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http
# 
# It also loads the IP address pool and L2 advertisement manifests.

# Load the MetalLB manifests
data "local_file" "metallb_manifest" {
  filename = "manifests/metallb-native.yaml"
}

data "local_file" "metallb_ip_address_pool" {
  filename = "manifests/metallb-ip-address-pool.yaml"
}

data "local_file" "metallb_l2_advertisement" {
  filename = "manifests/metallb-l2-advertisement.yaml"
}

# kubernetes_manifest resource represents *one* Kubernetes resource by supplying a manifest attribute.
# So we need to split the manifest file into individual Kubernetes resources.
locals {
  yamls = [for data in split("---", data.local_file.metallb_manifest.content) : yamldecode(trimspace(data))]
}

# The namespace is always in first position in the official manifest file.
resource "kubernetes_manifest" "metallb_namespace" {
  count    = 1
  manifest = local.yamls[0]
  field_manager {
    force_conflicts = true
    name            = "TerraformMetalLBNamespaceManager"
  }
}

resource "kubernetes_manifest" "metallb" {
  count      = length(local.yamls) - 1
  manifest   = local.yamls[count.index + 1]
  depends_on = [kubernetes_manifest.metallb_namespace] # Ensure the namespace is created first
  field_manager {
    force_conflicts = true
    name            = "TerraformMetalLBManager"
  }
}

resource "kubernetes_manifest" "metallb_ip_address_pool" {
  manifest = yamldecode(data.local_file.metallb_ip_address_pool.content)
  field_manager {
    force_conflicts = true
    name            = "TerraformMetalLBIPPoolManager"
  }
}

resource "kubernetes_manifest" "metallb_l2_advertisement" {
  manifest = yamldecode(data.local_file.metallb_l2_advertisement.content)
  field_manager {
    force_conflicts = true
    name            = "TerraformMetalLBL2AdManager"
  }
}
