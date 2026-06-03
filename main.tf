resource "aws_launch_template" "this" {
  name_prefix = coalesce(var.launch_template_name_prefix, "${var.name}-")
  description = "Launch template for EKS managed node group ${var.name}"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted             = true
      kms_key_id            = var.kms_key_arn
      volume_size           = var.root_volume.size
      volume_type           = var.root_volume.type
      iops                  = try(var.root_volume.iops, null)
      throughput            = try(var.root_volume.throughput, null)
      delete_on_termination = try(var.root_volume.delete_on_termination, true)
    }
  }

  metadata_options {
    http_endpoint               = var.metadata_options.http_endpoint
    http_tokens                 = var.metadata_options.http_tokens
    http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_options.instance_metadata_tags
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.launch_template_tags, var.additional_launch_template_tags)
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(local.launch_template_tags, var.additional_launch_template_tags)
  }

  tags = merge(local.launch_template_tags, var.additional_launch_template_tags)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = var.name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  ami_type             = var.ami_type
  capacity_type        = var.capacity_type
  force_update_version = var.force_update_version
  instance_types       = var.instance_types
  release_version      = var.release_version
  version              = var.kubernetes_version

  labels = var.labels

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.scaling_config.desired_size
    min_size     = var.scaling_config.min_size
    max_size     = var.scaling_config.max_size
  }

  update_config {
    max_unavailable            = try(var.update_config.max_unavailable, null)
    max_unavailable_percentage = try(var.update_config.max_unavailable_percentage, null)
  }

  dynamic "taint" {
    for_each = var.taints

    content {
      key    = taint.value.key
      value  = try(taint.value.value, null)
      effect = taint.value.effect
    }
  }

  tags = local.node_group_tags

  lifecycle {
    precondition {
      condition     = length(var.subnet_ids) >= 2
      error_message = "Managed node groups must be placed in at least two private subnets."
    }

    precondition {
      condition     = var.scaling_config.desired_size >= 2
      error_message = "Managed node group desired_size must be at least 2."
    }
  }
}
