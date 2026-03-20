terraform {
  required_providers {
    elasticstack = {
      source = "elastic/elasticstack"
    }
  }
}

resource "elasticstack_elasticsearch_ml_anomaly_detection_job" "nginx" {
  job_id          = var.job_id
  description     = "Anomaly detection for network traffic"
  custom_settings = jsonencode(var.custom_settings)
  analysis_config = {
    bucket_span = "15m"
    detectors = [
      {
        function             = "count"
        detector_description = "count"
      },
      {
        function             = "mean"
        field_name           = "nginx.access.body_sent.bytes"
        detector_description = "mean(\"nginx.access.body_sent.bytes\")"
      }
    ]
    influencers        = ["nginx.access.geoip.city_name", "nginx.access.user_agent.build"]
    model_prune_window = "30d"
  }
  analysis_limits = {
    model_memory_limit            = var.analysis_limits.model_memory_limit
    categorization_examples_limit = var.analysis_limits.categorization_examples_limit
  }
  data_description = {
    time_field  = "@timestamp"
    time_format = "epoch_ms"
  }
  model_snapshot_retention_days             = var.model_snapshot_retention_days
  daily_model_snapshot_retention_after_days = var.daily_model_snapshot_retention_after_days
}
