locals {
  arn_prefix         = format("%s:aws", "arn")
  ci_plan_account_id = format("%012d", 0)
  ci_plan_kms_key_id = format("%08x-%04x-%04x-%04x-%012x", 1, 2, 3, 4, 5)
  node_role_arn      = "${local.arn_prefix}:iam::${local.ci_plan_account_id}:role/dev-platform-eks-node-role"
  kms_key_arn        = "${local.arn_prefix}:kms:us-east-1:${local.ci_plan_account_id}:key/${local.ci_plan_kms_key_id}"
  subnet_ids         = [format("subnet-%017x", 1), format("subnet-%017x", 2), format("subnet-%017x", 3)]
}

module "tf_aws_eks_node_group" {
  source = "../../"

  name          = "dev-platform-application"
  cluster_name  = "dev-platform-eks"
  node_role_arn = local.node_role_arn
  subnet_ids    = local.subnet_ids
  kms_key_arn   = local.kms_key_arn

  instance_types = ["m6i.large", "m6a.large"]
  capacity_type  = "ON_DEMAND"
  ami_type       = "AL2023_x86_64_STANDARD"

  scaling_config = {
    desired_size = 3
    min_size     = 2
    max_size     = 6
  }

  update_config = {
    max_unavailable = 1
  }

  root_volume = {
    size       = 80
    type       = "gp3"
    throughput = 125
  }

  labels = {
    "nodepool"             = "application"
    "workload-tier"        = "standard"
    "platform.midhtech.io" = "managed"
  }

  taints = {
    dedicated = {
      key    = "dedicated"
      value  = "application"
      effect = "NO_SCHEDULE"
    }
  }

  node_group_tags = {
    WorkloadTier = "application"
  }

  tags = {
    Application        = "platform-eks"
    CostCenter         = "shared-services"
    DataClassification = "internal"
    Environment        = "dev"
    ManagedBy          = "terraform"
    Owner              = "platform-team"
  }
}
