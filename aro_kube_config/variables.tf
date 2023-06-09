
variable "resource_group_name" {
  description = "Name of the resource group name that contains ARO"
}

variable "cluster_name" {
  description = "Name of the ARO cluster"
}

variable "region" {
  description = "Location of the resource group."
}

variable "kube_config_path" {
  default = "/tmp/kubeconfig"
  description = "Location where kubeConfig will be created"
}

variable "generate_kube_config" {
  default = true
  description = "Dictates if the kubeConfig file should be generated or not. Set it to false to not generate the kubeConfig"
}