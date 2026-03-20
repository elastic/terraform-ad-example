terraform {
  required_version = ">= 1.0.0"

  required_providers {
    ec = {
      source  = "elastic/ec"
      version = "~> 0.9"
    }
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "~> 0.13.1"
    }
  }
}

#######################
# Variables
#######################

variable "ec_api_key" {
  type        = string
  description = "Elastic Cloud API key (account-level)."
}

variable "ec_region" {
  type        = string
  default     = "us-east-1"
  description = "Elastic Cloud region (e.g. us-east-1, gcp-us-central1)."
}

variable "deployment_template_id" {
  type        = string
  default     = "aws-cpu-optimized-faster-warm-arm"
  description = "Elastic Cloud deployment template ID."
}

variable "job_id" {
  description = "The ID of the anomaly detection job."
  type        = string
  default     = "nginx"
}

variable "datafeed_id" {
  description = "The ID of the datafeed."
  type        = string
  default     = "datafeed-nginx"
}

variable "indices" {
  description = "A list of indices for the datafeed (may include wildcards)."
  type        = list(string)
  default     = ["filebeat-nginx-elasticco-full"]
}

#######################
# Elastic Cloud
#######################

provider "ec" {
  apikey = var.ec_api_key
}

data "ec_stack" "latest" {
  version_regex = "latest"
  region        = var.ec_region
}

resource "ec_deployment" "demo" {
  name                   = "ml_terraform_example"
  region                 = var.ec_region
  version                = data.ec_stack.latest.version
  deployment_template_id = var.deployment_template_id

  elasticsearch = {
    hot = {
      autoscaling = {}
    }
    ml = {
      size          = "1g"
      size_resource = "memory"
      zone_count    = 1
      autoscaling   = {}
    }
  }

  kibana = {
    topology = {}
  }
}

#######################
# Elastic Stack provider
#######################

provider "elasticstack" {
  elasticsearch {
    username  = ec_deployment.demo.elasticsearch_username
    password  = ec_deployment.demo.elasticsearch_password
    endpoints = [ec_deployment.demo.elasticsearch.https_endpoint]
  }

  kibana {
    endpoints = [ec_deployment.demo.kibana.https_endpoint]
  }
}

#######################
# Modules
#######################

module "job" {
  source = "./modules/job"
  job_id = var.job_id
}

module "datafeed" {
  source      = "./modules/datafeed"
  datafeed_id = var.datafeed_id
  job_id      = module.job.job_id
  indices     = var.indices
}

module "job_state" {
  source = "./modules/job_state"
  job_id = module.job.job_id
  state  = "closed"
}

module "datafeed_state" {
  source      = "./modules/datafeed_state"
  datafeed_id = module.datafeed.datafeed_id
  state       = "stopped"

  depends_on = [module.job_state]
}
