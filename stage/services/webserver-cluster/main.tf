provider "aws" {
  region = "us-east-2"

  # Tags to apply to all AWS resources by default
  default_tags {
    tags = {
      Owner       = "DevOps Team"
      Environment = "Stage"
      ManagedBy   = "Terraform"
    }
  }
}

module "webserver_cluster" {
  source = "git@github.com:orellanaJav/terraform-modules.git//modules/services/webserver-cluster?ref=v0.0.6"

  cluster_name           = "webserver-stage"
  db_remote_state_bucket = "terraform-state-510693472221"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"
  instance_type          = "t2.micro"
  min_size               = 2
  max_size               = 2
  enable_autoscaling     = false
  server_text            = "Hola Mundo! mi guelita linda :D"

  custom_tags = {
    Owner       = "DevOps Team"
    Environment = "Stage"
    ManagedBy   = "Terraform"
  }

}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

terraform {
  backend "s3" {
    bucket = "terraform-state-510693472221"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-locks-510693472221"
    encrypt        = true
  }
}
