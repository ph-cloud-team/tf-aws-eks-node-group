locals {
  module_name = "tf-aws-eks-node-group"

  common_tags = merge(
    var.tags,
    {
      Module = local.module_name
      Name   = var.name
    }
  )

  launch_template_tags = merge(
    local.common_tags,
    {
      ResourceRole = "eks-node-launch-template"
    }
  )

  node_group_tags = merge(
    local.common_tags,
    var.node_group_tags,
    {
      ResourceRole = "eks-managed-node-group"
    }
  )
}
