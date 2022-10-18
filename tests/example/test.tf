
terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "main" {
  source      = "../.."
  bucket_name = "happy-3"
}

resource "test_assertions" "toggle_check" {
  
    component = "bucket"

    check "object_local_enabled" {
        description = "check if object lock is enabled"
        condition = can(regex("^happy-", "3"))
    }

    equal "name_equal" {
        description = "name condition"
        got = module.main.name
        want = "happy-x"
    }



}
