output "job_id" {
  description = "The ID of the anomaly detection job."
  value       = elasticstack_elasticsearch_ml_anomaly_detection_job.nginx.job_id
}
