# 1. Node IAM Role — 모든 노드 그룹이 공유
module "naming_node_role" {
  source = "../../modules/naming"

  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "iam_role"
  name          = "eks-node"
}

resource "aws_iam_role" "node" {
  # IAM Role 이름 길이 제한(38자) 우회를 위해 고정 이름 사용
  name = module.naming_node_role.result

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

# 필수 정책 연결 (WorkerNode, CNI, ECR, SSM, EBS) [cite: 1, 2]
resource "aws_iam_role_policy_attachment" "node" {
  for_each = {
    worker_node = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    cni         = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    ecr_read    = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    ssm         = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ebs_csi     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  policy_arn = each.value
  role       = aws_iam_role.node.name
}

# 2. Managed Node Groups — General 패턴 적용 
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = local.cluster_name
  node_group_name = "${local.cluster_name}-ng-${each.key}"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = local.private_subnet_ids
  version         = local.cluster_version

  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = each.value.capacity_type
  disk_size      = each.value.disk_size
  instance_types = each.value.instance_types

  labels = each.value.labels

  tags = merge(local.common_tags, {
    "Name" = "${local.cluster_name}-ng-${each.key}"
  })

  update_config {
    max_unavailable = 1
  }

  # 정책이 먼저 연결되어야 노드가 정상적으로 클러스터에 조인함
  depends_on = [aws_iam_role_policy_attachment.node]
}

# 3. EKS Access Entry — 노드의 클러스터 조인 허용
resource "aws_eks_access_entry" "node" {
  cluster_name  = local.cluster_name
  principal_arn = aws_iam_role.node.arn
  type          = "EC2_LINUX"
}