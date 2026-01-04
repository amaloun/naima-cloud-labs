data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "default-terraform-state-storage-a9f3c2"
    key    = "network/terraform.tfstate"
    region = "eu-west-3"
  }
}
