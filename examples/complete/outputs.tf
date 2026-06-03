output "node_group_name" {
  description = "Managed node group name."
  value       = module.tf_aws_eks_node_group.node_group_name
}

output "node_group_arn" {
  description = "Managed node group ARN."
  value       = module.tf_aws_eks_node_group.node_group_arn
}

output "capacity_type" {
  description = "Capacity type used by the node group."
  value       = module.tf_aws_eks_node_group.capacity_type
}

output "subnet_ids" {
  description = "Private subnets used by worker nodes."
  value       = module.tf_aws_eks_node_group.subnet_ids
}
