output "module_name" {
  description = "Name of the Terraform module."
  value       = local.module_name
}

output "node_group_name" {
  description = "Managed node group name."
  value       = aws_eks_node_group.this.node_group_name
}

output "node_group_arn" {
  description = "Managed node group ARN."
  value       = aws_eks_node_group.this.arn
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_node_group.this.cluster_name
}

output "status" {
  description = "Managed node group status."
  value       = aws_eks_node_group.this.status
}

output "capacity_type" {
  description = "Node group capacity type."
  value       = aws_eks_node_group.this.capacity_type
}

output "launch_template_id" {
  description = "Launch template ID used by the node group."
  value       = aws_launch_template.this.id
}

output "launch_template_latest_version" {
  description = "Latest launch template version."
  value       = aws_launch_template.this.latest_version
}

output "node_role_arn" {
  description = "IAM role ARN used by the node group."
  value       = aws_eks_node_group.this.node_role_arn
}

output "subnet_ids" {
  description = "Private subnet IDs used by the node group."
  value       = aws_eks_node_group.this.subnet_ids
}
