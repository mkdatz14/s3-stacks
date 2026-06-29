# s3-stacks

This repository takes the S3 workload from `s3-example-app` and models it as a single [Terraform Stack](https://developer.hashicorp.com/terraform/language/stacks).

The workspace-based S3 example creates one HCP Terraform workspace per bucket under `envs/`. This Stack keeps one component definition and separates it out into nine deployments from `deployments.tfdeploy.hcl`.

## File Layout

| File | Purpose |
| --- | --- |
| `components.tfcomponent.hcl` | Declares AWS and random providers, then calls the local `s3_bucket` component. |
| `variables.tfcomponent.hcl` | Stack-level inputs for region, bucket naming, lifecycle rules, encryption, and tags. |
| `outputs.tfcomponent.hcl` | Exposes bucket name, ARN, region, and regional domain name for each deployment. |
| `deployments.tfdeploy.hcl` | Declares the nine S3 bucket deployments that mirror `s3-example-app`. |
| `premium-deployment-groups.tfdeploy.hcl.example` | Optional HCP Terraform Plus example showing custom deployment groups and auto-approval checks. |
| `modules/s3_bucket/` | Local wrapper around `terraform-aws-modules/s3-bucket/aws` version `5.14.1`. |

## Component

The `s3_bucket` component uses the same implementation as the `s3-example-app` repository:

- `random_id` adds a stable suffix to generated bucket names.
- Bucket names are generated from project, environment, purpose, and suffix unless `bucket_name_override` is set.
- Public access is blocked.
- Object ownership is set to `BucketOwnerEnforced`.
- Server-side encryption and lifecycle rules are passed through as inputs.
- Standard tags are merged with deployment-specific tags.

The default project prefix is `s3-stacks`, so generated bucket names are separate from other s3 project demos.

## Deployments

Each deployment has its own state and its own AWS region, purpose, lifecycle rules, and tags according to its deployment.

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

The default deployment file omits custom deployment groups so this example works without an HCP Terraform Premium subscription. To show the Premium-only orchestration model, [premium-deployment-groups.tfdeploy.hcl.example](premium-deployment-groups.tfdeploy.hcl.example) includes custom deployment groups and auto-approval checks for successful non-destructive dev and staging plans and no-change prod plans.

## Premium Deployment Groups

HCP Terraform Premium supports deployment group rules for Stacks. The optional example shows:

- `successful_plan`: auto-approval can only continue when planning succeeds.
- `no_resource_deletes`: dev and staging plans can be auto-approved when they do not remove resources.
- `no_changes`: prod plans can be auto-approved only when the plan is successful and has no changes.

Because HCP Terraform currently only supports one deployment per deployment group, the example creates one group per deployment, such as `dev_1`, `staging_1`, and `prod_1`. Copy the example blocks into your `deployments.tfdeploy.hcl` file, then add the matching `deployment_group = deployment_group.<name>` assignment inside each deployment block to use the Premium features.

## Usage

Stacks run in HCP Terraform. To deploy:

1. Create a Stack in your HCP Terraform organization and connect it to this repository.
2. Create an HCP Terraform variable set named `s3-stacks-aws-credentials` with access to the Stack's project.
3. Add these environment variables to the variable set:
   - `AWS_ACCESS_KEY_ID` - sensitive
   - `AWS_SECRET_ACCESS_KEY` - sensitive
  - `AWS_SESSION_TOKEN` - sensitive
4. HCP Terraform reads `components.tfcomponent.hcl` and `deployments.tfdeploy.hcl` to plan each S3 bucket deployment.
5. Review and approve the plans for each deployment.

The Stack reads that variable set with this config:

```hcl
store "varset" "aws_credentials" {
  name     = "s3-stacks-aws-credentials"
  category = "env"
}
```

Each deployment passes `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_SESSION_TOKEN` into Stack variables, and the AWS provider uses those values directly. The secrets are not written into deployment state.

## Adding An Environment

To add another bucket deployment, append a deployment block:

```hcl
deployment "qa-1" {
  inputs = {
    access_key    = store.varset.aws_credentials.AWS_ACCESS_KEY_ID
    secret_key    = store.varset.aws_credentials.AWS_SECRET_ACCESS_KEY
    session_token = store.varset.aws_credentials.AWS_SESSION_TOKEN

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

No new workspace or additional wiring is required. The existing S3 component is reused for the new deployment.
