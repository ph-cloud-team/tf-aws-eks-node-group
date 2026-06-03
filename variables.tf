variable "name" {
  description = "Managed node group name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.name))
    error_message = "name must be 3-63 characters and use lowercase letters, numbers, and hyphens."
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster that owns this node group."
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN used by the managed node group."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for worker node placement."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "subnet_ids must contain at least two private subnets for baseline availability."
  }
}

variable "instance_types" {
  description = "EC2 instance types allowed for this node group."
  type        = list(string)
  default     = ["t3.medium"]

  validation {
    condition     = length(var.instance_types) > 0
    error_message = "instance_types must contain at least one instance type."
  }
}

variable "capacity_type" {
  description = "Node group capacity type."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "ami_type" {
  description = "EKS managed node group AMI type."
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "release_version" {
  description = "Optional EKS optimized AMI release version. Leave null to let AWS select the current release for the cluster version."
  type        = string
  default     = null
}

variable "scaling_config" {
  description = "Managed node group scaling configuration."
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })
  default = {
    desired_size = 2
    min_size     = 1
    max_size     = 4
  }

  validation {
    condition     = var.scaling_config.desired_size >= 2 && var.scaling_config.min_size >= 1 && var.scaling_config.max_size >= var.scaling_config.desired_size
    error_message = "scaling_config must use desired_size >= 2, min_size >= 1, and max_size >= desired_size."
  }
}

variable "update_config" {
  description = "Managed node group rolling update configuration."
  type = object({
    max_unavailable            = optional(number)
    max_unavailable_percentage = optional(number)
  })
  default = {
    max_unavailable = 1
  }

  validation {
    condition = (
      try(var.update_config.max_unavailable, null) != null ||
      try(var.update_config.max_unavailable_percentage, null) != null
    )
    error_message = "update_config must define max_unavailable or max_unavailable_percentage."
  }
}

variable "labels" {
  description = "Kubernetes labels applied to nodes in this node group."
  type        = map(string)
  default     = {}
}

variable "taints" {
  description = "Kubernetes taints applied to nodes in this node group."
  type = map(object({
    key    = string
    value  = optional(string)
    effect = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for taint in values(var.taints) : contains(["NO_SCHEDULE", "NO_EXECUTE", "PREFER_NO_SCHEDULE"], taint.effect)
    ])
    error_message = "taint effect must be NO_SCHEDULE, NO_EXECUTE, or PREFER_NO_SCHEDULE."
  }
}

variable "kubernetes_version" {
  description = "Optional Kubernetes version for the node group. Leave null to inherit from the cluster."
  type        = string
  default     = null
}

variable "force_update_version" {
  description = "Force version update if pods cannot be drained because of pod disruption budgets."
  type        = bool
  default     = false
}

variable "launch_template_name_prefix" {
  description = "Optional launch template name prefix. Defaults to the node group name."
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key ARN used to encrypt node root volumes."
  type        = string
}

variable "root_volume" {
  description = "Encrypted root volume settings for worker nodes."
  type = object({
    size                  = number
    type                  = string
    iops                  = optional(number)
    throughput            = optional(number)
    delete_on_termination = optional(bool, true)
  })
  default = {
    size = 50
    type = "gp3"
  }

  validation {
    condition     = var.root_volume.size >= 30 && contains(["gp3", "io1", "io2"], var.root_volume.type)
    error_message = "root_volume must use size >= 30 and encrypted-capable type gp3, io1, or io2."
  }
}

variable "metadata_options" {
  description = "EC2 instance metadata options for worker nodes."
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 1)
    instance_metadata_tags      = optional(string, "disabled")
  })
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # gitleaks:allow - EC2 IMDSv2 setting, not a credential.
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  validation {
    condition = (
      var.metadata_options.http_tokens == "required" &&
      var.metadata_options.http_put_response_hop_limit <= 1
    )
    error_message = "metadata_options.http_tokens must be required and http_put_response_hop_limit must be 1 or lower."
  }
}

variable "additional_launch_template_tags" {
  description = "Additional tags for the launch template resource and launched instances."
  type        = map(string)
  default     = {}
}

variable "node_group_tags" {
  description = "Additional tags for the managed node group."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Required enterprise tags applied to supported AWS resources."
  type        = map(string)

  validation {
    condition = alltrue([
      for key in ["Application", "CostCenter", "DataClassification", "Environment", "ManagedBy", "Owner"] : contains(keys(var.tags), key)
    ])
    error_message = "tags must include Application, CostCenter, DataClassification, Environment, ManagedBy, and Owner."
  }
}
