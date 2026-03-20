# Terraform Anomaly Detection Example

### Managing Elasticsearch Anomaly Detection Jobs and Datafeeds with Terraform

This repository demonstrates how to create, configure, and manage Elasticsearch [Anomaly Detection](https://www.elastic.co/docs/explore-analyze/machine-learning/anomaly-detection) jobs and datafeeds using Terraform, backed by an [Elastic Cloud](https://cloud.elastic.co) deployment.

It uses the [Elastic Stack Terraform Provider](https://registry.terraform.io/providers/elastic/elasticstack/latest/docs) (`elasticstack`) for ML resources and the [Elastic Cloud Terraform Provider](https://registry.terraform.io/providers/elastic/ec/latest/docs) (`ec`) to provision the deployment itself.

This project is designed for:

- SREs wanting to manage AD jobs as code instead of manual UI/API configuration
- Teams looking for reproducible, version-controlled anomaly detection setups
- Anyone following the accompanying blog post on Terraform and Anomaly Detection

By the end, you'll be able to run:

```
terraform apply
```

And get:

1. A new Elastic Cloud deployment with a dedicated ML node
2. An anomaly detection job with configurable detectors
3. A datafeed wired to your index
4. Full lifecycle control (open/close jobs, start/stop datafeeds)

## Prerequisites

- An [Elastic Cloud](https://cloud.elastic.co) account with an organization-level API key. See [Elastic Cloud regions, deployment templates, and instances](https://www.elastic.co/docs/reference/cloud/cloud-hosted/ec-regions-templates-instances) for available regions and templates.
- Terraform is installed — see [Install Terraform](https://developer.hashicorp.com/terraform/install).
- A terminal shell opened in this directory.
- A valid index suitable for AD jobs (i.e. with a timestamp field) should exist in the Elasticsearch cluster once it is deployed. In this example the index is `filebeat-nginx-elasticco-full`.

## Repo Structure

```
.
├── main.tf                        # Root: providers, variables, module calls
├── sample_data.ndjson             # Sample data for the AD job
├── .env.example                   # Template for secrets
├── elastic-env.sh                 # Helper to load/unload secrets
└── modules/
    ├── job/
    │   ├── main.tf                # AD job resource
    │   ├── variables.tf           # Job parameters
    │   └── outputs.tf             # Exports job_id
    ├── datafeed/
    │   ├── main.tf                # Datafeed resource
    │   ├── variables.tf           # Datafeed parameters
    │   └── outputs.tf             # Exports datafeed_id
    ├── job_state/
    │   ├── main.tf                # Job state resource
    │   ├── variables.tf           # State parameters
    │   └── outputs.tf             # Exports state
    └── datafeed_state/
        ├── main.tf                # Datafeed state resource
        ├── variables.tf           # State parameters
        └── outputs.tf             # Exports state
```

Each module follows the standard Terraform convention of separating concerns into `main.tf` (resources), `variables.tf` (inputs), and `outputs.tf` (exports). Outputs allow modules to be chained together so that, for example, the datafeed automatically receives the `job_id` from the job module and Terraform knows the correct order in which to create and destroy resources.

## Security Model

Secrets are never stored in Terraform files.

Terraform variables are populated via environment variables using the `TF_VAR_<variable_name>` convention. Secrets are stored in a local-only `.env` file (never committed) and loaded using the `elastic-env.sh` helper script.

Your `.env` file contains:

```
EC_API_KEY="your-elastic-cloud-api-key-here"
EC_ORG_ID="your-org-id-here"
```

These map to the Terraform variables `ec_api_key` and `ec_organization_id`.

## Getting Started

### 1. Clone the repo

```
git clone https://github.com/elastic/terraform-ad-example
cd terraform-ad-example
```

### 2. Create your `.env` file

```
cp .env.example .env
```

Edit `.env` and fill in your Elastic Cloud API key and Organization ID. Create an API key in Elastic Cloud under **Management → API Keys**.

### 3. Load secrets into the environment

```
source ./elastic-env.sh set
```

Verify with:

```
env | grep TF_VAR
```

### 4. Initialize Terraform

```
terraform init
```

This downloads the `elastic/ec` and `elastic/elasticstack` providers.

### 5. Plan and apply

Review the proposed changes:

```
terraform plan
```

The plan shows all five resources that will be created: the Elastic Cloud deployment, the AD job, the datafeed, and the two state resources.

Apply when ready:

```
terraform apply
```

Type `yes` when prompted. The deployment takes a couple of minutes; the ML resources are created immediately after.

### 6. Load sample data

The repo includes `sample_data.ndjson` with a few sample documents matching the job's expected fields (`@timestamp`, `nginx.access.body_sent.bytes`, and the influencer fields). Load it into the deployment using the Elasticsearch `_bulk` API:

```bash
ES_URL=$(terraform output -raw elasticsearch_https_endpoint)
ES_API_KEY=$(terraform output -raw elasticsearch_api_key 2>/dev/null)

curl -s -XPOST "${ES_URL}/_bulk" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "Content-Type: application/x-ndjson" \
  --data-binary @sample_data.ndjson
```

In practice you'd want many more documents (hundreds to thousands across weeks/months) for the anomaly detection model to learn meaningful baselines — this sample is enough to verify the pipeline works end to end.

### 7. Open the job

Edit the `state` parameter of the `job_state` module call in `main.tf`:

```hcl
module "job_state" {
  source = "./modules/job_state"
  job_id = module.job.job_id
  state  = "opened"
}
```

Then apply:

```
terraform apply
```

### 8. Start the datafeed

Edit the `state` parameter of the `datafeed_state` module call in `main.tf`:

```hcl
module "datafeed_state" {
  source      = "./modules/datafeed_state"
  datafeed_id = module.datafeed.datafeed_id
  state       = "started"

  depends_on = [module.job_state]
}
```

Then apply:

```
terraform apply
```

### 9. Cleaning up

Stop the datafeed and close the job by setting the states back to `"stopped"` and `"closed"`, or destroy all resources:

```
terraform destroy
```

Terraform tears everything down in the correct reverse order: state resources first, then the datafeed, then the job, and finally the Elastic Cloud deployment.

### 10. Unload secrets when done

```
source ./elastic-env.sh unset
```

## Resources

- [Elastic Stack Terraform Provider documentation](https://registry.terraform.io/providers/elastic/elasticstack/latest/docs)
- [Elastic Cloud Terraform Provider documentation](https://registry.terraform.io/providers/elastic/ec/latest/docs)
- [Elastic Cloud regions, deployment templates, and instances](https://www.elastic.co/docs/reference/cloud/cloud-hosted/ec-regions-templates-instances)
