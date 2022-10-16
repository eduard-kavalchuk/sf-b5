variable "vm_image" {
  description = "Image for VM"
  type        = string
  # No default image ID. It should be provided every time when creating an instance.
}

variable "cores" {
  description = "Number of cores"
  type        = number
  default     = 2
}

variable "memory_gb" {
  description = "RAM, GB"
  type        = number
  default     = 2
}

variable "core_fraction" {
  description = "Guaranteed fraction of CPU time, %"
  type        = number
  default     = 20
}

variable "disk_size_gb" {
  description = "Size of disk, GB"
  type        = number
  default     = 20
}

variable "subnet_id" {
  description = "Subnet network ID"
  type        = string
}

variable "service_account_id" {
  description = "Service account ID"
  type        = string
}

variable "zone" {
  description = "VM's zone"
  type        = string
}