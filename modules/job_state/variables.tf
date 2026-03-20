variable "job_id" {
  description = "The ID of the anomaly detection job."
  type        = string
}

variable "state" {
  description = "The desired state of the job: \"opened\" or \"closed\"."
  type        = string
  default     = "closed"
}

variable "job_timeout" {
  description = "Time to wait for the job to reach the desired state."
  type        = string
  default     = "30s"
}
