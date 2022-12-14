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

 ๐ป LocalStack CLI 1.2.0

Starting LocalStack in Docker mode ๐ณ
    preparing environment
    configuring container
    starting container                       
    detaching
    
$ localstack status services
โโโโโโโโโโโโโโโโโโโโโโโโโโโโณโโโโโโโโโโโโโโ
โ Service                  โ Status      โ
โกโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโฉ
โ acm                      โ โ available โ
โ apigateway               โ โ available โ
โ cloudformation           โ โ available โ
โ cloudwatch               โ โ available โ
โ config                   โ โ available โ
โ dynamodb                 โ โ available โ
โ dynamodbstreams          โ โ available โ
โ ec2                      โ โ available โ
โ es                       โ โ available โ
โ events                   โ โ available โ
โ firehose                 โ โ available โ
โ iam                      โ โ available โ
โ kinesis                  โ โ available โ
โ kms                      โ โ available โ
โ lambda                   โ โ available โ
โ logs                     โ โ available โ
โ opensearch               โ โ available โ
โ redshift                 โ โ available โ
โ resource-groups          โ โ available โ
โ resourcegroupstaggingapi โ โ available โ
โ route53                  โ โ available โ
โ route53resolver          โ โ available โ
โ s3                       โ โ available โ
โ s3control                โ โ available โ
โ secretsmanager           โ โ available โ
โ ses                      โ โ available โ
โ sns                      โ โ available โ
โ sqs                      โ โ available โ
โ ssm                      โ โ available โ
โ stepfunctions            โ โ available โ
โ sts                      โ โ available โ
โ support                  โ โ available โ
โ swf                      โ โ available โ
โ transcribe               โ โ available โ
โโโโโโโโโโโโโโโโโโโโโโโโโโโโดโโโโโโโโโโโโโโ
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
Integration testing (read more: https://www.terraform.io/language/modules/testing-experiment)

```terraform
$ terraform test
 Warning: The "terraform test" command is experimental
โ 
โ We'd like to invite adventurous module authors to write integration tests for their modules using this command, but all of the behaviors of this command are
โ currently experimental and may change based on feedback.
โ 
โ For more information on the testing experiment, including ongoing research goals and avenues for feedback, see:
โ     https://www.terraform.io/docs/language/modules/testing-experiment.html
โต
โโโ Failed: example.bucket.name_equal (name condition) โโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโ
wrong value
    got:  "happy-3"
    want: "happy-x"

โโโ Failed: example.bucket.object_local_enabled (check if object lock is enabled) โโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโ
condition failed
```