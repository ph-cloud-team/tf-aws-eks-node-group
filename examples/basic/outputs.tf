output "node_group_name" {
  description = "Managed node group name."
  value       = module.tf_aws_eks_node_group.node_group_name
}

output "launch_template_id" {
  description = "Launch template ID."
  value       = module.tf_aws_eks_node_group.launch_template_id
}
