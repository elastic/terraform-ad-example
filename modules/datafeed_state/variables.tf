variable "datafeed_id" {
  description = "The ID of the datafeed."
  type        = string
}

variable "state" {
  description = "The desired state of the datafeed: \"started\" or \"stopped\"."
  type        = string
  default     = "stopped"
}

variable "force" {
  description = "Whether to force-stop the datafeed."
  type        = bool
  default     = false
}

variable "datafeed_timeout" {
  description = "Time to wait for the datafeed to reach the desired state."
  type        = string
  default     = "60s"
}
