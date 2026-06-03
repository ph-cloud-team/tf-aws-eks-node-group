locals {
  arn_prefix         = format("%s:aws", "arn")
  ci_plan_account_id = format("%012d", 0)
  ci_plan_kms_key_id = format("%08x-%04x-%04x-%04x-%012x", 1, 2, 3, 4, 5)
  node_role_arn      = "${local.arn_prefix}:iam::${local.ci_plan_account_id}:role/dev-platform-eks-node-role"
  kms_key_arn        = "${local.arn_prefix}:kms:us-east-1:${local.ci_plan_account_id}:key/${local.ci_plan_kms_key_id}"
  subnet_ids         = [format("subnet-%017x", 1), format("subnet-%017x", 2)]
}

module "tf_aws_eks_node_group" {
  source = "../../"

  name          = "dev-platform-system"
  cluster_name  = "dev-platform-eks"
  node_role_arn = local.node_role_arn
  subnet_ids    = local.subnet_ids
  kms_key_arn   = local.kms_key_arn

  labels = {
    "nodepool" = "system"
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
