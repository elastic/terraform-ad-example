output "state" {
  description = "The current state of the datafeed."
  value       = elasticstack_elasticsearch_ml_datafeed_state.this.state
}
