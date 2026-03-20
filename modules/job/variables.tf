variable "job_id" {
  description = "The ID of the anomaly detection job."
  type        = string
}

variable "custom_settings" {
  description = "Custom metadata for the job, encoded as a JSON object in Terraform state."
  type        = map(string)
  default = {
    created_by = "terraform"
    department = "ITOps"
  }
}

variable "analysis_limits" {
  description = "Limits for the resources available to the anomaly detection job."
  type = object({
    model_memory_limit            = string
    categorization_examples_limit = number
  })
  default = {
    model_memory_limit            = "110MB"
    categorization_examples_limit = 4
  }
}

variable "model_snapshot_retention_days" {
  description = "How many days to retain model snapshots."
  type        = number
  default     = 10
}

variable "daily_model_snapshot_retention_after_days" {
  description = "After this many days only daily snapshots are retained."
  type        = number
  default     = 1
}
