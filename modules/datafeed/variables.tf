variable "datafeed_id" {
  description = "The ID of the datafeed."
  type        = string
}

variable "job_id" {
  description = "The ID of the anomaly detection job this datafeed belongs to."
  type        = string
}

variable "indices" {
  description = "A list of indices for the datafeed (may include wildcards)."
  type        = list(string)
}
