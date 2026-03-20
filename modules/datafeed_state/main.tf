terraform {
  required_providers {
    elasticstack = {
      source = "elastic/elasticstack"
    }
  }
}

resource "elasticstack_elasticsearch_ml_datafeed_state" "this" {
  datafeed_id      = var.datafeed_id
  state            = var.state
  force            = var.force
  datafeed_timeout = var.datafeed_timeout
}
