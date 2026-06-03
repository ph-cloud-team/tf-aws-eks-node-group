# tf-aws-eks-node-group

Enterprise Terraform module for AWS EKS managed node groups.

This module creates an EKS managed node group with encrypted worker node volumes, IMDSv2 enforcement, controlled rolling updates, private subnet placement, and policy-aligned scaling defaults. It is intended to be consumed by `tf-live` stacks after the EKS cluster, IAM node role, VPC, subnet, and KMS modules are created.

## What This Module Creates

- `aws_launch_template` for hardened worker node settings.
- `aws_eks_node_group` for managed worker capacity.
- Encrypted root volumes using a caller-owned KMS key.
- Instance and volume tag specifications for cost and ownership tracking.
- Optional Kubernetes labels and taints for workload placement.

## Governance Baseline

This module is written to satisfy the local platform policies:

- No `remote_access` block is created. Access should use SSM or Kubernetes-native operations.
- Node groups require at least two private subnets.
- Default desired size is `2`; minimum size is at least `1`.
- Root volumes are encrypted with a supplied KMS key.
- IMDSv2 is required.
- Enterprise tags are required by variable validation.

## Dependency Order

Use this module after:

1. `tf-aws-vpc`
2. `tf-aws-security-groups`
3. `tf-aws-kms-key`
4. `tf-aws-iam-role`
5. `tf-aws-eks-cluster`

Use this module before:

1. `tf-aws-eks-addons`
2. Kubernetes workload delivery through Argo CD or AWX jobs

## Example

```hcl
module "system_nodes" {
  source = "git::http://gitlab.midhtech.local/cloud_team/tf-modules/aws/containers/tf-aws-eks-node-group.git?ref=v1.0.0"

  name          = "dev-platform-system"
  cluster_name  = module.eks.cluster_name
  node_role_arn = module.node_role.role_arn
  subnet_ids    = module.vpc.private_subnet_ids
  kms_key_arn   = module.node_kms.key_arn

  tags = local.common_tags
}
```

## Validation

```bash
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

Shared GitLab CI should also run Checkov and custom OPA/Rego policies from `platform-policies`.
