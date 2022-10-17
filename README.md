# Terraform test with localstack

Objectives
- Testing terraform code with built-in subcommand `terraform test` (experimental feature with v0.15 release)
- Use `localstack` for integration testing

Use cases
- Cost effective regression testing
- Offline development, no AWS account access required

Requirements
- Docker for Mac
- Terraform v1.3.2
- Localstack v1.2

Installing Terraform

```bash
$ curl https://releases.hashicorp.com/terraform/1.3.2/terraform_1.3.2_darwin_arm64.zip -o tf.zip
$ unzip tf.zip && chmod +x terraform
$ terraform version
Terraform v1.3.2
on darwin_arm64
```

Installing Localstack
```bash
$ pip3 install localstack
$ localstack start -d

 💻 LocalStack CLI 1.2.0

Starting LocalStack in Docker mode 🐳
    preparing environment
    configuring container
    starting container                       
    detaching
    
$ localstack status services
┏━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┓
┃ Service                  ┃ Status      ┃
┡━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━┩
│ acm                      │ ✔ available │
│ apigateway               │ ✔ available │
│ cloudformation           │ ✔ available │
│ cloudwatch               │ ✔ available │
│ config                   │ ✔ available │
│ dynamodb                 │ ✔ available │
│ dynamodbstreams          │ ✔ available │
│ ec2                      │ ✔ available │
│ es                       │ ✔ available │
│ events                   │ ✔ available │
│ firehose                 │ ✔ available │
│ iam                      │ ✔ available │
│ kinesis                  │ ✔ available │
│ kms                      │ ✔ available │
│ lambda                   │ ✔ available │
│ logs                     │ ✔ available │
│ opensearch               │ ✔ available │
│ redshift                 │ ✔ available │
│ resource-groups          │ ✔ available │
│ resourcegroupstaggingapi │ ✔ available │
│ route53                  │ ✔ available │
│ route53resolver          │ ✔ available │
│ s3                       │ ✔ available │
│ s3control                │ ✔ available │
│ secretsmanager           │ ✔ available │
│ ses                      │ ✔ available │
│ sns                      │ ✔ available │
│ sqs                      │ ✔ available │
│ ssm                      │ ✔ available │
│ stepfunctions            │ ✔ available │
│ sts                      │ ✔ available │
│ support                  │ ✔ available │
│ swf                      │ ✔ available │
│ transcribe               │ ✔ available │
└──────────────────────────┴─────────────┘
```
Configure terraform-provider-aws with mock endpoints from localstack

```terraform
provider "aws" {
  access_key = "mock-it"
  secret_key = "mock-it"
  region     = "eu-west-1"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    iam            = "http://localhost:4566"
    rds            = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    route53        = "http://localhost:4566"
    s3             = "http://localhost:4566"
    }
}

resource "aws_s3_bucket" "test-bucket" {
  bucket = "my-bucket"
}
```
You are all set to run terraform apply commands as if you would run it against aws!

```terraform
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.test-bucket will be created
  + resource "aws_s3_bucket" "test-bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "my-bucket"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags_all                    = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      ... <truncated>
      
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```
Apply changes
```terraform
$ terraform apply --auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.test-bucket will be created
  + resource "aws_s3_bucket" "test-bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "my-bucket"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags_all                    = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)
        
        ... <truncated>
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_s3_bucket.test-bucket: Creating...
aws_s3_bucket.test-bucket: Creation complete after 1s [id=my-bucket]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
