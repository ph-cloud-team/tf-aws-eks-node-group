# Security

## Baseline Controls

- SSH remote access is not implemented.
- Worker node root volumes are encrypted with customer-managed KMS.
- IMDSv2 is required for all launched worker nodes.
- Metadata response hop limit is restricted to 1 to reduce metadata credential exposure.
- Private subnets are required for node placement.
- Tags are validated for ownership, environment, and data classification.

## IAM

The node role is supplied by the caller. The role should be created through the IAM role module with a permissions boundary and only the AWS-managed EKS worker policies required for the workload type.

## Operations

Use SSM, Kubernetes APIs, or AWX automation jobs for diagnostics. Avoid direct SSH because it weakens the private infrastructure model and complicates audit controls.
