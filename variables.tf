variable "token" {
  description = "Default yandex authorization token"
  type        = string
}

variable "cloud_id" {
  description = "Default clound ID in yandex cloud"
  type        = string
}

variable "folder_id" {
  description = "Default folder ID in yandex cloud"
  type        = string
}

variable "storage_access_key" {
  description = "Static key ID"
  type        = string
}

variable "storage_secret_key" {
  description = "Static key, secret part"
  type        = string
}

variable "service_account_id" {
  description = "Service account ID"
  type        = string
}