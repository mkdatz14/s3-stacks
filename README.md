# s3-stacks

This repository takes the S3 workload from `s3-example-app` and models it as a single [Terraform Stack](https://developer.hashicorp.com/terraform/language/stacks).

The workspace-based S3 example creates one HCP Terraform workspace per bucket under `envs/`. This Stack keeps one component definition and fans it out into nine deployments from `deployments.tfdeploy.hcl`.

## File Layout

| File | Purpose |
| --- | --- |
| `components.tfcomponent.hcl` | Declares AWS and random providers, then calls the local `s3_bucket` component. |
| `variables.tfcomponent.hcl` | Stack-level inputs for region, bucket naming, lifecycle rules, encryption, and tags. |
| `outputs.tfcomponent.hcl` | Exposes bucket name, ARN, region, and regional domain name for each deployment. |
| `deployments.tfdeploy.hcl` | Declares the nine S3 bucket deployments that mirror `s3-example-app`. |
| `modules/s3_bucket/` | Local wrapper around `terraform-aws-modules/s3-bucket/aws` version `5.14.1`. |

## Component

The `s3_bucket` component uses the same implementation pattern as `s3-example-app/shared`:

- `random_id` adds a stable suffix to generated bucket names.
- Bucket names are generated from project, environment, purpose, and suffix unless `bucket_name_override` is set.
- Public access is blocked.
- Object ownership is set to `BucketOwnerEnforced`.
- Server-side encryption and lifecycle rules are passed through as inputs.
- Standard tags are merged with deployment-specific tags.

The default project prefix is `s3-stacks`, so generated bucket names are separate from the `s3-example-app` workspace demo.

## Deployments

Each deployment has its own state and its own AWS region, purpose, lifecycle rules, and tags.

| Deployment | Region | Purpose | Force destroy | Versioning |
| --- | --- | --- | --- | --- |
| `dev-1` | `us-west-2` | `app-logs` | `true` | `false` |
| `dev-2` | `us-east-1` | `assets` | `true` | `true` |
| `dev-3` | `us-west-2` | `reports` | `true` | `false` |
| `staging-1` | `us-west-2` | `app-logs` | `true` | `true` |
| `staging-2` | `us-east-1` | `assets` | `true` | `true` |
| `staging-3` | `us-west-2` | `reports` | `true` | `true` |
| `prod-1` | `us-west-2` | `app-logs` | `false` | `true` |
| `prod-2` | `us-east-1` | `assets` | `false` | `true` |
| `prod-3` | `us-west-2` | `reports` | `false` | `true` |

Custom deployment groups and deployment-group auto-approval are intentionally omitted so this example works without an HCP Terraform Premium subscription.

## Usage

Stacks run in HCP Terraform. To deploy:

1. Create a Stack in your HCP Terraform organization and connect it to this repository.
2. Provide AWS credentials through a secure HCP Terraform variable set or Stack environment variables.
3. HCP Terraform reads `components.tfcomponent.hcl` and `deployments.tfdeploy.hcl` to plan each S3 bucket deployment.
4. Review and approve the plans for each deployment.

## Adding An Environment

To add another bucket deployment, append a deployment block:

```hcl
deployment "qa-1" {
  inputs = {
    aws_region         = "us-west-2"
    environment        = "qa-1"
    bucket_purpose     = "app-logs"
    force_destroy      = true
    versioning_enabled = true
    bucket_key_enabled = true

    tags = {
      CostCenter = "qa"
      Owner      = "platform-team"
      Tier       = "qa"
    }
  }
}
```

No new workspace or component wiring is required. The existing S3 component is reused for the new deployment.
