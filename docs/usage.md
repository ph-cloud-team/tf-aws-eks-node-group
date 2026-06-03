# Usage

## Basic Node Group

Use the basic pattern for a system node group with enterprise defaults.

```hcl
module "system_nodes" {
  source = "../../"

  name          = "dev-platform-system"
  cluster_name  = module.eks.cluster_name
  node_role_arn = module.eks_node_role.role_arn
  subnet_ids    = module.vpc.private_subnet_ids
  kms_key_arn   = module.node_kms.key_arn

  labels = {
    nodepool = "system"
  }

  tags = local.common_tags
}
```

## Application Node Group

Use a separate node group for application workloads when labels, taints, sizing, or lifecycle controls differ from platform controllers.

```hcl
module "application_nodes" {
  source = "../../"

  name          = "dev-platform-application"
  cluster_name  = module.eks.cluster_name
  node_role_arn = module.eks_node_role.role_arn
  subnet_ids    = module.vpc.private_subnet_ids
  kms_key_arn   = module.node_kms.key_arn

  instance_types = ["m6i.large", "m6a.large"]

  scaling_config = {
    desired_size = 3
    min_size     = 2
    max_size     = 6
  }

  tags = local.common_tags
}
```
