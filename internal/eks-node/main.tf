# =============================================================
# Node IAM Role — Managed NG / Karpenter 공통
# =============================================================

resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

# Flat Map 패턴 — N:1 Policy Attachment
locals {
  node_policies = {
    worker_node      = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    cni              = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    ecr_read         = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    ssm              = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ebs_csi          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = local.node_policies

  policy_arn = each.value
  role       = aws_iam_role.node.name
}

# =============================================================
# Infra Node Group
# =============================================================

resource "aws_eks_node_group" "infra" {
  cluster_name    = local.cluster_name
  node_group_name = "${local.cluster_name}-infra"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = local.private_subnet_ids
  version         = local.cluster_version

  scaling_config {
    desired_size = var.infra_ng_desired
    min_size     = var.infra_ng_min
    max_size     = var.infra_ng_max
  }

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"
  disk_size      = var.infra_ng_disk_size
  instance_types = var.infra_ng_instance_types

  labels = {
    role = "infra"
  }

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-infra"
  })

  update_config {
    max_unavailable = 1
  }

  depends_on = [aws_iam_role_policy_attachment.node]
}

# =============================================================
# EKS Access Entry — Node가 클러스터에 조인
# =============================================================

resource "aws_eks_access_entry" "node" {
  cluster_name  = local.cluster_name
  principal_arn = aws_iam_role.node.arn
  type          = "EC2_LINUX"
}
