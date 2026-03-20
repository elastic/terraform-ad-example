output "state" {
  description = "The current state of the job."
  value       = elasticstack_elasticsearch_ml_job_state.this.state
}
