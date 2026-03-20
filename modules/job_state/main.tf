terraform {
  required_providers {
    elasticstack = {
      source = "elastic/elasticstack"
    }
  }
}

resource "elasticstack_elasticsearch_ml_job_state" "this" {
  job_id      = var.job_id
  state       = var.state
  job_timeout = var.job_timeout
}
