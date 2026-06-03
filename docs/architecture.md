# Architecture

The module keeps node group concerns separate from cluster and IAM ownership. Live stacks pass the cluster name, node role ARN, private subnet IDs, and KMS key ARN from dedicated modules.

## Resource Model

- Launch template owns worker node hardening controls that EKS managed node groups do not expose directly.
- Managed node group owns autoscaled worker capacity and Kubernetes node metadata.
- IAM role and policies are intentionally external so identity governance remains reusable and reviewable.

## Network Placement

Node groups are expected to run in private subnets. Internet-bound access for image pulls and AWS APIs should use the VPC endpoint module first, then controlled NAT only where an endpoint is not available.

## Workload Separation

Use labels and taints to separate system, platform, and application workloads. Production environments should avoid mixing platform controllers and tenant applications on the same node pool.
