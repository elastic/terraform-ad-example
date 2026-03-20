terraform {
  required_providers {
    elasticstack = {
      source = "elastic/elasticstack"
    }
  }
}

resource "elasticstack_elasticsearch_ml_datafeed" "this" {
  datafeed_id = var.datafeed_id
  job_id      = var.job_id
  query = jsonencode({
    bool = {
      must = [
        {
          match_all = {}
        }
      ]
    }
  })
  indices = var.indices
}
